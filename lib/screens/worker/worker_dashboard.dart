import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../providers/issue_provider.dart';
import '../../providers/notification_provider.dart';
import '../../config/app_constants.dart';
import '../../models/issue_model.dart';
import '../../widgets/stat_card.dart';
import '../shared/notifications_screen.dart';
import '../profile/profile_screen.dart';
import 'worker_task_detail.dart';
import 'package:url_launcher/url_launcher.dart';
import '../dashboard/map_view.dart';
import '../../widgets/responsive_wrapper.dart';
import '../../utils/translations.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
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
    final auth = Provider.of<AuthProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);
    final unread = notifProvider.unreadCount(
      auth.user?.role ?? 'worker',
      auth.user?.id ?? '',
    );

    return Scaffold(
      body: ResponsiveWrapper(
        child: IndexedStack(
          index: _currentTab,
          children: [
            _WorkerOverview(
              onTabSelected: (i) => setState(() => _currentTab = i),
            ),
            const _WorkerTaskList(),
            const _WorkerHistoryList(),
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
            icon: const Icon(Icons.task_outlined),
            selectedIcon: const Icon(Icons.task),
            label: 'Tasks'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: 'History'.tr(context),
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
    );
  }
}

class _WorkerOverview extends StatelessWidget {
  final Function(int) onTabSelected;
  const _WorkerOverview({required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final issueProvider = Provider.of<IssueProvider>(context);
    final myTasks = issueProvider.issuesByWorker(auth.user?.id ?? 'w1');
    final active = myTasks.where((i) => i.status == 'work_started').length;
    final done = myTasks
        .where((i) => i.status == 'completed' || i.status == 'closed')
        .length;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 140,
          pinned: true,
          backgroundColor: AppColors.workerColor,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.workerColor, Color(0xFFEA2E0C)],
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
                    '${_getGreeting()}, ${Provider.of<AuthProvider>(context).user?.name.split(' ').first ?? 'Worker'}! 👷',
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
                    'Manage your assigned tasks & tracks progress'.tr(context),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'New Tasks',
                      value:
                          '${myTasks.where((i) => i.status == 'assigned').length}',
                      icon: Icons.assignment_outlined,
                      color: AppColors.workerColor,
                      onTap: () => onTabSelected(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Active',
                      value: '$active',
                      icon: Icons.pending_actions,
                      color: AppColors.warning,
                      onTap: () => onTabSelected(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Completed',
                      value: '$done',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                      onTap: () => onTabSelected(2), // History tab
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Performance
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
                      'My Performance'.tr(context),
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _PerfMetric(
                            'Tasks Done',
                            '$done',
                            Icons.check_circle_outline,
                            AppColors.success,
                          ),
                        ),
                        Expanded(
                          child: _PerfMetric(
                            'In Progress',
                            '$active',
                            Icons.timer_outlined,
                            AppColors.info,
                          ),
                        ),
                        Expanded(
                          child: _PerfMetric(
                            'Total',
                            '${myTasks.length}',
                            Icons.assignment_outlined,
                            AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Completion Progress'.tr(context),
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: myTasks.isEmpty ? 0 : done / myTasks.length,
                        minHeight: 10,
                        backgroundColor: AppColors.workerColor.withValues(
                          alpha: 0.1,
                        ),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.workerColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${((myTasks.isEmpty ? 0 : done / myTasks.length) * 100).toInt()}% of assigned tasks resolved',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Active tasks
              Text('Active Tasks'.tr(context), style: AppTextStyles.heading3),
              const SizedBox(height: 10),
              ...myTasks
                  .where((i) => i.status == 'work_started')
                  .take(3)
                  .map((t) => _WorkerTaskCard(issue: t, showActions: true)),
              if (myTasks.where((i) => i.status == 'work_started').isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No active tasks right now'.tr(context),
                      style: const TextStyle(color: Colors.grey),
                    ),
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

class _PerfMetric extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _PerfMetric(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _WorkerTaskList extends StatelessWidget {
  const _WorkerTaskList();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final issueProvider = Provider.of<IssueProvider>(context);
    final myTasks = issueProvider.issuesByWorker(auth.user?.id ?? 'w1');

    final newTasks = myTasks.where((i) => i.status == 'assigned').toList();
    final startedTasks = myTasks
        .where((i) => i.status == 'work_started')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tasks & Assignments',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body:
          myTasks
              .where(
                (i) => i.status == 'assigned' || i.status == 'work_started',
              )
              .isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No tasks assigned yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (newTasks.isNotEmpty) ...[
                  const Text('New Assignments', style: AppTextStyles.heading3),
                  const SizedBox(height: 10),
                  ...newTasks.map(
                    (t) => _WorkerTaskCard(issue: t, showActions: true),
                  ),
                  const SizedBox(height: 20),
                ],
                if (startedTasks.isNotEmpty) ...[
                  const Text('Active Tasks', style: AppTextStyles.heading3),
                  const SizedBox(height: 10),
                  ...startedTasks.map(
                    (t) => _WorkerTaskCard(issue: t, showActions: true),
                  ),
                ],
              ],
            ),
    );
  }
}

class _WorkerHistoryList extends StatelessWidget {
  const _WorkerHistoryList();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final issueProvider = Provider.of<IssueProvider>(context);
    final history = issueProvider
        .issuesByWorker(auth.user?.id ?? 'w1')
        .where((i) => i.status == 'completed' || i.status == 'closed')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
        backgroundColor: Colors.white,
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'No completed tasks yet',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (ctx, i) =>
                  _WorkerTaskCard(issue: history[i], showActions: false),
            ),
    );
  }
}

