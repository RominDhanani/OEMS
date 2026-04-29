class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String role; // MANAGER, USER
  final String status; // PENDING, APPROVED, REJECTED, DEACTIVATED
  final int? managerId;
  final String? managerName;
  final String? mobileNumber;
  final String? profileImage;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    this.managerId,
    this.managerName,
    this.mobileNumber,
    this.profileImage,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      role: json['role'] ?? 'USER',
      status: json['status'] ?? 'PENDING',
      managerId: json['manager_id'],
      managerName: json['manager_name'],
      mobileNumber: json['mobile_number'],
      profileImage: json['profile_image'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'status': status,
      'managerId': managerId,
      'managerName': managerName,
      'mobileNumber': mobileNumber,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }


  bool get isManager => role == 'MANAGER';
  bool get isUser => role == 'USER';
  bool get isApproved => status == 'APPROVED';

  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? role,
    String? status,
    int? managerId,
    String? managerName,
    String? mobileNumber,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
