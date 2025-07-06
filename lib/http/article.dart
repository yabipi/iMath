import 'package:dio/dio.dart';
import 'package:imath/config/api_config.dart';
import 'init.dart';

class ArticleHttp {

  static Future addArticle(params) async {
    final response = await Request().post(
      '${ApiConfig.SERVER_BASE_URL}/api/article',
      options: Options(contentType: Headers.jsonContentType),
      data:params,
    );
    return response.data;
  }

  static Future loadArticles() async {
    final response = await Request().get(
        '${ApiConfig.SERVER_BASE_URL}/api/article'
    );
    return response.data;
  }
}