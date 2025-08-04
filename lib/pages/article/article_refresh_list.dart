import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/config/icons.dart';
import 'package:imath/http/article.dart';
import 'package:imath/models/article.dart';
import 'package:imath/utils/data_util.dart';
import 'package:imath/utils/date_util.dart';
import 'package:imath/widgets/refresh/constructor.dart';
import 'package:imath/widgets/refresh/paging_mixin.dart';

class ArticleRefreshListScreen extends StatefulWidget {
  ArticleRefreshListScreen({super.key, required this.articleType});
  final ArticleType articleType;

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

  // 根据文章ID获取对应的图标和颜色
  Map<String, dynamic> _getIconForArticle(int? articleId) {
    if (articleId == null) {
      return mathIconSet[0]; // 默认返回第一个图标
    }
    
    // 使用文章ID的哈希值来选择图标，确保同一篇文章总是显示相同的图标
    final index = articleId.abs() % mathIconSet.length;
    return mathIconSet[index];
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
        return GestureDetector(
          onTap: () {
            context.push("/article", extra: item);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 数学相关图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getIconForArticle(item.id)['colors'],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _getIconForArticle(item.id)['colors'][0].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getIconForArticle(item.id)['icon'],
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 文章内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // 日期
                            Expanded(
                              child: Text(
                                DateUtil.formatDate(item.date) ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            // 三个精美图标
                            Row(
                              children: [
                                // 点赞图标
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.shade200, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        size: 16,
                                        color: Colors.red.shade400,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(item.id ?? 0) % 100 + 10}', // 模拟点赞数
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 阅览数图标
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.shade200, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        size: 16,
                                        color: Colors.blue.shade400,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(item.id ?? 0) % 500 + 50}', // 模拟阅览数
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 收藏图标
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.amber.shade200, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.bookmark,
                                        size: 16,
                                        color: Colors.amber.shade400,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(item.id ?? 0) % 30 + 5}', // 模拟收藏数
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.amber.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      scrollController: _scrollController,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox.shrink(); // 移除分隔线，使用卡片间距
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
  ArticleListController({required this.articleType});
  final ArticleType articleType;

  @override
  FutureOr fecthData(int page) async {
    final result = await ArticleHttp.loadArticles(articleType: this.articleType); // 假设接口支持 pageNo 参数
    final articles = DataUtils.dataAsList(result['data'], Article.fromJson);
    endLoad(articles, maxCount:result['total']);
  }
}