import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_constants.dart';
import '../../models/issue_model.dart';
import '../../providers/issue_provider.dart';
import '../../utils/translations.dart';

class TicketScreen extends StatelessWidget {
  final Issue issue;
  const TicketScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(issue.ticketNumber),
        backgroundColor: AppColors.citizenColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket details copied!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<IssueProvider>(
        builder: (ctx, provider, _) {
          // Get fresh issue from provider
          final freshIssue = provider.issues.firstWhere(
            (i) => i.id == issue.id,
            orElse: () => issue,
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TicketHeader(issue: freshIssue),
                const SizedBox(height: 16),
                _StatusTimeline(issue: freshIssue),
                const SizedBox(height: 16),
                _IssueDetails(issue: freshIssue),
                if (freshIssue.assignedWorkerName != null) ...[
                  const SizedBox(height: 16),
                  _AssignedWorkerCard(issue: freshIssue),
                ],
                const SizedBox(height: 16),
                _LocationCard(issue: freshIssue),
                if (freshIssue.eSignatureData != null) ...[
                  const SizedBox(height: 16),
                  _CompletionProofCard(issue: freshIssue),
                ],
                if (freshIssue.status == 'completed' ||
                    freshIssue.status == 'closed') ...[
                  const SizedBox(height: 16),
                  _SatisfactionRating(issue: freshIssue),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TicketHeader extends StatelessWidget {
  final Issue issue;
  const _TicketHeader({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.citizenColor,
            AppColors.citizenColor.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.citizenColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppConstants.categoryIcon(issue.category),
                  color: Colors.white,
                  size: 28,
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
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issue.ticketNumber,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoChip(
                AppConstants.statusLabel(issue.status),
                Colors.white,
                Colors.white.withValues(alpha: 0.25),
              ),
              _InfoChip(
                issue.priority.toUpperCase(),
                Colors.white,
                Colors.white.withValues(alpha: 0.25),
              ),
              _InfoChip(
                issue.category,
                Colors.white,
                Colors.white.withValues(alpha: 0.25),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 12, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                '${'Submitted:'.tr(context)} ${_formatDate(issue.createdAt)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color bgColor;
  const _InfoChip(this.label, this.textColor, this.bgColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final Issue issue;
  const _StatusTimeline({required this.issue});

  static const _steps = [
    ('pending', 'Submitted', Icons.assignment_turned_in_outlined),
    ('acknowledged', 'Acknowledged', Icons.verified_outlined),
    ('work_started', 'Work Started', Icons.engineering_outlined),
    ('completed', 'Completed', Icons.check_circle_outline),
    ('closed', 'Closed', Icons.lock_outline),
  ];

  int get _currentStep {
    final order = [
      'pending',
      'acknowledged',
      'work_started',
      'completed',
      'closed',
    ];
    return order.indexOf(issue.status);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Timeline'.tr(context), style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          ..._steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final s = entry.value;
            final isDone = idx <= _currentStep;
            final isCurrent = idx == _currentStep;
            final isLast = idx == _steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? (isCurrent
                                  ? AppColors.citizenColor
                                  : AppColors.success)
                            : Colors.grey[200],
                        border: isCurrent
                            ? Border.all(
                                color: AppColors.citizenColor,
                                width: 3,
                              )
                            : null,
                      ),
                      child: Icon(
                        s.$3,
                        size: 16,
                        color: isDone ? Colors.white : Colors.grey[400],
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: isDone && idx < _currentStep
                            ? AppColors.success
                            : Colors.grey[200],
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.$2,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDone
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (isCurrent)
                          Text(
                            'Current status'.tr(context),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.citizenColor.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _IssueDetails extends StatelessWidget {
  final Issue issue;
  const _IssueDetails({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Issue Details'.tr(context), style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          _DetailRow('Category'.tr(context), issue.category.tr(context)),
          _DetailRow(
            'Priority'.tr(context),
            issue.priority.toUpperCase().tr(context),
          ),
          _DetailRow(
            'Submitted By'.tr(context),
            issue.submittedBy.isEmpty
                ? 'Anonymous'.tr(context)
                : issue.submittedBy,
          ),
          _DetailRow('Submitted On'.tr(context), _fmtDate(issue.createdAt)),
          if (issue.updatedAt != null)
            _DetailRow('Last Updated'.tr(context), _fmtDate(issue.updatedAt!)),
          const Divider(height: 24),
          Text('Description'.tr(context), style: AppTextStyles.label),
          const SizedBox(height: 8),
          Text(issue.description, style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedWorkerCard extends StatelessWidget {
  final Issue issue;
  const _AssignedWorkerCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.workerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.workerColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.workerColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.engineering, color: AppColors.workerColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigned Field Worker'.tr(context),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  issue.assignedWorkerName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.workerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Active'.tr(context),
              style: const TextStyle(
                color: AppColors.workerColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final Issue issue;
  const _LocationCard({required this.issue});

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
          Text('Location'.tr(context), style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.danger, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  issue.address,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.my_location,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Lat: ${issue.latitude.toStringAsFixed(4)}, Lng: ${issue.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionProofCard extends StatelessWidget {
  final Issue issue;
  const _CompletionProofCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completion Proof Submitted'.tr(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'E-signature captured and recorded by field worker'.tr(
                    context,
                  ),
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
    );
  }
}

class _SatisfactionRating extends StatefulWidget {
  final Issue issue;
  const _SatisfactionRating({required this.issue});

  @override
  State<_SatisfactionRating> createState() => _SatisfactionRatingState();
}

class _SatisfactionRatingState extends State<_SatisfactionRating> {
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _rating = widget.issue.satisfactionRating ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning.withValues(alpha: 0.08), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate This Resolution'.tr(context),
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 4),
          Text(
            'How satisfied are you with the resolution?'.tr(context),
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () async {
                  setState(() => _rating = i + 1);
                  final provider = Provider.of<IssueProvider>(
                    context,
                    listen: false,
                  );
                  final idx = provider.issues.indexWhere(
                    (issue) => issue.id == widget.issue.id,
                  );
                  if (idx >= 0) {
                    await provider.updateStatus(
                      widget.issue.id,
                      provider.issues[idx].status,
                    );
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thanks for rating ${i + 1} ⭐!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          if (_rating > 0) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                _ratingText(_rating),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _ratingText(int r) {
    switch (r) {
      case 1:
        return 'Very Unsatisfied 😞';
      case 2:
        return 'Unsatisfied 😐';
      case 3:
        return 'Neutral 🙂';
      case 4:
        return 'Satisfied 😊';
      case 5:
        return 'Very Satisfied 😄';
      default:
        return '';
    }
  }
}
