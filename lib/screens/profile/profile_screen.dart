import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/issue_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/user_model.dart';
import '../../config/app_constants.dart';
import '../../providers/preferences_provider.dart';
import 'help_center_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final prefs = Provider.of<PreferencesProvider>(context);
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final roleColor =
        {
          'citizen': AppColors.citizenColor,
          'authority': AppColors.authorityColor,
          'worker': AppColors.workerColor,
          'admin': AppColors.adminColor,
        }[user.role] ??
        AppColors.primary;

    final roleIcon =
        {
          'citizen': Icons.person_outline,
          'authority': Icons.admin_panel_settings_outlined,
          'worker': Icons.engineering_outlined,
          'admin': Icons.settings_outlined,
        }[user.role] ??
        Icons.person;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: roleColor,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [roleColor, roleColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child:
                          user.profileImage != null &&
                              user.profileImage!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                user.profileImage!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                cacheWidth: 200,
                              ),
                            )
                          : Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(roleIcon, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                user.role[0].toUpperCase() +
                                    user.role.substring(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => _showEditProfile(context, user),
              ),
            ],
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Account info
                    _Section('Account Information', [
                      _InfoTile(Icons.person_outline, 'Full Name', user.name),
                      _InfoTile(Icons.email_outlined, 'Email', user.email),
                      if (user.phone != null && user.phone!.isNotEmpty)
                        _InfoTile(Icons.phone_outlined, 'Phone', user.phone!),
                      if (user.department != null &&
                          user.department!.isNotEmpty)
                        _InfoTile(
                          Icons.business_outlined,
                          'Department',
                          user.department!,
                        ),
                    ]),
                    const SizedBox(height: 16),

                    // Preferences
                    _Section('Preferences', [
                      _ActionTile(
                        Icons.notifications_outlined,
                        'Notification Settings',
                        prefs.notificationsMuted ? 'Muted' : 'Default Sounds',
                        () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Notification Settings'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  StatefulBuilder(
                                    builder: (ctx, setState) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: const Text('Default Sounds'),
                                            leading: Radio<bool>(
                                              value: false,
                                              // ignore: deprecated_member_use
                                              groupValue:
                                                  prefs.notificationsMuted,
                                              // ignore: deprecated_member_use
                                              onChanged: (val) {
                                                prefs.setNotificationsMuted(
                                                  val!,
                                                );
                                                Navigator.pop(ctx);
                                              },
                                            ),
                                            onTap: () {
                                              prefs.setNotificationsMuted(
                                                false,
                                              );
                                              Navigator.pop(ctx);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('Silent'),
                                            leading: Radio<bool>(
                                              value: true,
                                              // ignore: deprecated_member_use
                                              groupValue:
                                                  prefs.notificationsMuted,
                                              // ignore: deprecated_member_use
                                              onChanged: (val) {
                                                prefs.setNotificationsMuted(
                                                  val!,
                                                );
                                                Navigator.pop(ctx);
                                              },
                                            ),
                                            onTap: () {
                                              prefs.setNotificationsMuted(true);
                                              Navigator.pop(ctx);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionTile(
                        Icons.language_outlined,
                        'Language',
                        prefs.language == 'ta' ? 'Tamil' : 'English',
                        () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Select Language'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  StatefulBuilder(
                                    builder: (ctx, setState) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: const Text('English'),
                                            leading: Radio<String>(
                                              value: 'en',
                                              // ignore: deprecated_member_use
                                              groupValue: prefs.language,
                                              // ignore: deprecated_member_use
                                              onChanged: (val) {
                                                prefs.setLanguage(val!);
                                                Navigator.pop(ctx);
                                              },
                                            ),
                                            onTap: () {
                                              prefs.setLanguage('en');
                                              Navigator.pop(ctx);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('Tamil'),
                                            leading: Radio<String>(
                                              value: 'ta',
                                              // ignore: deprecated_member_use
                                              groupValue: prefs.language,
                                              // ignore: deprecated_member_use
                                              onChanged: (val) {
                                                prefs.setLanguage(val!);
                                                Navigator.pop(ctx);
                                              },
                                            ),
                                            onTap: () {
                                              prefs.setLanguage('ta');
                                              Navigator.pop(ctx);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionTile(
                        Icons.color_lens_outlined,
                        'Theme',
                        prefs.themeMode == ThemeMode.system
                            ? 'System Default'
                            : (prefs.themeMode == ThemeMode.dark
                                  ? 'Dark Mode'
                                  : 'Light Mode'),
                        () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Select Theme'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  StatefulBuilder(
                                    builder: (ctx, setState) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: const Text('System Default'),
                                            leading: Radio<ThemeMode>(
                                              value: ThemeMode.system,
                                              // ignore: deprecated_member_use
                                              groupValue: prefs.themeMode,
                                              // ignore: deprecated_member_use
                                              onChanged: (val) {
                                                prefs.setThemeMode(val!);
                                                Navigator.pop(ctx);
                                              },
                                            ),
                                            onTap: () {
                                              prefs.setThemeMode(
                                                ThemeMode.system,
                                              );
                                              Navigator.pop(ctx);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('Light Mode'),
                                            leading: Radio<ThemeMode>(
                                              value: ThemeMode.light,
                                              // ignore: deprecated_member_use
                                              groupValue: prefs.themeMode,
                                              // ignore: deprecated_member_use
                                              onChanged: (val) {
                                                prefs.setThemeMode(val!);
                                                Navigator.pop(ctx);
                                              },
                                            ),
                                            onTap: () {
                                              prefs.setThemeMode(
                                                ThemeMode.light,
                                              );
                                              Navigator.pop(ctx);
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('Dark Mode'),
                                            leading: Radio<ThemeMode>(
                                              value: ThemeMode.dark,
                                              // ignore: deprecated_member_use
                                              groupValue: prefs.themeMode,
                                              // ignore: deprecated_member_use
                                              onChanged: (val) {
                                                prefs.setThemeMode(val!);
                                                Navigator.pop(ctx);
                                              },
                                            ),
                                            onTap: () {
                                              prefs.setThemeMode(
                                                ThemeMode.dark,
                                              );
                                              Navigator.pop(ctx);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Support
                    _Section('Support', [
                      _ActionTile(
                        Icons.help_outline,
                        'Help Center',
                        'FAQs & guides',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const HelpCenterScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionTile(
                        Icons.feedback_outlined,
                        'Send Feedback',
                        'Share your thoughts',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const HelpCenterScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionTile(
                        Icons.info_outlined,
                        'About App',
                        'Citizen v2.0.0',
                        () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Citizen',
                            applicationVersion: '2.0.0',
                            applicationIcon: const Icon(
                              Icons.location_city,
                              size: 48,
                              color: AppColors.primary,
                            ),
                            children: [
                              const Text(
                                'Citizen is a platform for community issue management.',
                              ),
                            ],
                          );
                        },
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Logout
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          await auth.logout();
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Reset Data (Developer tool)
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reset All App Data'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        onPressed: () => _showResetConfirmation(context),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Data?'),
        content: const Text(
          'This will clear all issues, notifications, and local settings and restore defaults.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final nProv = Provider.of<NotificationProvider>(
                context,
                listen: false,
              );
              final iProv = Provider.of<IssueProvider>(context, listen: false);

              await nProv.resetData();
              await iProv.resetData();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App data reset successfully')),
                );
              }
            },
            child: const Text(
              'Reset Now',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditProfileSheet(user: user),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: AppTextStyles.label),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: children.asMap().entries.map((e) {
              return Column(
                children: [
                  e.value,
                  if (e.key < children.length - 1)
                    const Divider(height: 1, indent: 52),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _ActionTile(this.icon, this.title, this.subtitle, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final User user;
  const _EditProfileSheet({required this.user});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  XFile? _newProfileImage;
  bool _submitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 50,
    );
    if (file != null && mounted) {
      setState(() => _newProfileImage = file);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Edit Profile', style: AppTextStyles.heading2),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _newProfileImage != null
                        ? (kIsWeb
                              ? NetworkImage(_newProfileImage!.path)
                              : FileImage(File(_newProfileImage!.path)))
                        : (widget.user.profileImage != null &&
                                      widget.user.profileImage!.isNotEmpty
                                  ? NetworkImage(widget.user.profileImage!)
                                  : null)
                              as ImageProvider?,
                    child:
                        _newProfileImage == null &&
                            widget.user.profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey.shade400,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Full Name', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Phone Number', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Enter your phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting
                  ? null
                  : () async {
                      setState(() => _submitting = true);
                      final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      await auth.updateUser(
                        _nameCtrl.text,
                        _phoneCtrl.text,
                        profileImage: _newProfileImage,
                      );
                      if (context.mounted) {
                        setState(() => _submitting = false);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
