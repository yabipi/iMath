import 'package:dio/dio.dart';
import 'package:imath/config/api_config.dart';
import 'init.dart';

class UserHttp {

  static Future update(int userId, params) async {
    final response = await Request().put(
      '${ApiConfig.SERVER_BASE_URL}/api/user/${userId}/update',
      options: Options(contentType: Headers.jsonContentType),
      data: params,
    );
    return response.data;
  }

  static Future submitFeedback(int userId, String message) async {
    final response = await Request().post(
      '${ApiConfig.SERVER_BASE_URL}/api/user/feedback',
      options: Options(contentType: Headers.jsonContentType),
      data: {"userId": userId, "feedback": message},
    );
    return response.data;
  }

}