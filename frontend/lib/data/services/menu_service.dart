import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/data/models/merchant_model.dart';

class MenuService {
  MenuService._();

  static Future<List<MenuItemModel>> getAllMenus() async {
    final json = await ApiClient.get('/menus');
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Membuat menu item baru.
  ///
  /// Backend menerima `multipart/form-data` dengan fields:
  ///   - `name` (required)
  ///   - `originalPrice` (required, angka dikirim sebagai string)
  ///   - `description` (optional)
  ///   - `image` (optional, file gambar)
  static Future<MenuItemModel> createMenu({
    required String name,
    required int originalPrice,
    String? description,
    String? imagePath,
  }) async {
    final fields = <String, String>{
      'name': name,
      'originalPrice': originalPrice.toString(),
      if (description != null && description.isNotEmpty)
        'description': description,
    };

    final json = await ApiClient.multipartPost(
      '/menus',
      fields: fields,
      filePath: imagePath,
      fileFieldName: 'image',
    );

    return MenuItemModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  static Future<MenuItemModel> updateMenu(
    String menuItemId,
    Map<String, dynamic> data,
  ) async {
    final json = await ApiClient.patch('/menus/$menuItemId', data);
    return MenuItemModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  static Future<void> deleteMenu(String menuItemId) async {
    await ApiClient.delete('/menus/$menuItemId');
  }
}
