import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/data/models/merchant_model.dart';

class SurplusService {
  SurplusService._();

  static Future<List<SurplusItemModel>> getMySurplus() async {
    final json = await ApiClient.get('/surplus');
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => SurplusItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<SurplusItemModel> create(Map<String, dynamic> data) async {
    final json = await ApiClient.post('/surplus', data);
    return SurplusItemModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  static Future<SurplusItemModel> update(String id, Map<String, dynamic> data) async {
    final json = await ApiClient.patch('/surplus/$id', data);
    return SurplusItemModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}
