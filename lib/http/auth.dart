import 'package:dio/dio.dart';
import 'package:imath/config/api_config.dart';
import 'init.dart';

class AuthHttp {
  static Future sendCaptcha(String phoneNumber) async {
    final response = await Request().post(
      '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/sendCaptcha',
      options: Options(contentType: Headers.jsonContentType),
      data: {'phone': phoneNumber},
    );
    return response.data;
  }

  static Future verifyCaptcha(String phone, String captcha, String? password,
      {String? username}) async {
    final response = await Request().post(
      '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/verifyCaptcha',
      options: Options(contentType: Headers.jsonContentType),
      data: {
        'captcha': captcha,
        'phone': phone,
        'password': password,
        'username': username,
      },
    );
    return response.data;
  }

  static Future<dynamic> signIn(username, password) async {
    final response = await Request().post(
        '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/login',
        options: Options(contentType: Headers.jsonContentType),
        data: {'username': username, 'password': password});
    return response.data;
  }

  static Future<dynamic> signOut(username) async {
    final response = await Request().post(
        '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/logout',
        options: Options(contentType: Headers.jsonContentType),
        data: {
          'username': username,
        });
    return response.data;
  }

  static Future<dynamic> changePassword(
      String oldPassword, String newPassword) async {
    final response = await Request().post(
        '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/changePassword',
        options: Options(contentType: Headers.jsonContentType),
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        });
    return response.data;
  }
}
