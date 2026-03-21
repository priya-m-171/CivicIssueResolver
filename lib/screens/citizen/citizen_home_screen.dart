import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/issue_provider.dart';
import '../../providers/notification_provider.dart';
import '../../config/app_constants.dart';
import '../../models/issue_model.dart';
import '../dashboard/map_view.dart';
import '../dashboard/issue_detail_screen.dart';
import '../report/report_issue_screen.dart';
import '../shared/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/mini_chart.dart';
import '../../utils/translations.dart';
import '../../widgets/responsive_wrapper.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  int _currentTab = 0;

  void _navigateToTab(int index) {
    setState(() => _currentTab = index);
  }

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
    final notifications = Provider.of<NotificationProvider>(context);
    final unread = notifications.unreadCount(
      auth.user?.role ?? 'citizen',
      auth.user?.id ?? '',
    );
    return Scaffold(
      body: ResponsiveWrapper(
        child: IndexedStack(
          index: _currentTab,
          children: [
            _CitizenDashboard(onViewAll: () => _navigateToTab(1)),
            const _CitizenIssuesTab(),
            IssueMapView(),
            NotificationsScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        backgroundColor: Colors.white,
        elevation: 8,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: 'Overview'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: 'My Issues'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: 'Map'.tr(context),
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
      floatingActionButton: _currentTab <= 2
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
              ),
              icon: const Icon(Icons.add),
              label: Text('Report Issue'.tr(context)),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}

class _CitizenDashboard extends StatelessWidget {
  final VoidCallback onViewAll;
  const _CitizenDashboard({required this.onViewAll});

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning'.tr(context);
    if (hour < 17) return 'Good Afternoon'.tr(context);
    return 'Good Evening'.tr(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final issueProvider = Provider.of<IssueProvider>(context);
    final myIssues = issueProvider.issuesByUser(auth.user?.id ?? 'c1');

    final myPending = myIssues.where((i) => i.status == 'pending').length;

    final myCompleted = myIssues
        .where((i) => i.status == 'completed' || i.status == 'closed')
        .length;

    return RefreshIndicator(
      onRefresh: () =>
          Provider.of<IssueProvider>(context, listen: false).fetchIssues(),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.citizenColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.citizenColor, Color(0xFF4A7EFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${_getGreeting(context)}, ${auth.user?.name.split(' ').first ?? 'Citizen'.tr(context)}! 👋',
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
                      'Track & report civic issues in your area'.tr(context),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Consumer<NotificationProvider>(
                builder: (ctx, notif, _) {
                  final unread = notif.unreadCount(
                    auth.user?.role ?? 'citizen',
                    auth.user?.id ?? '',
                  );
                  return IconButton(
                    icon: Badge(
                      isLabelVisible: unread > 0,
                      label: Text('$unread'),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // My stats
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'My Reports'.tr(context),
                        value: '${myIssues.length}',
                        icon: Icons.assignment_outlined,
                        color: AppColors.citizenColor,
                        onTap: onViewAll,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Pending'.tr(context),
                        value: '$myPending',
                        icon: Icons.hourglass_empty,
                        color: AppColors.warning,
                        onTap: onViewAll,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Resolved'.tr(context),
                        value: '$myCompleted',
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                        onTap: onViewAll,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // City-wide stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.citizenColor.withValues(alpha: 0.05),
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.citizenColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'City Overview'.tr(context),
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _miniStat(
                              'Total'.tr(context),
                              '${issueProvider.totalIssues}',
                              AppColors.citizenColor,
                            ),
                          ),
                          Expanded(
                            child: _miniStat(
                              'In Progress'.tr(context),
                              '${issueProvider.inProgressIssues.length}',
                              AppColors.warning,
                            ),
                          ),
                          Expanded(
                            child: _miniStat(
                              'Resolved'.tr(context),
                              '${issueProvider.resolvedCount}',
                              AppColors.success,
                            ),
                          ),
                          Expanded(
                            child: _miniStat(
                              'Rate'.tr(context),
                              '${issueProvider.resolutionRate.toStringAsFixed(0)}%',
                              AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Monthly Trend (issues submitted)'.tr(context),
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 8),
                      MiniBarChart(
                        data: issueProvider.weeklyTrend
                            .map((e) => e.toDouble())
                            .toList(),
                        color: AppColors.citizenColor,
                        height: 70,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Category breakdown
                Text(
                  'Issues by Category'.tr(context),
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 10),
                _CategoryBreakdown(breakdown: issueProvider.categoryBreakdown),
                const SizedBox(height: 16),

                // Recent Issues
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'My Recent Reports'.tr(context),
                        style: AppTextStyles.heading3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: onViewAll,
                      child: Text(
                        'View All'.tr(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (myIssues.isEmpty)
                  _EmptyState()
                else
                  ...myIssues.take(3).map((issue) => _IssueCard(issue: issue)),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return InkWell(
      onTap: onViewAll,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final Map<String, int> breakdown;
  const _CategoryBreakdown({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) return const SizedBox.shrink();
    final total = breakdown.values.fold(0, (a, b) => a + b);
    final colors = [
      AppColors.citizenColor,
      AppColors.warning,
      AppColors.success,
      AppColors.danger,
      AppColors.secondary,
    ];
    final entries = breakdown.entries.toList();

    return Column(
      children: entries.take(5).toList().asMap().entries.map((entry) {
        final i = entry.key;
        final cat = entry.value;
        final pct = total > 0 ? cat.value / total : 0.0;
        final color = colors[i % colors.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(AppConstants.categoryIcon(cat.key), size: 14, color: color),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(
                  cat.key.tr(context),
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
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${cat.value}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CitizenIssuesTab extends StatefulWidget {
  const _CitizenIssuesTab();

  @override
  State<_CitizenIssuesTab> createState() => _CitizenIssuesTabState();
}

class _CitizenIssuesTabState extends State<_CitizenIssuesTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final issueProvider = Provider.of<IssueProvider>(context);
    var myIssues = issueProvider.issuesByUser(auth.user?.id ?? 'c1');

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      myIssues = myIssues
          .where(
            (i) =>
                i.title.toLowerCase().contains(q) ||
                i.ticketNumber.toLowerCase().contains(q) ||
                i.category.toLowerCase().contains(q),
          )
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Reports'.tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search your reports...'.tr(context),
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
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: myIssues.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.assignment_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No results for "$_searchQuery"'.tr(context)
                              : 'No issues reported yet'.tr(context),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try searching with different keywords'.tr(
                                  context,
                                )
                              : 'Tap the + button to report your first issue'
                                    .tr(context),
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: myIssues.length,
                    itemBuilder: (ctx, i) => _IssueCard(issue: myIssues[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final Issue issue;
  const _IssueCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => IssueDetailScreen(issue: issue)),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      AppConstants.categoryIcon(issue.category) ==
                          Icons.report_problem
                      ? Colors.orange.withValues(alpha: 0.1)
                      : AppColors.citizenColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppConstants.categoryIcon(issue.category),
                  color: AppColors.citizenColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      issue.ticketNumber,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            issue.address,
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
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                      AppConstants.statusLabel(issue.status).tr(context),
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
                    child: Text(
                      issue.priority.toUpperCase().tr(context),
                      style: TextStyle(
                        color: AppConstants.priorityColor(issue.priority),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No issues reported yet'.tr(context),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "Report Issue" to submit your first complaint'.tr(context),
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
