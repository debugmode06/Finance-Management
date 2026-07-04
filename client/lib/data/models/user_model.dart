class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? department;
  final String? profileImage;
  final bool isActive;
  final bool isDeleted;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.department,
    this.profileImage,
    required this.isActive,
    required this.isDeleted,
    this.lastLoginAt,
    this.createdAt,
  });

  bool get isFinanceDirector => role == 'finance_director';
  bool get isDirector => role == 'director';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      department: json['department'],
      profileImage: json['profileImage'],
      isActive: json['isActive'] ?? true,
      isDeleted: json['isDeleted'] ?? false,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'department': department,
        'profileImage': profileImage,
        'isActive': isActive,
        'isDeleted': isDeleted,
      };

  UserModel copyWith({
    String? name,
    String? phone,
    String? profileImage,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      department: department,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted,
      lastLoginAt: lastLoginAt,
      createdAt: createdAt,
    );
  }
}
