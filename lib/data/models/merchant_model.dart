
class MerchantModel {
  final String merchantId;
  final String merchantName;
  final String? address;
  final String? description;
  final String? openTime;
  final String? closeTime;
  final String? avatar;
  final List<String> categories;
  final double? rating;

  const MerchantModel({
    required this.merchantId,
    required this.merchantName,
    this.address,
    this.description,
    this.openTime,
    this.closeTime,
    this.avatar,
    required this.categories,
    this.rating,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      merchantId: json['merchantId'] as String,
      merchantName: json['merchantName'] as String? ?? '',
      address: json['address'] as String?,
      description: json['description'] as String?,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      avatar: json['avatar'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}

class SurplusItemModel {
  final String surplusItemId;
  final String name;
  final String? description;
  final String? image;
  final int discountPrice;
  final int originalPrice;
  final int stock;
  final bool isActive;

  const SurplusItemModel({
    required this.surplusItemId,
    required this.name,
    this.description,
    this.image,
    required this.discountPrice,
    required this.originalPrice,
    required this.stock,
    this.isActive = true,
  });

  factory SurplusItemModel.fromJson(Map<String, dynamic> json) {
    return SurplusItemModel(
      surplusItemId: json['surplusItemId'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      image: json['image'] as String?,
      discountPrice: (json['discountPrice'] as num?)?.toInt() ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class MenuItemModel {
  final String menuItemId;
  final String name;
  final String? description;
  final String? image;
  final int originalPrice;
  final bool isActive;

  const MenuItemModel({
    required this.menuItemId,
    required this.name,
    this.description,
    this.image,
    required this.originalPrice,
    this.isActive = true,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      menuItemId: json['menuItemId'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      image: json['image'] as String?,
      originalPrice: (json['originalPrice'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class MerchantDetailModel {
  final String merchantId;
  final String merchantName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? openTime;
  final String? closeTime;
  final String? phone;
  final String? avatar;
  final List<String> categories;
  final double? rating;
  final int totalRevenue;
  final int totalPortion;
  final DateTime? createdAt;
  final List<SurplusItemModel> surplusItems;

  const MerchantDetailModel({
    required this.merchantId,
    required this.merchantName,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.openTime,
    this.closeTime,
    this.phone,
    this.avatar,
    required this.categories,
    this.rating,
    this.totalRevenue = 0,
    this.totalPortion = 0,
    this.createdAt,
    required this.surplusItems,
  });

  factory MerchantDetailModel.fromJson(Map<String, dynamic> json) {
    return MerchantDetailModel(
      merchantId: json['merchantId'] as String,
      merchantName: json['merchantName'] as String? ?? '',
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      description: json['description'] as String?,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble(),
      totalRevenue: (json['totalRevenue'] as num?)?.toInt() ?? 0,
      totalPortion: (json['totalPortion'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      surplusItems: (json['surplusItems'] as List<dynamic>?)
              ?.map((e) => SurplusItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
