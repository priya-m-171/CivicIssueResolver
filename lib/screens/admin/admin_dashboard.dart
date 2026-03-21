import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/issue_provider.dart';
import '../../providers/notification_provider.dart';
import '../../config/app_constants.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/mini_chart.dart';
import '../shared/notifications_screen.dart';
import '../profile/profile_screen.dart';
import 'user_management_screen.dart';
import 'admin_qna_screen.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../dashboard/map_view.dart';
import '../../widgets/responsive_wrapper.dart';
import '../../utils/translations.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IssueProvider>(context, listen: false).fetchIssues();
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveWrapper(
        child: IndexedStack(
          index: _currentTab,
          children: [
            const _AdminOverview(),
            const UserManagementScreen(),
            const _AdminSystemTab(),
            const AdminQnaScreen(),
            const IssueMapView(),
            const NotificationsScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        backgroundColor: Colors.white,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: 'Overview'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outlined),
            selectedIcon: const Icon(Icons.people),
            label: 'Users'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: const Icon(Icons.admin_panel_settings),
            label: 'System'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.mail_outline),
            selectedIcon: const Icon(Icons.mail),
            label: 'Q&A'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: 'Map'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications),
            label: 'Alerts'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outlined),
            selectedIcon: const Icon(Icons.person),
            label: 'Profile'.tr(context),
          ),
        ],
      ),
    );
  }
}

class _AdminOverview extends StatelessWidget {
  const _AdminOverview();

