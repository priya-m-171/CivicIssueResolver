import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../models/issue_model.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

class IssueProvider with ChangeNotifier {
  List<Issue> _issues = [];
  bool _isLoading = false;

  List<Issue> get issues => [..._issues];
  bool get isLoading => _isLoading;

  List<Issue> get pendingIssues =>
      _issues.where((i) => i.status == 'pending').toList();
  List<Issue> get acknowledgedIssues =>
      _issues.where((i) => i.status == 'acknowledged').toList();
  List<Issue> get inProgressIssues =>
      _issues.where((i) => i.status == 'work_started').toList();
  List<Issue> get completedIssues => _issues
      .where((i) => i.status == 'completed' || i.status == 'closed')
      .toList();

  List<Issue> issuesByUser(String userId) =>
      _issues.where((i) => i.userId == userId).toList();
  List<Issue> issuesByWorker(String workerId) =>
      _issues.where((i) => i.assignedWorkerId == workerId).toList();

  // Analytics helpers
  int get totalIssues => _issues.length;
  int get resolvedCount => _issues
      .where((i) => i.status == 'completed' || i.status == 'closed')
      .length;
  int get pendingCount => _issues.where((i) => i.status == 'pending').length;
  int get assignedCount =>
      _issues.where((i) => i.assignedWorkerId != null).length;
  double get resolutionRate =>
      totalIssues == 0 ? 0 : (resolvedCount / totalIssues * 100);

