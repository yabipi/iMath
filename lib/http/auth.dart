import 'package:dio/dio.dart';
import 'package:imath/config/api_config.dart';
import 'init.dart';

class AuthHttp {

  static Future sendCaptcha(String phoneNumber) async {
    final response = await Request().post(
      '${ApiConfig.SERVER_BASE_URL}/api/user/sendCaptcha',
      options: Options(contentType: Headers.jsonContentType),
      data: {'phone': phoneNumber},
    );
    return response;
  }

  static Future verifyCaptcha(String phone, String captcha) async {
    final response = await Request().post(
        '${ApiConfig.SERVER_BASE_URL}/api/user/verifyCaptcha',
      options: Options(contentType: Headers.jsonContentType),
      data: {'captcha': captcha, 'phone':  phone},
    );
    return response.data;
  }

  static Future<dynamic> signIn(username, password) async {
    final response = await Request().post('${ApiConfig.SERVER_BASE_URL}/api/user/login',
        options: Options(contentType: Headers.jsonContentType),
        data: {
          'username': username,
          'password': password
        }
    );
    return response.data;
  }

  static Future<dynamic> signOut(username) async {
    final response = await Request().post('${ApiConfig.SERVER_BASE_URL}/api/user/logout',
        options: Options(contentType: Headers.jsonContentType),
        data: {
          'username': username,
        }
    );
    return response.data;
  }
}