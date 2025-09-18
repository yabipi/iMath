import 'package:dio/dio.dart';
import 'package:imath/config/api_config.dart';
import 'package:imath/http/payload.dart';
import 'init.dart';

class AuthHttp {

  static Future<ResponseData> checkUsername(String username) async {
    final response = await Request().post(
      '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/checkname',
      options: Options(contentType: Headers.jsonContentType),
      data: {
        'username': username,
        // 'verification_token': verification_token,
      },
    );
    return ResponseData.fromJson(response.data);
  }

  static Future<ResponseData> checkPhone(String phone) async {
    final response = await Request().post(
      '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/checkphone',
      options: Options(contentType: Headers.jsonContentType),
      data: {
        'phone': phone,
        // 'verification_token': verification_token,
      },
    );
    return ResponseData.fromJson(response.data);
  }

  static Future<ResponseData> register(String username, String phoneNumber, String password, String verification_token) async {
    final response = await Request().post(
      '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/register',
      options: Options(contentType: Headers.jsonContentType),
      data: {
        'username': username,
        'phone': phoneNumber,
        'password': password,
        'verification_token': verification_token,
      },
    );
    return ResponseData.fromJson(response.data);
  }

  static Future<ResponseData> sendCaptcha(String phoneNumber) async {
    final response = await Request().post(
      '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/sendCaptcha',
      options: Options(contentType: Headers.jsonContentType),
      data: {'phone': phoneNumber},
    );
    return ResponseData.fromJson(response.data);
  }

  static Future<ResponseData> verifyCaptcha(String phone, String captcha, String type) async {
    final response = await Request().post(
      '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/verifyCaptcha',
      options: Options(contentType: Headers.jsonContentType),
      data: {
        'phone': phone,
        'captcha': captcha,
        'type': type,
      },
    );
    return ResponseData.fromJson(response.data);
  }

  static Future<ResponseData> signIn(username, password) async {
    final response = await Request().post(
        '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/login',
        options: Options(contentType: Headers.jsonContentType),
        data: {'username': username, 'password': password});
    return ResponseData.fromJson(response.data);
  }

  static Future<ResponseData> signOut(username) async {
    final response = await Request().post(
        '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/logout',
        options: Options(contentType: Headers.jsonContentType),
        data: {
          'username': username,
        });
    return ResponseData.fromJson(response.data);
  }

  static Future<ResponseData> changePassword(
      String oldPassword, String newPassword) async {
      final response = await Request().post(
          '${ApiConfig.AUTH_BASE_URL}/api/v1/auth/changePassword',
          options: Options(contentType: Headers.jsonContentType),
          data: {
            'oldPassword': oldPassword,
            'newPassword': newPassword,
          });
    return ResponseData.fromJson(response.data);
  }
}
