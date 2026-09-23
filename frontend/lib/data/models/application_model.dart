class ApplicationModel {
  final String applicationId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String merchantName;
  final String merchantOwner;
  final String status;
  final String address;
  final double latitude;
  final double longitude;
  final String? description;
  final String openTime;
  final String closeTime;
  final String phone;
  final String? avatar;
  final List<String> categories;
  final String bankType;
  final String bankAccount;
  final String bankHolder;
  final String document;
  final String? rejectNote;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  ApplicationModel({
    required this.applicationId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.merchantName,
    required this.merchantOwner,
    required this.status,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    required this.openTime,
    required this.closeTime,
    required this.phone,
    this.avatar,
    required this.categories,
    required this.bankType,
    required this.bankAccount,
    required this.bankHolder,
    required this.document,
    this.rejectNote,
    this.reviewedAt,
    required this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: json['applicationId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      userPhone: json['userPhone'] as String? ?? '',
      merchantName: json['merchantName'] as String? ?? '',
      merchantOwner: json['merchantOwner'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      openTime: json['openTime'] as String? ?? '',
      closeTime: json['closeTime'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bankType: json['bankType'] as String? ?? '',
      bankAccount: json['bankAccount'] as String? ?? '',
      bankHolder: json['bankHolder'] as String? ?? '',
      document: json['document'] as String? ?? '',
      rejectNote: json['rejectNote'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'] as String)
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
