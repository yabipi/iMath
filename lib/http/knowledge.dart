import 'package:dio/dio.dart';
import 'package:imath/config/api_config.dart';
import 'package:imath/models/quiz.dart';

import 'init.dart';

class KnowledgeHttp {
  static Future addKnowledge(params) async {
    final response = await Request().post(
      '${ApiConfig.SERVER_BASE_URL}/api/know/create',
      options: Options(contentType: Headers.jsonContentType),
      data:params,
    );
    return response;
  }

}