class Issue {
  final String id;
  final String ticketNumber;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String imageUrl; // primary image
  final List<String> imageUrls; // all images
  final double latitude;
  final double longitude;
  final String address;
  final String
  status; // 'pending', 'acknowledged', 'work_started', 'completed', 'closed'
  final String? assignedWorkerId;
  final String? assignedWorkerName;
  final String? proofImageUrl;
  final String? eSignatureData; // base64
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String submittedBy;
  int? satisfactionRating;
  String? feedbackText;

  Issue({
    required this.id,
    required this.ticketNumber,
    required this.userId,
    required this.title,
    required this.description,
    this.category = 'general',
    this.priority = 'medium',
    required this.imageUrl,
    this.imageUrls = const [],
    required this.latitude,
    required this.longitude,
    required this.address,
    this.status = 'pending',
    this.assignedWorkerId,
    this.assignedWorkerName,
    this.proofImageUrl,
    this.eSignatureData,
    this.resolutionNotes,
    required this.createdAt,
    this.updatedAt,
    this.submittedBy = '',
    this.satisfactionRating,
    this.feedbackText,
  });

  Issue copyWith({
    String? status,
    String? assignedWorkerId,
    String? assignedWorkerName,
    String? proofImageUrl,
    String? eSignatureData,
    String? resolutionNotes,
    DateTime? updatedAt,
    int? satisfactionRating,
    String? feedbackText,
  }) {
    return Issue(
      id: id,
      ticketNumber: ticketNumber,
      userId: userId,
      title: title,
      description: description,
      category: category,
      priority: priority,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      latitude: latitude,
      longitude: longitude,
      address: address,
      status: status ?? this.status,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
      assignedWorkerName: assignedWorkerName ?? this.assignedWorkerName,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      eSignatureData: eSignatureData ?? this.eSignatureData,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedBy: submittedBy,
      satisfactionRating: satisfactionRating ?? this.satisfactionRating,
      feedbackText: feedbackText ?? this.feedbackText,
    );
  }

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      ticketNumber: json['ticket_number'] ?? 'CMP-0000',
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      category: json['category'] ?? 'general',
      priority: json['priority'] ?? 'medium',
      imageUrl: json['image_url'] ?? '',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'],
      status: json['status'] ?? 'pending',
      assignedWorkerId: json['assigned_worker_id'],
      assignedWorkerName: json['assigned_worker_name'],
      proofImageUrl: json['proof_image_url'],
      eSignatureData: json['e_signature_data'],
      resolutionNotes: json['resolution_notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      submittedBy: json['submitted_by'] ?? '',
      satisfactionRating: json['satisfaction_rating'] != null
          ? int.tryParse(json['satisfaction_rating'].toString())
          : null,
      feedbackText: json['feedback_text'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'ticket_number': ticketNumber,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'status': status,
      'assigned_worker_id': assignedWorkerId,
      'assigned_worker_name': assignedWorkerName,
      'proof_image_url': proofImageUrl,
      'e_signature_data': eSignatureData,
      'resolution_notes': resolutionNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'submitted_by': submittedBy,
      'satisfaction_rating': satisfactionRating,
      'feedback_text': feedbackText,
    };
    map.removeWhere((key, value) => value == null);
    return map;
  }
}
