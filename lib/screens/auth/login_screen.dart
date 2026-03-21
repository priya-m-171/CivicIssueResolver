import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../config/app_constants.dart';
import '../../widgets/responsive_wrapper.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String _selectedRole = 'citizen';
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final _roles = [
    {
      'role': 'citizen',
      'label': 'Citizen',
      'icon': Icons.person_outline,
      'color': AppColors.citizenColor,
      'email': 'citizen@civic.com',
      'desc': 'Report issues',
    },
    {
      'role': 'authority',
      'label': 'Authority',
      'icon': Icons.admin_panel_settings_outlined,
      'color': AppColors.authorityColor,
      'email': 'authority@civic.com',
      'desc': 'Manage complaints',
    },
    {
      'role': 'worker',
      'label': 'Field Worker',
      'icon': Icons.engineering_outlined,
      'color': AppColors.workerColor,
      'email': 'worker@civic.com',
      'desc': 'Complete tasks',
    },
    {
      'role': 'admin',
      'label': 'Admin',
      'icon': Icons.settings_outlined,
      'color': AppColors.adminColor,
      'email': 'admin@civic.com',
      'desc': 'System control',
    },
  ];

  Color get _roleColor {
    final role = _roles.firstWhere((r) => r['role'] == _selectedRole);
    return role['color'] as Color;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _prefillRole('citizen');
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _prefillRole(String role) {
    if (role == 'admin') {
      _emailController.text = 'admin@123.com';
      _passwordController.text = 'admin123';
    } else {
      _emailController.clear();
      _passwordController.clear();
    }
  }

  void _selectRole(String role) {
    setState(() => _selectedRole = role);
    _prefillRole(role);
    _animController.forward(from: 0.3);
  }

  Future<void> _login() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await auth.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        await Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).loadNotifications();
      }
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('SocketException') ||
          errorMsg.contains('timeout') ||
          errorMsg.contains('ClientException')) {
        errorMsg =
            'Network error: Unable to connect to the server. Please check your connection.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor;
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              roleColor,
              roleColor.withValues(alpha: 0.85),
              roleColor.withValues(alpha: 0.6),
              const Color(0xFF1A1A2E),
            ],
            stops: const [0.0, 0.3, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: ResponsiveWrapper(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Citizen',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Community Issue Management',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F9FF),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Role label
                            Text(
                              'Select Your Role',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Role grid (2x2)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 2.6,
                                  ),
                              itemCount: _roles.length,
                              itemBuilder: (ctx, i) {
                                final r = _roles[i];
                                final isSelected = _selectedRole == r['role'];
                                final color = r['color'] as Color;
                                return GestureDetector(
                                  onTap: () => _selectRole(r['role'] as String),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? color.withValues(alpha: 0.12)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? color
                                            : AppColors.divider,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: color.withValues(
                                                  alpha: 0.15,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? color.withValues(alpha: 0.15)
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            r['icon'] as IconData,
                                            color: isSelected
                                                ? color
                                                : Colors.grey,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                r['label'] as String,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? color
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                r['desc'] as String,
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Demo hint
                            if (_selectedRole == 'admin')
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: roleColor.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: roleColor.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: roleColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Admin credentials auto-filled',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: roleColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Email field
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.divider,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Password field
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscure,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(
                                  Icons.lock_outlined,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.divider,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Login button
                            Consumer<AuthProvider>(
                              builder: (ctx, auth, _) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      roleColor,
                                      roleColor.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: roleColor.withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: auth.isLoading ? null : _login,
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            if (_selectedRole == 'citizen') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: AppColors.divider),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'Or sign in with',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: AppColors.divider),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Consumer<AuthProvider>(
                                      builder: (ctx, auth, _) =>
                                          OutlinedButton.icon(
                                            icon: const Icon(
                                              Icons.g_mobiledata,
                                              size: 28,
                                              color: Colors.blueAccent,
                                            ),
                                            label: const Text(
                                              'Google',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              side: const BorderSide(
                                                color: AppColors.divider,
                                              ),
                                            ),
                                            onPressed: auth.isLoading
                                                ? null
                                                : () async {
                                                    try {
                                                      await auth
                                                          .signInWithGoogle();
                                                      if (!ctx.mounted) return;
                                                      if (auth
                                                          .isAuthenticated) {
                                                        await Provider.of<
                                                              NotificationProvider
                                                            >(
                                                              ctx,
                                                              listen: false,
                                                            )
                                                            .loadNotifications();
                                                      }
                                                    } catch (e) {
                                                      if (!ctx.mounted) return;
                                                      ScaffoldMessenger.of(
                                                        ctx,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            e
                                                                .toString()
                                                                .replaceAll(
                                                                  'Exception: ',
                                                                  '',
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Consumer<AuthProvider>(
                                      builder: (ctx, auth, _) =>
                                          OutlinedButton.icon(
                                            icon: const Icon(
                                              Icons.apple,
                                              size: 24,
                                              color: Colors.black87,
                                            ),
                                            label: const Text(
                                              'Apple',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              side: const BorderSide(
                                                color: AppColors.divider,
                                              ),
                                            ),
                                            onPressed: auth.isLoading
                                                ? null
                                                : () async {
                                                    try {
                                                      await auth
                                                          .signInWithApple();
                                                      if (!ctx.mounted) return;
                                                      if (auth
                                                          .isAuthenticated) {
                                                        await Provider.of<
                                                              NotificationProvider
                                                            >(
                                                              ctx,
                                                              listen: false,
                                                            )
                                                            .loadNotifications();
                                                      }
                                                    } catch (e) {
                                                      if (!ctx.mounted) return;
                                                      ScaffoldMessenger.of(
                                                        ctx,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            e
                                                                .toString()
                                                                .replaceAll(
                                                                  'Exception: ',
                                                                  '',
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Register link
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Register',
                                        style: TextStyle(
                                          color: roleColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