  @override
  Widget build(BuildContext context) {
    final issueProvider = Provider.of<IssueProvider>(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          backgroundColor: AppColors.adminColor,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.adminColor, Color(0xFF065F46)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${_getGreeting()}, Admin! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'System monitoring & oversight in real-time',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => Provider.of<IssueProvider>(
                context,
                listen: false,
              ).fetchIssues(),
            ),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Key metrics
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Total Issues',
                      value: '${issueProvider.totalIssues}',
                      icon: Icons.assignment_outlined,
                      color: AppColors.adminColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Resolution %',
                      value:
                          '${issueProvider.resolutionRate.toStringAsFixed(0)}%',
                      icon: Icons.trending_up,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Weekly trend chart
              _AdminChartCard(
                title: 'Issue Volume (Weekly Trend)',
                child: MiniBarChart(
                  data: issueProvider.weeklyTrend
                      .map((e) => e.toDouble())
                      .toList(),
                  color: AppColors.adminColor,
                  height: 90,
                ),
              ),
              const SizedBox(height: 16),

              // Status distribution
              _AdminChartCard(
                title: 'Status Distribution',
                child: Row(
                  children: [
                    MiniDonutChart(
                      data: {
                        'Pending': issueProvider.pendingCount.toDouble(),
                        'In Progress': issueProvider.inProgressIssues.length
                            .toDouble(),
                        'Completed': issueProvider.resolvedCount.toDouble(),
                        'Acknowledged': issueProvider.acknowledgedIssues.length
                            .toDouble(),
                      },
                      colors: {
                        'Pending': AppColors.warning,
                        'In Progress': AppColors.info,
                        'Completed': AppColors.success,
                        'Acknowledged': AppColors.authorityColor,
                      },
                      size: 100,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegRow(
                            'Pending',
                            issueProvider.pendingCount,
                            AppColors.warning,
                          ),
                          _LegRow(
                            'In Progress',
                            issueProvider.inProgressIssues.length,
                            AppColors.info,
                          ),
                          _LegRow(
                            'Completed',
                            issueProvider.resolvedCount,
                            AppColors.success,
                          ),
                          _LegRow(
                            'Acknowledged',
                            issueProvider.acknowledgedIssues.length,
                            AppColors.authorityColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Category breakdown
              _AdminChartCard(
                title: 'Issues by Category',
                child: Column(
                  children: issueProvider.categoryBreakdown.entries.take(6).map(
                    (e) {
                      final pct = issueProvider.totalIssues > 0
                          ? e.value / issueProvider.totalIssues
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              AppConstants.categoryIcon(e.key),
                              size: 13,
                              color: AppColors.adminColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 3,
                              child: Text(
                                e.key,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 8,
                                  backgroundColor: AppColors.adminColor
                                      .withValues(alpha: 0.1),
                                  valueColor: const AlwaysStoppedAnimation(
                                    AppColors.adminColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${e.value}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.adminColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _LegRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _LegRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),
          Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _AdminChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ---- System Tab ----
class _AdminSystemTab extends StatelessWidget {
  const _AdminSystemTab();

  @override
  Widget build(BuildContext context) {
    final issueProvider = Provider.of<IssueProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SystemCard('Data Management', [
              _SystemTile(
                Icons.refresh,
                'Reset Demo Data',
                'Reload all seed data',
                AppColors.warning,
                () async {
                  await issueProvider.resetData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demo data reset successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),
              _SystemTile(
                Icons.download_outlined,
                'Export Report',
                'Download complaint summary',
                AppColors.info,
                () => _showPasswordExportDialog(context, issueProvider),
              ),
            ]),
            const SizedBox(height: 16),
            _SystemCard('System Stats', [
              _SystemInfoRow(
                'Total Complaints',
                '${issueProvider.totalIssues}',
              ),
              _SystemInfoRow(
                'Resolution Rate',
                '${issueProvider.resolutionRate.toStringAsFixed(1)}%',
              ),

              _SystemInfoRow('App Version', '2.0.0'),
            ]),
            const SizedBox(height: 16),
            _SystemCard('Access Control', [
              _SystemTile(
                Icons.people_outline,
                'Manage Roles',
                'Assign & update user roles',
                AppColors.authorityColor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const UserManagementScreen(),
                    ),
                  );
                },
              ),
              _SystemTile(
                Icons.lock_outline,
                'Security Settings',
                'Password & 2FA policies',
                AppColors.danger,
                () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Security Policies'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SwitchListTile(
                            title: const Text('Require 2FA for Admins'),
                            value: true,
                            onChanged: (v) {},
                          ),
                          SwitchListTile(
                            title: const Text('Enforce Strong Passwords'),
                            value: true,
                            onChanged: (v) {},
                          ),
                          SwitchListTile(
                            title: const Text('Auto-lock idle sessions'),
                            value: false,
                            onChanged: (v) {},
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SystemCard(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(title, style: AppTextStyles.heading3),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SystemTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _SystemTile(
    this.icon,
    this.title,
    this.subtitle,
    this.color,
    this.onTap,
  );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

class _SystemInfoRow extends StatelessWidget {
  final String label, value;
  const _SystemInfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

Future<void> _showPasswordExportDialog(
  BuildContext context,
  IssueProvider provider,
) async {
  final pwdCtrl = TextEditingController();
  final conf = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Admin Authorization'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter admin password to export data.'),
          const SizedBox(height: 12),
          TextField(
            controller: pwdCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, pwdCtrl.text.isNotEmpty),
          child: const Text('Export'),
        ),
      ],
    ),
  );

  if (conf == true && context.mounted) {
    try {
      final rows = <List<String>>[
        ['Ticket', 'Title', 'Category', 'Status', 'Date', 'Address'],
      ];
      for (var i in provider.issues) {
        rows.add([
          i.ticketNumber,
          i.title,
          i.category,
          i.status,
          i.createdAt.toIso8601String(),
          i.address,
        ]);
      }
      final csv = const ListToCsvConverter().convert(rows);
      final bytes = Uint8List.fromList(utf8.encode(csv));
      final xfile = XFile.fromData(
        bytes,
        name: 'civic_report.csv',
        mimeType: 'text/csv',
      );

      if (context.mounted) {
        if (kIsWeb) {
          await Share.shareXFiles([xfile], text: 'Citizen System Report');
        } else {
          try {
            final downloadsDir = await getDownloadsDirectory();
            final docsDir = await getApplicationDocumentsDirectory();
            final targetDir = downloadsDir ?? docsDir;
            final filePath =
                '${targetDir.path}/civic_report_${DateTime.now().millisecondsSinceEpoch}.csv';
            await xfile.saveTo(filePath);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Report successfully saved to: $filePath'),
                  duration: const Duration(seconds: 5),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } catch (e) {
            // Fallback to share if direct file saving fails
            if (context.mounted) {
              await Share.shareXFiles([xfile], text: 'Citizen System Report');
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export report')),
        );
      }
    }
  }
}
