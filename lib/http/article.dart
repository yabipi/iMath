import 'package:dio/dio.dart';
import 'package:imath/config/api_config.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/models/article.dart';
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

  static Future<Article> loadArticle(int? articleId) async {
    final response = await Request().get(
      '${ApiConfig.SERVER_BASE_URL}/api/article/${articleId}',
    );
    Article article = Article.fromJson(response.data);
    return article;
  }

  static Future updateArticle(int? articleId, params) async {
    final response = await Request().put(
      '${ApiConfig.SERVER_BASE_URL}/api/article/${articleId}',
      options: Options(contentType: Headers.jsonContentType),
      data:params,
    );
    return response.data;
  }

  static Future loadArticles({
                ArticleType articleType = ArticleType.normal,
                String level = '',
                String branch = '',
                int pageNo = 1,
                int pageSize = 10}) async {
    final response = await Request().get(
        '${ApiConfig.SERVER_BASE_URL}/api/article?&type=${articleType.value}&level=${level}&branch=${branch}&pageNo=${pageNo}&pageSize=${pageSize}'
    );
    return response.data;
  }

  static Future loadKnowledges({ArticleType articleType = ArticleType.normal, required String level, required String branch}) async {
    final response = await Request().get(
        '${ApiConfig.SERVER_BASE_URL}/api/article?type=${articleType}&level=${level}&branch=${branch}'
    );
    return response.data;
  }
}