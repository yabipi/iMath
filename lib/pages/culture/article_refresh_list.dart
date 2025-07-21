import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/http/article.dart';
import 'package:imath/models/article.dart';
import 'package:imath/utils/data_util.dart';
import 'package:imath/utils/date_util.dart';
import 'package:imath/widgets/refresh/constructor.dart';
import 'package:imath/widgets/refresh/paging_mixin.dart';

class ArticleRefreshListScreen extends StatefulWidget {
  ArticleRefreshListScreen({super.key, ArticleType articleType = ArticleType.normal});
  ArticleType? articleType;

  @override
  State<ArticleRefreshListScreen> createState() => _ArticleRefreshListScreenState();
}

class _ArticleRefreshListScreenState extends State<ArticleRefreshListScreen> {
  final ScrollController _scrollController = ScrollController();
  late PagingMixin<Article> _controller;

  void initState() {
    super.initState();
    _controller = ArticleListController(articleType: widget.articleType);
    _controller.initPaging();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return SpeedyPagedList<Article>.separated(
      controller: _controller,
      itemBuilder: (context, index, item) {
        return ListTile(
          title: Text(item.title),
          subtitle: Text(DateUtil.formatDate(item.date) ?? ''),
          onTap: () {
            context.go("/culture/article", extra: item);
          },
        );
      },
      scrollController: _scrollController,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider();
      },
    );
  }
}

class User {
  final String name;
  final String avatar;
  final String? desc;

  User({
    required this.name,
    required this.avatar,
    this.desc,
  });
}

class ArticleListController with PagingMixin<Article> {
  ArticleListController({this.articleType});
  final ArticleType? articleType;

  @override
  FutureOr fecthData(int page) async {
    final result = await ArticleHttp.loadArticles(articleType: articleType??ArticleType.normal); // 假设接口支持 pageNo 参数
    final articles = DataUtils.dataAsList(result['data'], Article.fromJson);
    endLoad(articles, maxCount:result['total']);
  }
}