import 'package:dio/dio.dart';
import 'package:imath/config/api_config.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/models/quiz.dart';
import 'package:imath/state/global_state.dart';

import 'init.dart';

class KnowledgeHttp {

  static Future loadKnowledge(int knowledgeId) async {
    final response = await Request().get('${ApiConfig.SERVER_BASE_URL}/api/know/${knowledgeId}');
    return response.data;
  }

  static Future addKnowledge(params) async {
    final response = await Request().post(
      '${ApiConfig.SERVER_BASE_URL}/api/know/create',
      options: Options(contentType: Headers.jsonContentType),
      data:params,
    );
    return response;
  }

  static Future listKnowledges(MATH_LEVEL level, int categoryId) async {
    final categories = GlobalState.get(CATEGORIES_KEY);
    String category = categories[categoryId.toString()];
    String url;
    if (categoryId != ALL_CATEGORY) {
      url = '${ApiConfig.SERVER_BASE_URL}/api/know/list?level=${level.value}&category=${category}';
    } else {
      url = '${ApiConfig.SERVER_BASE_URL}/api/know/list?level=${level.value}';
    }
    final response = await Request().get(url);
    return response.data;
  }

}