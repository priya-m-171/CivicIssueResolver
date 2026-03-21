import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_constants.dart';
import '../../models/issue_model.dart';
import '../../providers/issue_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/map_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/translations.dart';

class IssueDetailScreen extends StatelessWidget {
  final Issue issue;
  const IssueDetailScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<AuthProvider>(context).role;
    final issueProvider = Provider.of<IssueProvider>(context, listen: false);
    final notifProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppConstants.statusColor(issue.status),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.statusColor(issue.status),
                          AppConstants.statusColor(
                            issue.status,
                          ).withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  issue.ticketNumber,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.priorityColor(
                                    issue.priority,
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.flag,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      issue.priority.toUpperCase().tr(context),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            issue.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            issue.category.tr(context),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status pill
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.statusColor(
                        issue.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppConstants.statusColor(
                          issue.status,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatusDot(issue.status),
                        const SizedBox(width: 8),
                        Text(
                          AppConstants.statusLabel(issue.status).tr(context),
                          style: TextStyle(
                            color: AppConstants.statusColor(issue.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Progress stepper
                _StatusProgressBar(status: issue.status),
                const SizedBox(height: 20),

                // Description
                _DetailCard(
                  'Description'.tr(context),
                  child: Text(
                    issue.description,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Attached Photos
                if (issue.imageUrls.isNotEmpty || issue.imageUrl.isNotEmpty)
                  _DetailCard(
                    'Attached Photos'.tr(context),
                    child: SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: issue.imageUrls.isNotEmpty
                            ? issue.imageUrls.length
                            : (issue.imageUrl.isNotEmpty ? 1 : 0),
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final url = issue.imageUrls.isNotEmpty
                              ? issue.imageUrls[index]
                              : issue.imageUrl;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              cacheWidth: 400,
                              errorBuilder: (_, _, _) => Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (issue.imageUrls.isNotEmpty || issue.imageUrl.isNotEmpty)
                  const SizedBox(height: 12),

                _DetailCard(
                  'Resolution Details'.tr(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (issue.resolutionNotes != null &&
                          issue.resolutionNotes!.isNotEmpty) ...[
                        Text(
                          'Worker Notes:'.tr(context),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          issue.resolutionNotes!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (issue.satisfactionRating != null) ...[
                        Row(
                          children: [
                            Text(
                              'Citizen Rating:'.tr(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index < issue.satisfactionRating!
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber.shade700,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        if (issue.feedbackText != null &&
                            issue.feedbackText!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Feedback:'.tr(context),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            issue.feedbackText!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                      if (issue.proofImageUrl != null) ...[
                        if (issue.resolutionNotes != null ||
                            issue.satisfactionRating != null)
                          const SizedBox(height: 16),
                        Text(
                          'Proof of Completion:'.tr(context),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 400),
                            child: Image.network(
                              issue.proofImageUrl!,
                              width: double.infinity,
                              fit: BoxFit
                                  .contain, // Natural aspect ratio up to 400px
                              cacheWidth: 800,
                              errorBuilder: (_, _, _) => Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey[200],
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                    Text(
                                      'Could not load proof photo',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Location & Date
                _DetailCard(
                  'Location & Date'.tr(context),
                  child: Column(
                    children: [
                      _InfoRow(
                        Icons.location_on_outlined,
                        'Address'.tr(context),
                        issue.address,
                      ),
                      const Divider(height: 16),
                      _InfoRow(
                        Icons.calendar_today_outlined,
                        'Submitted'.tr(context),
                        _fmt(issue.createdAt),
                      ),
                      if (issue.updatedAt != null) ...[
                        const Divider(height: 16),
                        _InfoRow(
                          Icons.update,
                          'Last Updated'.tr(context),
                          _fmt(issue.updatedAt!),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Map preview
                _DetailCard(
                  'Issue Location'.tr(context),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: const IssueMapView(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final url = Uri.parse(
                              'https://www.google.com/maps/dir/?api=1&destination=${issue.latitude},${issue.longitude}',
                            );
                            try {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } catch (e) {
                              debugPrint('Error launching maps: $url');
                            }
                          },
                          icon: const Icon(Icons.directions),
                          label: Text('Get Directions'.tr(context)),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Assignment info
                if (issue.assignedWorkerName != null)
                  _DetailCard(
                    'Assignment'.tr(context),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.workerColor.withValues(
                            alpha: 0.1,
                          ),
                          child: Icon(
                            Icons.engineering_outlined,
                            color: AppColors.workerColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                issue.assignedWorkerName!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Field Worker Assigned'.tr(context),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                            'Active'.tr(context),
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (issue.assignedWorkerName != null)
                  const SizedBox(height: 12),

                // E-signature status
                if (issue.eSignatureData != null)
                  _DetailCard(
                    'Verification'.tr(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Work Verified with E-Signature'.tr(context),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.success,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.draw_outlined,
                                  color: AppColors.success,
                                  size: 30,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'E-Signature on file'.tr(context),
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (issue.eSignatureData != null) const SizedBox(height: 12),

                // Submitter info
                _DetailCard(
                  'Reported By'.tr(context),
                  child: Column(
                    children: [
                      _InfoRow(
                        Icons.person_outline,
                        'Name'.tr(context),
                        issue.submittedBy,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Rating and Feedback (visible to everyone)
                if (issue.satisfactionRating != null) ...[
                  _DetailCard(
                    'Feedback & Rating'.tr(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < issue.satisfactionRating!
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber.shade700,
                              size: 24,
                            );
                          }),
                        ),
                        if (issue.feedbackText != null &&
                            issue.feedbackText!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '"${issue.feedbackText!}"',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Citizen Rating action
                if (role == 'citizen' &&
                    (issue.status == 'completed' ||
                        issue.status == 'closed')) ...[
                  if (issue.satisfactionRating == null)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.star_outline),
                        label: Text('Rate Resolution'.tr(context)),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) => _RatingSheet(issue: issue),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],

                // Authority actions
                if (role == 'authority') ...[
                  if (issue.status == 'pending') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.verified_outlined),
                        label: Text('Acknowledge & Verify'.tr(context)),
                        onPressed: () async {
                          await issueProvider.updateStatus(
                            issue.id,
                            'acknowledged',
                            onNotify: notifProvider.addNotification,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Issue acknowledged!'.tr(context),
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close),
                      label: Text('Close Issue'.tr(context)),
                      onPressed: () async {
                        await issueProvider.updateStatus(
                          issue.id,
                          'closed',
                          onNotify: notifProvider.addNotification,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusDot extends StatelessWidget {
  final String status;
  const _StatusDot(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppConstants.statusColor(status),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StatusProgressBar extends StatelessWidget {
  final String status;
  const _StatusProgressBar({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = ['pending', 'acknowledged', 'work_started', 'completed'];
    final isClosed = status == 'closed';
    final idx = steps.indexOf(status);
    final activeIdx = isClosed ? steps.length - 1 : (idx >= 0 ? idx : 0);

    return Row(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final label = [
          'Submitted'.tr(context),
          'Verified'.tr(context),
          'In Progress'.tr(context),
          'Completed'.tr(context),
        ][i];
        final isActive = i <= activeIdx;
        final isCurrent = isClosed ? (i == steps.length - 1) : (i == activeIdx);

        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive ? AppColors.primary : AppColors.divider,
                  ),
                ),
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.white,
                      border: Border.all(
                        color: isActive ? AppColors.primary : AppColors.divider,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: isActive
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i < (idx >= 0 ? idx : 0)
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _DetailCard(this.title, {required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _RatingSheet extends StatefulWidget {
  final Issue issue;
  const _RatingSheet({required this.issue});

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _rating = 0;
  bool _submitting = false;
  final TextEditingController _feedbackController = TextEditingController();

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a rating'.tr(context)),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final issueProvider = Provider.of<IssueProvider>(context, listen: false);
      await issueProvider.updateSatisfactionRating(
        widget.issue.id,
        _rating,
        feedback: _feedbackController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your feedback!'.tr(context)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate Issue Resolution'.tr(context),
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'How satisfied are you with how your complaint was handled?'.tr(
              context,
            ),
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber.shade700,
                  size: 40,
                ),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any additional feedback? (Optional)'.tr(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Submit Feedback'.tr(context)),
            ),
          ),
        ],
      ),
    );
  }
}
