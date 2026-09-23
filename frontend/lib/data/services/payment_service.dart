import 'package:haphap_fe/core/network/api_client.dart';

class PaymentResponse {
  final String paymentId;
  final String orderId;
  final int amount;
  final String status;
  final String snapToken;
  final String redirectUrl;

  const PaymentResponse({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.snapToken,
    required this.redirectUrl,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      paymentId: json['paymentId'] as String,
      orderId: json['orderId'] as String,
      amount: json['amount'] as int,
      status: json['status'] as String,
      snapToken: json['snapToken'] as String,
      redirectUrl: json['redirectUrl'] as String,
    );
  }
}

class PaymentService {
  PaymentService._();

  static Future<PaymentResponse> createPayment(String orderId) async {
    final response = await ApiClient.post('/payments/$orderId', {});
    // Backend wraps response in { "data": { ... } }
    final data = response['data'] as Map<String, dynamic>;
    return PaymentResponse.fromJson(data);
  }
}
