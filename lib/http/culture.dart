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
    return response;
  }

  static Future loadMathematicians() async {
    final response = await Request().get(
      '${ApiConfig.SERVER_BASE_URL}/api/mathematician'
    );
    return response.data;
  }
}