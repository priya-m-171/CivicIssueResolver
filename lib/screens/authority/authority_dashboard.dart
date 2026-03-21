import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../../providers/auth_provider.dart';
import '../../providers/issue_provider.dart';
import '../../providers/notification_provider.dart';
import '../../config/app_constants.dart';
import '../../models/issue_model.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/mini_chart.dart';
import '../dashboard/issue_detail_screen.dart';
import '../shared/notifications_screen.dart';
import '../profile/profile_screen.dart';
import 'authority_analytics_screen.dart';
import '../dashboard/map_view.dart';
import '../../widgets/responsive_wrapper.dart';
import '../../utils/translations.dart';

class AuthorityDashboard extends StatefulWidget {
  const AuthorityDashboard({super.key});

  @override
  State<AuthorityDashboard> createState() => _AuthorityDashboardState();
}

class _AuthorityDashboardState extends State<AuthorityDashboard> {
  int _currentTab = 0;
  String _filter = 'all';

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
    final auth = Provider.of<AuthProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);
    final unread = notifProvider.unreadCount(
      auth.user?.role ?? 'authority',
      auth.user?.id ?? '',
    );

    return Scaffold(
      body: ResponsiveWrapper(
        child: IndexedStack(
          index: _currentTab,
          children: [
            _AuthorityOverview(
              filter: _filter,
              onFilterChanged: (f) => setState(() {
                _filter = f;
                _currentTab = 1;
              }),
            ),
            _AuthorityComplaintsList(filter: _filter),
            const IssueMapView(),
            const AuthorityAnalyticsScreen(),
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
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: 'All Complaints'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: 'Map'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: 'Analytics'.tr(context),
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
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

class _AuthorityOverview extends StatelessWidget {
  final String filter;
  final Function(String) onFilterChanged;
  const _AuthorityOverview({
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final issueProvider = Provider.of<IssueProvider>(context);
    final issues = issueProvider.issues;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 140,
          pinned: true,
          backgroundColor: AppColors.authorityColor,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.authorityColor, Color(0xFF9F67FF)],
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
                    'Authority Dashboard'.tr(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Manage & verify community complaints'.tr(context),
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
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Total',
                      value: '${issueProvider.totalIssues}',
                      icon: Icons.assignment_outlined,
                      color: AppColors.authorityColor,
                      onTap: () => onFilterChanged('all'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Pending',
                      value: '${issueProvider.pendingCount}',
                      icon: Icons.hourglass_empty,
                      color: AppColors.warning,
                      onTap: () => onFilterChanged('pending'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Assigned',
                      value: '${issueProvider.assignedCount}',
                      icon: Icons.assignment_ind_outlined,
                      color: AppColors.info,
                      onTap: () => onFilterChanged('acknowledged'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Resolved',
                      value: '${issueProvider.resolvedCount}',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                      onTap: () => onFilterChanged('completed'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weekly trend
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Complaint Volume (Weekly)',
                            style: AppTextStyles.heading3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${issueProvider.resolutionRate.toStringAsFixed(0)}% resolved',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    MiniBarChart(
                      data: issueProvider.weeklyTrend
                          .map((e) => e.toDouble())
                          .toList(),
                      color: AppColors.authorityColor,
                      height: 80,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Status breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Breakdown'.tr(context),
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 12),
                    ...issueProvider.statusBreakdown.entries.map((e) {
                      final pct = issueProvider.totalIssues > 0
                          ? e.value / issueProvider.totalIssues
                          : 0.0;
                      final color = e.key == 'Pending'
                          ? AppColors.warning
                          : e.key == 'In Progress'
                          ? AppColors.info
                          : e.key == 'Completed'
                          ? AppColors.success
                          : AppColors.authorityColor;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                e.key,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor: color.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation(color),
                                  minHeight: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${e.value}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Recent pending
              Text('Pending Review'.tr(context), style: AppTextStyles.heading3),
              const SizedBox(height: 10),
              ...issues
                  .where((i) => i.status == 'pending')
                  .take(3)
                  .map((issue) => _AuthorityIssueCard(issue: issue)),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }
}

class _AuthorityComplaintsList extends StatefulWidget {
  final String filter;
  const _AuthorityComplaintsList({required this.filter});

  @override
  State<_AuthorityComplaintsList> createState() =>
      _AuthorityComplaintsListState();
}

class _AuthorityComplaintsListState extends State<_AuthorityComplaintsList> {
  String _statusFilter = 'all';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final issueProvider = Provider.of<IssueProvider>(context);
    var filtered = _statusFilter == 'all'
        ? issueProvider.issues
        : issueProvider.issues.where((i) => i.status == _statusFilter).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (i) =>
                i.title.toLowerCase().contains(q) ||
                i.ticketNumber.toLowerCase().contains(q) ||
                i.category.toLowerCase().contains(q) ||
                i.submittedBy.toLowerCase().contains(q),
          )
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('All Complaints'.tr(context)),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by title, ticket, category...'.tr(context),
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    value: 'all',
                    selected: _statusFilter,
                    onTap: (v) => setState(() => _statusFilter = v),
                  ),
                  _FilterChip(
                    label: 'Pending',
                    value: 'pending',
                    selected: _statusFilter,
                    onTap: (v) => setState(() => _statusFilter = v),
                    color: AppColors.warning,
                  ),
                  _FilterChip(
                    label: 'Acknowledged',
                    value: 'acknowledged',
                    selected: _statusFilter,
                    onTap: (v) => setState(() => _statusFilter = v),
                    color: AppColors.info,
                  ),
                  _FilterChip(
                    label: 'In Progress',
                    value: 'work_started',
                    selected: _statusFilter,
                    onTap: (v) => setState(() => _statusFilter = v),
                    color: AppColors.authorityColor,
                  ),
                  _FilterChip(
                    label: 'Completed',
                    value: 'completed',
                    selected: _statusFilter,
                    onTap: (v) => setState(() => _statusFilter = v),
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No complaints found'.tr(context),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) =>
                        _AuthorityIssueCard(issue: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, value, selected;
  final Function(String) onTap;
  final Color color;
  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    this.color = AppColors.authorityColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorityIssueCard extends StatelessWidget {
  final Issue issue;
  const _AuthorityIssueCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    final issueProvider = Provider.of<IssueProvider>(context, listen: false);
    final notifProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${issue.ticketNumber} • ${_daysAgo(issue.createdAt)} • ${issue.address}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.statusColor(
                          issue.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppConstants.statusLabel(issue.status),
                        style: TextStyle(
                          color: AppConstants.statusColor(issue.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.priorityColor(
                          issue.priority,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag,
                            size: 10,
                            color: AppConstants.priorityColor(issue.priority),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            issue.priority.toUpperCase(),
                            style: TextStyle(
                              color: AppConstants.priorityColor(issue.priority),
                              fontSize: 9,
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
            const SizedBox(height: 8),
            Text(
              issue.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  AppConstants.categoryIcon(issue.category),
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  issue.category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.person_outline,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'By: ${issue.submittedBy}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.visibility_outlined, size: 14),
                    label: const Text('View', style: TextStyle(fontSize: 12)),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IssueDetailScreen(issue: issue),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (issue.status == 'pending') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.verified_outlined, size: 14),
                      label: const Text(
                        'Verify',
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () async {
                        await issueProvider.updateStatus(
                          issue.id,
                          'acknowledged',
                          onNotify: notifProvider.addNotification,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Issue verified & acknowledged'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
                if (issue.status == 'acknowledged') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.assignment_ind_outlined, size: 14),
                      label: const Text(
                        'Assign',
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _showAssignDialog(
                        context,
                        issue,
                        issueProvider,
                        notifProvider,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
                if (issue.status == 'work_started') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.close, size: 14),
                      label: const Text(
                        'Close',
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () async {
                        await issueProvider.updateStatus(
                          issue.id,
                          'closed',
                          onNotify: notifProvider.addNotification,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(
    BuildContext context,
    Issue issue,
    IssueProvider issueProvider,
    NotificationProvider notifProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AssignWorkerSheet(
        issue: issue,
        issueProvider: issueProvider,
        notifProvider: notifProvider,
      ),
    );
  }

  String _daysAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt).inDays;
    return diff == 0 ? 'Today' : '${diff}d ago';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Assign Worker Sheet with e-Signature
// ─────────────────────────────────────────────────────────────────────────────
class _AssignWorkerSheet extends StatefulWidget {
  final Issue issue;
  final IssueProvider issueProvider;
  final NotificationProvider notifProvider;

  const _AssignWorkerSheet({
    required this.issue,
    required this.issueProvider,
    required this.notifProvider,
  });

  @override
  State<_AssignWorkerSheet> createState() => _AssignWorkerSheetState();
}

class _AssignWorkerSheetState extends State<_AssignWorkerSheet> {
  List<Map<String, dynamic>> _workers = [];
  bool _loadingWorkers = true;

  Map<String, dynamic>? _selectedWorker;
  bool _showSignature = false;
  bool _isSubmitting = false;
  late final SignatureController _sigController;

  @override
  void initState() {
    super.initState();
    _sigController = SignatureController(
      penStrokeWidth: 2.5,
      penColor: AppColors.authorityColor,
      exportBackgroundColor: Colors.white,
    );
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    final ip = Provider.of<IssueProvider>(context, listen: false);
    final workers = await ip.fetchWorkers();
    if (mounted) {
      setState(() {
        _workers = workers;
        _loadingWorkers = false;
      });
    }
  }

  @override
  void dispose() {
    _sigController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.authorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment_ind_outlined,
                    color: AppColors.authorityColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assign Field Worker',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.issue.ticketNumber,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            if (!_showSignature) ...[
              // Step 1: worker selection
              const Text(
                'Select a worker',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 10),
              if (_loadingWorkers)
                const Center(child: CircularProgressIndicator())
              else if (_workers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No workers registered yet. Workers must register with the "Field Worker" role.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._workers.map((w) {
                  final isSelected = _selectedWorker?['id'] == w['id'];
                  final category =
                      w['worker_category'] as String? ?? 'General Field Work';
                  return GestureDetector(
                    onTap: () => setState(() => _selectedWorker = w),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.authorityColor.withValues(alpha: 0.05)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.authorityColor
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isSelected
                                ? AppColors.authorityColor
                                : AppColors.workerColor.withValues(alpha: 0.15),
                            child: Text(
                              (w['name'] as String)[0],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.workerColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  w['name'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  category,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.authorityColor,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _selectedWorker == null
                      ? null
                      : () => setState(() => _showSignature = true),
                  icon: const Icon(Icons.draw_outlined, size: 18),
                  label: const Text('Continue to Sign'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.authorityColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Step 2: e-signature
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _showSignature = false),
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Authority Authorization',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Assigning to: ${_selectedWorker!['name']}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.authorityColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.authorityColor.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.authorityColor,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sign below to authorize this work assignment',
                        style: TextStyle(
                          color: AppColors.authorityColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Authorized Signature',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.authorityColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Signature(
                    controller: _sigController,
                    height: 140,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _sigController.clear(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (_sigController.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please provide your signature'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                            return;
                          }
                          setState(() => _isSubmitting = true);
                          final sigData = await _sigController.toPngBytes();
                          final sigString = sigData != null
                              ? 'authority_sig_${DateTime.now().millisecondsSinceEpoch}'
                              : null;
                          // Save signature then assign
                          await widget.issueProvider.updateProofAndSignature(
                            widget.issue.id,
                            eSignatureData: sigString,
                          );
                          await widget.issueProvider.updateStatus(
                            widget.issue.id,
                            'assigned',
                            workerId: _selectedWorker!['id'] as String,
                            workerName: _selectedWorker!['name'] as String,
                            onNotify: widget.notifProvider.addNotification,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Assigned to ${_selectedWorker!["name"]} with authorization',
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 18,
                        ),
                  label: const Text('Authorize & Assign'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.authorityColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
