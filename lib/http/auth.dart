import 'package:dio/dio.dart';
import 'package:imath/config/api_config.dart';
import 'init.dart';

class AuthHttp {

  static Future sendCaptcha() async {
    final response = await Request().get(
      '${ApiConfig.SERVER_BASE_URL}/api/user/sendCaptcha',
    );
    return response;
  }

  static Future verifyCaptcha(String captcha) async {
    final response = await Request().post(
        '${ApiConfig.SERVER_BASE_URL}/api/user/verifyCaptcha',
      options: Options(contentType: Headers.jsonContentType),
      data: {'captcha': captcha},
    );
    return response.data;
  }
}