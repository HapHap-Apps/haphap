class UserProfileModel {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role;
  final int totalSaved;
  final int totalPortion;

  UserProfileModel({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.role = 'CUSTOMER',
    this.totalSaved = 0,
    this.totalPortion = 0,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'] ?? 'CUSTOMER',
      totalSaved: json['totalSaved'] ?? 0,
      totalPortion: json['totalPortion'] ?? 0,
    );
  }
}
