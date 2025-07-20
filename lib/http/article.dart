import 'package:dio/dio.dart';
import 'package:imath/config/api_config.dart';
import 'package:imath/config/constants.dart';
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

  static Future loadArticle(int? articleId) async {
    final response = await Request().get(
      '${ApiConfig.SERVER_BASE_URL}/api/article/${articleId}',
    );
    return response.data;
  }

  static Future updateArticle(int? articleId, params) async {
    final response = await Request().put(
      '${ApiConfig.SERVER_BASE_URL}/api/article/${articleId}',
      options: Options(contentType: Headers.jsonContentType),
      data:params,
    );
    return response.data;
  }

  static Future loadArticles({ArticleType articleType = ArticleType.normal, int pageNo = 1, int pageSize = 10}) async {
    final response = await Request().get(
        '${ApiConfig.SERVER_BASE_URL}/api/article?pageNo=${pageNo}&pageSize=${pageSize}&type=${articleType.value}'
    );
    return response.data;
  }
}