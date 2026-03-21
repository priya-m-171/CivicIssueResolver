import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:signature/signature.dart';
import 'dart:convert';
import '../../config/app_constants.dart';
import '../../models/issue_model.dart';
import '../../providers/issue_provider.dart';
import '../../providers/notification_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkerTaskDetail extends StatelessWidget {
  final Issue issue;
  const WorkerTaskDetail({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(issue.ticketNumber),
        backgroundColor: AppColors.workerColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<IssueProvider>(
        builder: (ctx, provider, _) {
          final fresh = provider.issues.firstWhere(
            (i) => i.id == issue.id,
            orElse: () => issue,
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TaskHeaderCard(issue: fresh),
                const SizedBox(height: 16),
                _TaskLocationMap(issue: fresh),
                const SizedBox(height: 16),
                _TaskDescriptionCard(issue: fresh),
                const SizedBox(height: 16),
                _StatusCard(issue: fresh),
                if (fresh.eSignatureData != null) ...[
                  const SizedBox(height: 16),
                  _ProofCard(issue: fresh),
                ],
                if (fresh.status == 'work_started') ...[
                  const SizedBox(height: 20),
                  _CompleteButton(issue: fresh),
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

// ── Header ────────────────────────────────────────────────────────────────────

class _TaskHeaderCard extends StatelessWidget {
  final Issue issue;
  const _TaskHeaderCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.workerColor, Color(0xFFFF9500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.workerColor.withValues(alpha: 0.3),
            blurRadius: 14,
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
                  size: 26,
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
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      issue.ticketNumber,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _PriorityBadge(priority: issue.priority),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: Colors.white70,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  issue.address,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.category_outlined,
                size: 13,
                color: Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                issue.category,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Location map ──────────────────────────────────────────────────────────────

class _TaskLocationMap extends StatelessWidget {
  final Issue issue;
  const _TaskLocationMap({required this.issue});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(issue.latitude, issue.longitude);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  color: AppColors.workerColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text('Issue Location', style: AppTextStyles.heading3),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: SizedBox(
              height: 220,
              child: FlutterMap(
                options: MapOptions(initialCenter: point, initialZoom: 15),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.civic.resolver',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 44,
                        height: 60,
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 14,
                              color: AppColors.danger,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.directions),
              label: const Text('Get Directions'),
              onPressed: () async {
                final url = Uri.parse(
                  'https://www.google.com/maps/dir/?api=1&destination=${issue.latitude},${issue.longitude}',
                );
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  debugPrint('Could not launch directions');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Description ───────────────────────────────────────────────────────────────

class _TaskDescriptionCard extends StatelessWidget {
  final Issue issue;
  const _TaskDescriptionCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description', style: AppTextStyles.heading3),
          const SizedBox(height: 10),
          Text(issue.description, style: AppTextStyles.bodySecondary),
          const Divider(height: 24),
          _Row(
            'Submitted by',
            issue.submittedBy.isEmpty ? 'Anonymous' : issue.submittedBy,
          ),
          _Row('Date', _fmtDate(issue.createdAt)),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    const m = [
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
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status card ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final Issue issue;
  const _StatusCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.statusColor(issue.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info_outline, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Status',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                AppConstants.statusLabel(issue.status),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Completion proof ──────────────────────────────────────────────────────────

class _ProofCard extends StatelessWidget {
  final Issue issue;
  const _ProofCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified, color: AppColors.success, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E-Signature Submitted',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  'Completion proof recorded successfully',
                  style: TextStyle(
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

// ── Complete button + bottom sheet ────────────────────────────────────────────

class _CompleteButton extends StatelessWidget {
  final Issue issue;
  const _CompleteButton({required this.issue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.draw_outlined),
        label: const Text('Mark as Complete'),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => _CompletionBottom(issue: issue),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.workerColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _CompletionBottom extends StatefulWidget {
  final Issue issue;
  const _CompletionBottom({required this.issue});

  @override
  State<_CompletionBottom> createState() => _CompletionBottomState();
}

class _CompletionBottomState extends State<_CompletionBottom> {
  late final SignatureController _sig;
  bool _signed = false;
  bool _submitting = false;
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sig = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _sig.addListener(() {
      if (_sig.isNotEmpty && !_signed) setState(() => _signed = true);
    });
  }

  @override
  void dispose() {
    _sig.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sig.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw your e-signature first'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    // Capture providers BEFORE any await to avoid BuildContext-across-async-gap
    final ip = Provider.of<IssueProvider>(context, listen: false);
    final np = Provider.of<NotificationProvider>(context, listen: false);
    setState(() => _submitting = true);
    try {
      final bytes = await _sig.toPngBytes();
      final b64 = base64Encode(bytes!);
      await ip.updateProofAndSignature(
        widget.issue.id,
        eSignatureData: b64,
        resolutionNotes: _notes.text.trim().isNotEmpty
            ? _notes.text.trim()
            : null,
        newStatus: 'completed',
        onNotify: np.addNotification,
      );
      if (mounted) {
        Navigator.of(context)
          ..pop() // close sheet
          ..pop(); // go back to task list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Task completed with e-signature!'),
            backgroundColor: AppColors.success,
          ),
        );
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
      builder: (_, scroll) => SingleChildScrollView(
        controller: scroll,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text('Complete Task', style: AppTextStyles.heading2),
            const SizedBox(height: 4),
            const Text(
              'Add notes and e-signature to confirm task completion',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 20),

            // Notes
            const Text('Completion Notes', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe work done, materials used…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Signature
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
                    _sig.clear();
                    setState(() => _signed = false);
                  },
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                  controller: _sig,
                  height: 150,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            if (_signed)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Signature captured',
                      style: TextStyle(color: AppColors.success, fontSize: 12),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit & Complete Task',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
