import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchQuery = '';
  String _filterRole = 'All';

  List<_DemoUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final res = await SupabaseService.client.from('profiles').select();
      final loaded = (res as List).map((row) {
        return _DemoUser(
          id: row['id'] ?? '',
          name: row['name'] ?? 'Unknown User',
          email: row['email'] ?? 'No Email Provided',
          role: row['role'] ?? 'citizen',
          department: row['worker_category'] ?? row['department'],
          active: true, // Assuming true unless explicitly tracked.
        );
      }).toList();

      if (mounted) {
        setState(() {
          _users = loaded;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading users: $e')));
      }
    }
  }

  List<_DemoUser> get _filtered {
    return _users.where((u) {
      final matchRole =
          _filterRole == 'All' || u.role == _filterRole.toLowerCase();
      final matchSearch =
          _searchQuery.isEmpty ||
          u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchRole && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'User Directory',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.adminColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                '${_users.length} Active',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              labelStyle: const TextStyle(color: AppColors.adminColor),
              side: BorderSide.none,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchFilterBar(
            query: _searchQuery,
            filterRole: _filterRole,
            onSearch: (v) => setState(() => _searchQuery = v),
            onFilter: (v) => setState(() => _filterRole = v),
          ),
          _RoleStatsRow(users: _users),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No users found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _UserCard(
                      user: filtered[i],
                      isSelf: filtered[i].id == auth.user?.id,
                      onToggleActive: (u) {
                        setState(() {
                          final idx = _users.indexWhere((x) => x.id == u.id);
                          if (idx >= 0) {
                            _users[idx] = _DemoUser(
                              id: u.id,
                              name: u.name,
                              email: u.email,
                              role: u.role,
                              department: u.department,
                              active: !u.active,
                            );
                          }
                        });
                      },
                      onChangeRole: (u, newRole) {
                        setState(() {
                          final idx = _users.indexWhere((x) => x.id == u.id);
                          if (idx >= 0) {
                            _users[idx] = _DemoUser(
                              id: u.id,
                              name: u.name,
                              email: u.email,
                              role: newRole,
                              department: u.department,
                              active: u.active,
                            );
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${u.name} role changed to $newRole'),
                            backgroundColor: AppColors.adminColor,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Search + filter bar ───────────────────────────────────────────────────────

class _SearchFilterBar extends StatelessWidget {
  final String query, filterRole;
  final ValueChanged<String> onSearch, onFilter;
  const _SearchFilterBar({
    required this.query,
    required this.filterRole,
    required this.onSearch,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    const roles = ['All', 'Citizen', 'Authority', 'Worker', 'Admin'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Search by name or email…',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: roles.map((r) {
                final selected = filterRole == r;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onFilter(r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.adminColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.adminColor
                              : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        r,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role stats ────────────────────────────────────────────────────────────────

class _RoleStatsRow extends StatelessWidget {
  final List<_DemoUser> users;
  const _RoleStatsRow({required this.users});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        'Citizens',
        users.where((u) => u.role == 'citizen').length,
        AppColors.citizenColor,
      ),
      (
        'Authority',
        users.where((u) => u.role == 'authority').length,
        AppColors.authorityColor,
      ),
      (
        'Workers',
        users.where((u) => u.role == 'worker').length,
        AppColors.workerColor,
      ),
      (
        'Admins',
        users.where((u) => u.role == 'admin').length,
        AppColors.adminColor,
      ),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: s.$3.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    '${s.$2}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: s.$3,
                    ),
                  ),
                  Text(
                    s.$1,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── User card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final _DemoUser user;
  final bool isSelf;
  final ValueChanged<_DemoUser> onToggleActive;
  final void Function(_DemoUser, String) onChangeRole;
  const _UserCard({
    required this.user,
    required this.isSelf,
    required this.onToggleActive,
    required this.onChangeRole,
  });

  Color get _roleColor {
    switch (user.role) {
      case 'authority':
        return AppColors.authorityColor;
      case 'worker':
        return AppColors.workerColor;
      case 'admin':
        return AppColors.adminColor;
      default:
        return AppColors.citizenColor;
    }
  }

  IconData get _roleIcon {
    switch (user.role) {
      case 'authority':
        return Icons.admin_panel_settings_outlined;
      case 'worker':
        return Icons.engineering_outlined;
      case 'admin':
        return Icons.manage_accounts_outlined;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _roleColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_roleIcon, color: _roleColor),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelf) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.adminColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.adminColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.department != null)
                    Text(
                      user.department!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _RoleBadge(role: user.role, color: _roleColor),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: user.active
                              ? AppColors.success.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.active ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 10,
                            color: user.active
                                ? AppColors.success
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            if (!isSelf)
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (val) {
                  if (val == 'toggle') {
                    onToggleActive(user);
                  } else {
                    onChangeRole(user, val);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          user.active
                              ? Icons.block
                              : Icons.check_circle_outline,
                          size: 16,
                          color: user.active
                              ? AppColors.danger
                              : AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(user.active ? 'Deactivate' : 'Activate'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    enabled: false,
                    child: Text(
                      'Change role',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ...[
                    'citizen',
                    'authority',
                    'worker',
                    'admin',
                  ].where((r) => r != user.role).map((r) {
                    return PopupMenuItem(
                      value: r,
                      child: Row(
                        children: [
                          const Icon(Icons.swap_horiz, size: 14),
                          const SizedBox(width: 8),
                          Text('Set as ${r[0].toUpperCase()}${r.substring(1)}'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  final Color color;
  const _RoleBadge({required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role[0].toUpperCase() + role.substring(1),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────

class _DemoUser {
  final String id, name, email, role;
  final String? department;
  final bool active;
  const _DemoUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    required this.active,
  });
}
