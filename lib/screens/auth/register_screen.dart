import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_constants.dart';
import '../../widgets/responsive_wrapper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'citizen';
  bool _obscure = true;
  String? _selectedWorkerCategory;

  static const _workerCategories = [
    'Road Maintenance',
    'Electrical & Lighting',
    'Water Supply & Plumbing',
    'Sanitation & Waste',
    'Building & Construction',
    'Parks & Greenery',
    'Traffic & Signage',
    'General Field Work',
  ];

  final _roles = [
    {
      'role': 'citizen',
      'label': 'Citizen',
      'icon': Icons.person_outline,
      'color': AppColors.citizenColor,
    },
    {
      'role': 'authority',
      'label': 'Authority',
      'icon': Icons.admin_panel_settings_outlined,
      'color': AppColors.authorityColor,
    },
    {
      'role': 'worker',
      'label': 'Field Worker',
      'icon': Icons.engineering_outlined,
      'color': AppColors.workerColor,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if (_selectedRole == 'worker' && _selectedWorkerCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your worker category'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    try {
      String phone = _phoneController.text.trim();
      if (phone.isNotEmpty && !phone.startsWith('+91')) {
        phone = '+91 $phone';
      }
      await Provider.of<AuthProvider>(context, listen: false).register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        role: _selectedRole,
        phone: phone,
        workerCategory: _selectedRole == 'worker'
            ? _selectedWorkerCategory
            : null,
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // back to AppHome which handles autologin
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
        SnackBar(content: Text(errorMsg), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
        title: const Text('Create Account', style: AppTextStyles.heading3),
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Your Role', style: AppTextStyles.label),
              const SizedBox(height: 10),
              Row(
                children: _roles.map((r) {
                  final isSelected = _selectedRole == r['role'];
                  final color = r['color'] as Color;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedRole = r['role'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : AppColors.divider,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                r['icon'] as IconData,
                                color: isSelected ? color : Colors.grey,
                                size: 22,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                r['label'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? color
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _field('Full Name', _nameController, Icons.person_outline),
              const SizedBox(height: 14),
              _field(
                'Email Address',
                _emailController,
                Icons.email_outlined,
                type: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _field(
                'Phone Number',
                _phoneController,
                Icons.phone_outlined,
                type: TextInputType.phone,
              ),
              if (_selectedRole == 'worker') ...[
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedWorkerCategory,
                  decoration: InputDecoration(
                    labelText: 'Worker Category *',
                    prefixIcon: const Icon(Icons.engineering_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  hint: const Text('Select your specialisation'),
                  items: _workerCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedWorkerCategory = v),
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              Consumer<AuthProvider>(
                builder: (ctx, auth, _) {
                  final roleColor =
                      _roles.firstWhere(
                            (r) => r['role'] == _selectedRole,
                          )['color']
                          as Color;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [roleColor, roleColor.withValues(alpha: 0.8)],
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
                      onPressed: auth.isLoading ? null : _register,
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
                              'Create Account',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (_selectedRole == 'citizen') ...[
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.divider)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or sign up with',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Consumer<AuthProvider>(
                        builder: (ctx, auth, _) => OutlinedButton.icon(
                          icon: const Icon(
                            Icons.g_mobiledata,
                            size: 28,
                            color: Colors.blueAccent,
                          ),
                          label: const Text(
                            'Google',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: AppColors.divider),
                          ),
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  try {
                                    await auth.signInWithGoogle();
                                    if (!ctx.mounted) return;
                                    if (auth.isAuthenticated) {
                                      Navigator.of(
                                        context,
                                      ).pop(); // Back to home which handles autologin
                                    }
                                  } catch (e) {
                                    if (!ctx.mounted) return;
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e.toString().replaceAll(
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
                        builder: (ctx, auth, _) => OutlinedButton.icon(
                          icon: const Icon(
                            Icons.apple,
                            size: 24,
                            color: Colors.black87,
                          ),
                          label: const Text(
                            'Apple',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: AppColors.divider),
                          ),
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  try {
                                    await auth.signInWithApple();
                                    if (!ctx.mounted) return;
                                    if (auth.isAuthenticated) {
                                      Navigator.of(context).pop();
                                    }
                                  } catch (e) {
                                    if (!ctx.mounted) return;
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e.toString().replaceAll(
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
                const SizedBox(height: 16),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType? type,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
