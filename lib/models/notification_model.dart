class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'status_update', 'assignment', 'verification', 'system'
  final String? relatedIssueId;
  final String? targetRole; // 'citizen', 'authority', 'worker', 'admin', 'all'
  final String? targetUserId;
  bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.type = 'system',
    this.relatedIssueId,
    this.targetRole,
    this.targetUserId,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'] ?? 'system',
      relatedIssueId: json['related_issue_id'],
      targetRole: json['target_role'],
      targetUserId: json['target_user_id'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'related_issue_id': relatedIssueId,
      'target_role': targetRole,
      'target_user_id': targetUserId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
    map.removeWhere((key, value) => value == null);
    return map;
  }
}
