import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/data/models/order_model.dart';

class OrderService {
  OrderService._();

  static Future<List<OrderModel>> fetchMyOrders() async {
    final json = await ApiClient.get('/orders/me');
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<OrderModel> fetchOrder(String orderId) async {
    final json = await ApiClient.get('/orders/$orderId');
    return OrderModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> createOrder({
    required String merchantId,
    required List<Map<String, dynamic>> orderItems,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'merchantId': merchantId,
      'orderItems': orderItems,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
    final json = await ApiClient.post('/orders', body);
    return json['data'] as Map<String, dynamic>? ?? {};
  }


  static Future<List<OrderModel>> fetchOrderMerchant() async {
    final json = await ApiClient.get('/orders/merchant');
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }


  static Future<OrderModel> acceptOrder(String orderId) async {
    final json = await ApiClient.patch('/orders/$orderId/status', {'status': 'ACCEPT'});
    return OrderModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  static Future<OrderModel> rejectOrder(String orderId) async {
    final json = await ApiClient.patch('/orders/$orderId/status', {'status': 'REJECT'});
    return OrderModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  static Future<OrderModel> scanOrder(String orderId, String qrCode) async {
    final json = await ApiClient.patch('/orders/$orderId/scan', {
      'qrCode': qrCode,
    });
    return OrderModel.fromJson(json['data'] as Map<String, dynamic>);
  }


  static Future<OrderModel> readyOrder(String orderId) async {
    final json = await ApiClient.patch('/orders/$orderId/status', {'status': 'READY'});
    return OrderModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}
