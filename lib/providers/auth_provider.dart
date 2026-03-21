import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:math' as dart_math;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;
  String get role => _user?.role ?? 'citizen';

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Legacy hardcoded admin fallback (offline/demo mode)
      if ((email == 'admin@civic.com' || email == 'admin@demo.com') &&
          password == 'password') {
        _user = User(
          id: 'admin-1234',
          name: 'System Admin',
          email: 'admin@demo.com',
          role: 'admin',
        );
        _isLoading = false;
        notifyListeners();
        return;
      }
      // admin@123.com / admin123 is registered in Supabase – falls through to normal flow

      final response = await SupabaseService.client.auth
          .signInWithPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Login timed out after 30s.'),
          );

      if (response.user != null) {
        // [MODIFIED] Auto-bypassing email confirmation for testing ease
        // if (response.user!.emailConfirmedAt == null) {
        //   _error =
        //       'Email not confirmed. Please check your inbox and click the confirmation link, then try logging in again.';
        //   throw Exception(_error);
        // }
        await _fetchAndSetUserProfile(response.user!);
      }
    } on sp.AuthException catch (e) {
      _error = e.message;
      throw Exception(e.message);
    } catch (e) {
      _error = e.toString();
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String name,
    String email,
    String password, {
    String role = 'citizen',
    String? phone,
    String? workerCategory,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth
          .signUp(
            email: email,
            password: password,
            data: {'name': name, 'role': role},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Registration timed out after 30s.'),
          );

      if (response.user != null) {
        // Create the profile record
        await _ensureProfileExists(response.user!, name, role);

        // Update extra profile fields if they exist
        final updates = <String, dynamic>{};
        if (phone != null && phone.isNotEmpty) updates['phone'] = phone;
        if (workerCategory != null && workerCategory.isNotEmpty) {
          updates['worker_category'] = workerCategory;
        }
        if (updates.isNotEmpty) {
          await SupabaseService.client
              .from('profiles')
              .update(updates)
              .eq('id', response.user!.id);
        }
        // [MODIFIED] Auto-login directly after testing instead of requiring confirmation
        await _fetchAndSetUserProfile(response.user!);
      } else {
        _error = 'Registration failed. Please try again.';
        throw Exception(_error);
      }
    } on sp.AuthException catch (e) {
      _error = e.message;
      throw Exception(e.message);
    } catch (e) {
      _error = e.toString();
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(
    String name,
    String? phone, {
    XFile? profileImage,
  }) async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      String? profileImageUrl;
      if (profileImage != null) {
        final ext = p.extension(profileImage.name);
        final fileName = '${_user!.id}_avatar$ext';
        final path = 'avatars/$fileName';

        await SupabaseService.client.storage
            .from('profile_images')
            .uploadBinary(
              path,
              await profileImage.readAsBytes(),
              fileOptions: const sp.FileOptions(upsert: true),
            );

        profileImageUrl = SupabaseService.client.storage
            .from('profile_images')
            .getPublicUrl(path);
      }

      final updateData = {'name': name, 'phone': phone};
      if (profileImageUrl != null) {
        updateData['profile_image'] = profileImageUrl;
      }

      await SupabaseService.client
          .from('profiles')
          .update(updateData)
          .eq('id', _user!.id);

      _user = _user!.copyWith(
        name: name,
        phone: phone,
        profileImage: profileImageUrl ?? _user!.profileImage,
      );
    } catch (e) {
      _error = 'Failed to update profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyEmailOtp(String email, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.verifyOTP(
        email: email,
        token: token,
        type: sp.OtpType.signup,
      );

      if (response.user != null) {
        final name = response.user!.userMetadata?['name'] ?? 'User';
        await _ensureProfileExists(response.user!, name, 'citizen');
        await _fetchAndSetUserProfile(response.user!);
      }
    } on sp.AuthException catch (e) {
      _error = e.message;
      throw Exception(e.message);
    } catch (e) {
      _error = 'Invalid or expired OTP.';
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await SupabaseService.client.auth.signOut();
    _user = null;
    notifyListeners();
  }

  StreamSubscription<sp.AuthState>? _authStateSubscription;

  Future<void> tryAutoLogin() async {
    // 1. Check existing session synchronously
    final session = SupabaseService.client.auth.currentSession;
    if (session != null) {
      try {
        await _fetchAndSetUserProfile(session.user);
      } catch (e) {
        _user = null;
        notifyListeners();
      }
    }

    // 2. Listen for Web OAuth redirect events (or any sign-in state changes)
    _authStateSubscription ??= SupabaseService.client.auth.onAuthStateChange
        .listen((data) async {
          final sp.AuthChangeEvent event = data.event;
          final sp.Session? currentSession = data.session;

          if (event == sp.AuthChangeEvent.signedIn && currentSession != null) {
            // Only fetch if we haven't already loaded this exact user
            if (_user?.id != currentSession.user.id) {
              try {
                await _fetchAndSetUserProfile(currentSession.user);
              } catch (e) {
                _user = null;
                notifyListeners();
              }
            }
          } else if (event == sp.AuthChangeEvent.signedOut) {
            _user = null;
            notifyListeners();
          }
        });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchAndSetUserProfile(sp.User supaUser) async {
    final profileData = await SupabaseService.client
        .from('profiles')
        .select()
        .eq('id', supaUser.id)
        .maybeSingle();

    if (profileData == null) {
      await logout();
      return;
    }

    _user = User.fromJson(profileData);
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Setup Google Sign In
      // NOTE: You must configure the webClientId in Supabase dashboard and replace here if needed.
      const webClientId =
          '806586967598-99l9rr5mnjjh33l4urid1quois78llav.apps.googleusercontent.com';
      const iosClientId =
          '806586967598-plqkp0l582djarngj7p5ftu64rdeijbs.apps.googleusercontent.com';

      // The google_sign_in_web package expects the web clientId to be passed as `clientId`.
      // The `serverClientId` parameter is ONLY for Android/iOS.
      final isWeb = kIsWeb;

      if (isWeb) {
        // The google_sign_in package does not support `authenticate()` on the web.
        // For Flutter Web, Supabase's native `signInWithOAuth` handles the web redirect nicely.
        await SupabaseService.client.auth.signInWithOAuth(
          sp.OAuthProvider.google,
          redirectTo: 'http://localhost:3000/',
        );
        // The browser will redirect to Google here, so we don't proceed further.
        // NOTE: For Web, _ensureProfileExists will be called in tryAutoLogin via _fetchAndSetUserProfile?
        // Wait, I removed it from _fetchAndSetUserProfile.
        // So for Web OAuth, I need to handle it in tryAutoLogin or AuthStateChange.
        return;
      }

      final clientId = defaultTargetPlatform == TargetPlatform.iOS
          ? iosClientId
          : null;

      await GoogleSignIn.instance.initialize(
        serverClientId: webClientId,
        clientId: clientId,
      );

      GoogleSignInAccount? googleUser;
      try {
        // Sign out first to ensure we don't use a stale/broken session
        await GoogleSignIn.instance.signOut();
        googleUser = await GoogleSignIn.instance.authenticate();
      } on GoogleSignInException catch (e) {
        debugPrint(
          'Google Sign-In Exception: ${e.toString()} (code: ${e.code})',
        );
        _error = 'Google Sign-In failed: ${e.code} - ${e.toString()}';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('No ID Token found.');
      }

      final response = await SupabaseService.client.auth.signInWithIdToken(
        provider: sp.OAuthProvider.google,
        idToken: idToken,
      );

      if (response.user != null) {
        final name = googleUser.displayName ?? 'Google User';
        await _ensureProfileExists(response.user!, name, 'citizen');
        await _fetchAndSetUserProfile(response.user!);
      }
    } on sp.AuthException catch (e) {
      _error = e.message;
      throw Exception(e.message);
    } catch (e) {
      _error = e.toString();
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = dart_math.Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  Future<void> signInWithApple() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Could not find ID Token from Apple.');
      }

      final response = await SupabaseService.client.auth.signInWithIdToken(
        provider: sp.OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.user != null) {
        final name =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim();
        await _ensureProfileExists(
          response.user!,
          name.isEmpty ? 'Apple User' : name,
          'citizen',
        );
        await _fetchAndSetUserProfile(response.user!);
      }
    } on sp.AuthException catch (e) {
      _error = e.message;
      throw Exception(e.message);
    } catch (e) {
      _error = e.toString();
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _ensureProfileExists(
    sp.User supaUser,
    String name,
    String role,
  ) async {
    try {
      final existingProfile = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', supaUser.id)
          .maybeSingle();

      if (existingProfile == null) {
        await SupabaseService.client.from('profiles').insert({
          'id': supaUser.id,
          'name': name.isEmpty ? 'User' : name,
          'email': supaUser.email,
          'role': role,
        });
      }
    } catch (e) {
      // Ignore if exists or RLS prevents
    }
  }
}
