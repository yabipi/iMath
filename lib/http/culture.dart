import 'package:dio/dio.dart';
import 'package:imath/config/api_config.dart';
import 'init.dart';

class CultureHttp {

  static Future addMathematician(params) async {
    final response = await Request().post(
      '${ApiConfig.SERVER_BASE_URL}/api/mathematician',
      options: Options(contentType: Headers.jsonContentType),
      data:params,
    );
    return response.data;
  }

  static Future loadMathematicians() async {
    final response = await Request().get(
      '${ApiConfig.SERVER_BASE_URL}/api/mathematician'
    );
    return response.data;
  }

  static Future loadMathematician(int mathematicianId) async {
    final response = await Request().get(
        '${ApiConfig.SERVER_BASE_URL}/api/mathematician/${mathematicianId}'
    );
    return response.data;
  }

  static Future updateMathematician(int mathematicianId, params) async {
    final response = await Request().put(
        '${ApiConfig.SERVER_BASE_URL}/api/mathematician/${mathematicianId}',
        options: Options(contentType: Headers.jsonContentType),
        data: params,
    );
    return response.data;
  }
}