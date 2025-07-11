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

  static Future verifyCaptcha(String captcha, String phone) async {
    final response = await Request().post(
        '${ApiConfig.SERVER_BASE_URL}/api/user/verifyCaptcha',
      options: Options(contentType: Headers.jsonContentType),
      data: {'captcha': captcha, 'phone':  phone},
    );
    return response.data;
  }
}