  Map<String, int> get categoryBreakdown {
    final map = <String, int>{};
    for (final issue in _issues) {
      map[issue.category] = (map[issue.category] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get statusBreakdown {
    return {
      'Pending': pendingCount,
      'Acknowledged': acknowledgedIssues.length,
      'In Progress': inProgressIssues.length,
      'Completed': completedIssues.length,
    };
  }

  List<int> get weeklyTrend {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(8, (i) {
      final weekStart = today.subtract(Duration(days: (7 - i) * 7));
      final weekEnd = weekStart.add(const Duration(days: 7, seconds: -1));
      return _issues
          .where(
            (issue) =>
                issue.createdAt.isAfter(
                  weekStart.subtract(const Duration(seconds: 1)),
                ) &&
                issue.createdAt.isBefore(
                  weekEnd.add(const Duration(seconds: 1)),
                ),
          )
          .length;
    });
  }

  Future<List<String>> _uploadImages(
    String issueId,
    List<XFile> imageFiles,
  ) async {
    // Upload all images in parallel for faster submission
    final futures = imageFiles.asMap().entries.map((entry) async {
      final i = entry.key;
      final file = entry.value;
      final ext = p.extension(file.name);
      final fileName = '${issueId}_$i$ext';
      final path = 'issues/$fileName';

      await SupabaseService.client.storage
          .from('issue_images')
          .uploadBinary(path, await file.readAsBytes());

      return SupabaseService.client.storage
          .from('issue_images')
          .getPublicUrl(path);
    });
    return Future.wait(futures);
  }

  Future<void> addIssue(
    Issue issue, {
    List<XFile> imageFiles = const [],
    NotificationCallback? onNotify,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<String> imageUrls = [];
      String primaryImageUrl = '';

      if (imageFiles.isNotEmpty) {
        imageUrls = await _uploadImages(issue.id, imageFiles);
        primaryImageUrl = imageUrls.isNotEmpty ? imageUrls.first : '';
      }

      final issueToInsert = issue.toJson();
      issueToInsert['image_url'] = primaryImageUrl;
      issueToInsert['image_urls'] = imageUrls; // Override the list

      final response = await SupabaseService.client
          .from('issues')
          .insert(issueToInsert)
          .select()
          .single();

      final newIssue = Issue.fromJson(response);
      _issues.insert(0, newIssue);

      if (onNotify != null) {
        onNotify(
          AppNotification(
            id: const Uuid().v4(),
            title: 'Complaint Submitted',
            message:
                'Your complaint "${issue.title}" (${issue.ticketNumber}) has been submitted.',
            type: 'status_update',
            relatedIssueId: issue.id,
            targetRole: 'citizen',
            targetUserId: issue.userId,
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
        onNotify(
          AppNotification(
            id: const Uuid().v4(),
            title: 'New Complaint',
            message:
                'A new complaint "${issue.title}" has been submitted and needs verification.',
            type: 'task_assigned',
            relatedIssueId: issue.id,
            targetRole: 'authority',
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
        onNotify(
          AppNotification(
            id: const Uuid().v4(),
            title: 'New System Complaint',
            message:
                'A new complaint "${issue.title}" has been submitted to the platform.',
            type: 'system',
            relatedIssueId: issue.id,
            targetRole: 'admin',
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding issue: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(
    String id,
    String newStatus, {
    String? workerId,
    String? workerName,
    NotificationCallback? onNotify,
  }) async {
    try {
      final updateData = {
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (workerId != null) updateData['assigned_worker_id'] = workerId;
      if (workerName != null) updateData['assigned_worker_name'] = workerName;

      await SupabaseService.client
          .from('issues')
          .update(updateData)
          .eq('id', id);

      final idx = _issues.indexWhere((i) => i.id == id);
      if (idx >= 0) {
        _issues[idx] = _issues[idx].copyWith(
          status: newStatus,
          assignedWorkerId: workerId ?? _issues[idx].assignedWorkerId,
          assignedWorkerName: workerName ?? _issues[idx].assignedWorkerName,
          updatedAt: DateTime.now(),
        );
        notifyListeners();

        if (onNotify != null) {
          final issue = _issues[idx];
          onNotify(
            AppNotification(
              id: const Uuid().v4(),
              title: 'Issue Status Updated',
              message:
                  'Issue "${issue.title}" status changed to ${newStatus.replaceAll('_', ' ')}.',
              type: 'status_update',
              relatedIssueId: id,
              targetRole: 'citizen',
              targetUserId: issue.userId,
              isRead: false,
              createdAt: DateTime.now(),
            ),
          );

          if (workerId != null || issue.assignedWorkerId != null) {
            final wId = workerId ?? issue.assignedWorkerId;
            if (wId != null && wId.isNotEmpty) {
              onNotify(
                AppNotification(
                  id: const Uuid().v4(),
                  title: newStatus == 'acknowledged'
                      ? 'New Task Assigned'
                      : 'Task Status Updated',
                  message:
                      'Task "${issue.title}" is now ${newStatus.replaceAll('_', ' ')}.',
                  type: 'task_assigned',
                  relatedIssueId: id,
                  targetRole: 'worker',
                  targetUserId: wId,
                  isRead: false,
                  createdAt: DateTime.now(),
                ),
              );
            }
          }

          onNotify(
            AppNotification(
              id: const Uuid().v4(),
              title: 'Issue Status Updated',
              message:
                  'Issue "${issue.title}" status changed to ${newStatus.replaceAll('_', ' ')}.',
              type: 'status_update',
              relatedIssueId: id,
              targetRole: 'authority',
              isRead: false,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating issue status: $e');
      rethrow;
    }
  }

  Future<void> updateProofAndSignature(
    String id, {
    XFile? proofImageFile,
    String? eSignatureData,
    String? resolutionNotes,
    String? newStatus,
    NotificationCallback? onNotify,
  }) async {
    try {
      String? proofUrl;
      if (proofImageFile != null) {
        final ext = p.extension(proofImageFile.name);
        final fileName = '${id}_proof$ext';
        final path = 'proofs/$fileName';

        await SupabaseService.client.storage
            .from('issue_images')
            .uploadBinary(
              path,
              await proofImageFile.readAsBytes(),
              fileOptions: const sp.FileOptions(upsert: true),
            );

        proofUrl = SupabaseService.client.storage
            .from('issue_images')
            .getPublicUrl(path);
      }

      final updateData = {'updated_at': DateTime.now().toIso8601String()};
      if (proofUrl != null) updateData['proof_image_url'] = proofUrl;
      if (eSignatureData != null) {
        updateData['e_signature_data'] = eSignatureData;
      }
      if (resolutionNotes != null) {
        updateData['resolution_notes'] = resolutionNotes;
      }
      if (newStatus != null) {
        updateData['status'] = newStatus;
      }

      await SupabaseService.client
          .from('issues')
          .update(updateData)
          .eq('id', id);

      final idx = _issues.indexWhere((i) => i.id == id);
      if (idx >= 0) {
        _issues[idx] = _issues[idx].copyWith(
          proofImageUrl: proofUrl ?? _issues[idx].proofImageUrl,
          eSignatureData: eSignatureData ?? _issues[idx].eSignatureData,
          resolutionNotes: resolutionNotes ?? _issues[idx].resolutionNotes,
          status: newStatus ?? _issues[idx].status,
          updatedAt: DateTime.now(),
        );
        notifyListeners();

        if (newStatus != null && onNotify != null) {
          final issue = _issues[idx];
          onNotify(
            AppNotification(
              id: const Uuid().v4(),
              title: 'Issue Status Updated',
              message:
                  'Issue "${issue.title}" status changed to ${newStatus.replaceAll('_', ' ')}.',
              type: 'status_update',
              relatedIssueId: id,
              targetRole: 'citizen',
              targetUserId: issue.userId,
              isRead: false,
              createdAt: DateTime.now(),
            ),
          );

          if (issue.assignedWorkerId != null) {
            onNotify(
              AppNotification(
                id: const Uuid().v4(),
                title: 'Task Status Updated',
                message:
                    'Task "${issue.title}" is now ${newStatus.replaceAll('_', ' ')}.',
                type: 'task_assigned',
                relatedIssueId: id,
                targetRole: 'worker',
                targetUserId: issue.assignedWorkerId!,
                isRead: false,
                createdAt: DateTime.now(),
              ),
            );
          }

          onNotify(
            AppNotification(
              id: const Uuid().v4(),
              title: 'Issue Status Updated',
              message:
                  'Issue "${issue.title}" status changed to ${newStatus.replaceAll('_', ' ')}.',
              type: 'status_update',
              relatedIssueId: id,
              targetRole: 'authority',
              isRead: false,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating proof: $e');
      rethrow;
    }
  }

  Future<void> fetchIssues() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.client
          .from('issues')
          .select()
          .order('created_at', ascending: false);

      _issues = data.map<Issue>((e) => Issue.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching issues: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches all registered workers from the profiles table.
  Future<List<Map<String, dynamic>>> fetchWorkers() async {
    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select('id, name, phone, worker_category')
          .eq('role', 'worker')
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error fetching workers: $e');
      return [];
    }
  }

  Future<void> updateSatisfactionRating(
    String id,
    int rating, {
    String? feedback,
  }) async {
    try {
      final updateData = <String, dynamic>{'satisfaction_rating': rating};
      if (feedback != null && feedback.isNotEmpty) {
        updateData['feedback_text'] = feedback;
      }

      await SupabaseService.client
          .from('issues')
          .update(updateData)
          .eq('id', id);

      final idx = _issues.indexWhere((i) => i.id == id);
      if (idx >= 0) {
        _issues[idx] = _issues[idx].copyWith(
          satisfactionRating: rating,
          feedbackText: feedback,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating rating: $e');
      rethrow;
    }
  }

  Future<void> resetData() async {
    // Keeping for interface compatibility but not doing anything in production
    await fetchIssues();
  }
}

typedef NotificationCallback = void Function(AppNotification notification);