class _WorkerTaskCard extends StatelessWidget {
  final Issue issue;
  final bool showActions;
  const _WorkerTaskCard({required this.issue, required this.showActions});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.workerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    AppConstants.categoryIcon(issue.category),
                    color: AppColors.workerColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        issue.ticketNumber,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.priorityColor(
                      issue.priority,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    issue.priority.toUpperCase(),
                    style: TextStyle(
                      color: AppConstants.priorityColor(issue.priority),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    issue.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              issue.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkerTaskDetail(issue: issue),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Details'.tr(context),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (issue.status == 'assigned')
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow, size: 16),
                        label: Text('Start Work'.tr(context)),
                        onPressed: () async {
                          final ip = Provider.of<IssueProvider>(
                            context,
                            listen: false,
                          );
                          final np = Provider.of<NotificationProvider>(
                            context,
                            listen: false,
                          );
                          await ip.updateStatus(
                            issue.id,
                            'work_started',
                            onNotify: np.addNotification,
                          );
                          final url = Uri.parse(
                            'https://www.google.com/maps/dir/?api=1&destination=${issue.latitude},${issue.longitude}',
                          );
                          try {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (e) {
                            debugPrint('Could not launch maps: $url');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.workerColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                  else if (issue.status == 'work_started')
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check, size: 16),
                        label: Text('Complete'.tr(context)),
                        onPressed: () => _showCompletionDialog(context, issue),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            if (!showActions && issue.eSignatureData != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 12,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'E-Signature Submitted'.tr(context),
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, Issue issue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WorkCompletionSheet(issue: issue),
    );
  }
}

class _WorkCompletionSheet extends StatefulWidget {
  final Issue issue;
  const _WorkCompletionSheet({required this.issue});

  @override
  State<_WorkCompletionSheet> createState() => _WorkCompletionSheetState();
}

class _WorkCompletionSheetState extends State<_WorkCompletionSheet> {
  late final SignatureController _signCtrl;
  bool _signed = false;
  bool _submitting = false;
  String? _errorMessage;
  final _notesController = TextEditingController();
  XFile? _proofImage;

  @override
  void initState() {
    super.initState();
    _signCtrl = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _signCtrl.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickProofImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null && mounted) {
      setState(() => _proofImage = file);
    }
  }

  Future<void> _submitCompletion() async {
    setState(() => _errorMessage = null);

    if (_notesController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please provide completion notes');
      return;
    }
    if (_proofImage == null) {
      setState(() => _errorMessage = 'Please upload a proof image');
      return;
    }
    if (!_signed || _signCtrl.isEmpty) {
      setState(
        () => _errorMessage =
            'Please provide your e-signature to confirm completion',
      );
      return;
    }
    final issueProvider = Provider.of<IssueProvider>(context, listen: false);
    final notifProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    setState(() => _submitting = true);
    try {
      final signBytes = await _signCtrl.toPngBytes();
      final signBase64 = base64Encode(signBytes!);

      await issueProvider.updateProofAndSignature(
        widget.issue.id,
        proofImageFile: _proofImage,
        eSignatureData: signBase64,
        resolutionNotes: _notesController.text.trim(),
      );
      await issueProvider.updateStatus(
        widget.issue.id,
        'completed',
        onNotify: notifProvider.addNotification,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Task marked as completed with e-signature!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to complete task: $e');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      builder: (ctx, scroll) => SingleChildScrollView(
        controller: scroll,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Complete Task', style: AppTextStyles.heading2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.workerColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.issue.ticketNumber,
                      style: TextStyle(
                        color: AppColors.workerColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Provide completion notes and sign to confirm task done',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 20),

              const Text('Completion Notes', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe the work done, materials used, etc.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Proof Image *', style: AppTextStyles.label),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickProofImage,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 120,
                    maxHeight: 350,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _proofImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.grey,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Capture Proof Image',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(
                                  _proofImage!.path,
                                  fit: BoxFit.contain,
                                  cacheWidth: 800,
                                )
                              : Image.file(
                                  File(_proofImage!.path),
                                  fit: BoxFit.contain,
                                  cacheWidth: 800,
                                ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'E-Signature Required',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      _signCtrl.clear();
                      setState(() => _signed = false);
                    },
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Sign in the box below to confirm task completion',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _signed ? AppColors.success : AppColors.primary,
                    width: _signed ? 2 : 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Signature(
                    controller: _signCtrl,
                    height: 160,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _signed = _signCtrl.isNotEmpty),
                child: Row(
                  children: [
                    if (!_signed)
                      const Text(
                        'Draw your signature above then tap to confirm',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      )
                    else
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Signature captured',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              ListenableBuilder(
                listenable: _signCtrl,
                builder: (_, _) {
                  final hasSign = _signCtrl.isNotEmpty;
                  if (hasSign && !_signed) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _signed = true);
                    });
                  }
                  return const SizedBox.shrink();
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submitCompletion,
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.verified_outlined),
                  label: Text(
                    _submitting
                        ? 'Submitting...'
                        : 'Confirm Completion with E-Signature',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
