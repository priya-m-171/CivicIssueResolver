class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'citizen', 'authority', 'worker', 'admin'
  final String? profileImage;
  final String? phone;
  final String? department;
  final String? workerCategory; // e.g. 'Road Maintenance', 'Electrical', etc.

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'citizen',
    this.profileImage,
    this.phone,
    this.department,
    this.workerCategory,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? profileImage,
    String? phone,
    String? department,
    String? workerCategory,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      workerCategory: workerCategory ?? this.workerCategory,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'citizen',
      profileImage: json['profile_image'],
      phone: json['phone'],
      department: json['department'],
      workerCategory: json['worker_category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_image': profileImage,
      'phone': phone,
      'department': department,
      'worker_category': workerCategory,
    };
  }
}
