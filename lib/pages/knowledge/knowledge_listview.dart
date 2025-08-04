import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:imath/config/constants.dart';
import 'package:imath/config/icons.dart';
import 'package:imath/http/article.dart';
import 'package:imath/models/article.dart';
import 'package:imath/pages/common/bottom_navigation_bar.dart';
import 'package:imath/pages/common/category_panel.dart';
import 'package:imath/state/global_state.dart';
import 'package:imath/utils/data_util.dart';
import 'package:imath/utils/date_util.dart';
import 'package:imath/state/settings_provider.dart';

/// 知识列表数据管理器
class KnowledgeListNotifier extends AsyncNotifier<List<Article>> {
  // 分页状态
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _currentBranch = '';
  ArticleType _currentArticleType = ArticleType.normal;

  @override
  Future<List<Article>> build() async {
    // 获取当前的数学级别
    final currentMathLevel = ref.watch(mathLevelProvider);

    try {
      // 重置分页状态
      _currentPage = 1;
      _hasMore = true;
      _currentBranch = '';
      _currentArticleType = ArticleType.normal;

      // 加载全部分支的数据（branch为空字符串）
      final result = await ArticleHttp.loadArticles(
        articleType: _currentArticleType,
        level: currentMathLevel.value,
        branch: _currentBranch,
        pageNo: _currentPage,
        pageSize: 10,
      );

      final articles = DataUtils.dataAsList(result['data'], Article.fromJson);

      // 检查是否还有更多数据
      _hasMore = articles.length == 10;

      return articles;
    } catch (e) {
      throw Exception('加载知识列表失败: $e');
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    // 重置分页状态
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;

    // 重新构建数据
    final currentMathLevel = ref.read(mathLevelProvider);

    try {
      final result = await ArticleHttp.loadArticles(
        articleType: _currentArticleType,
        level: currentMathLevel.value,
        branch: _currentBranch,
        pageNo: _currentPage,
        pageSize: 10,
      );

      final articles = DataUtils.dataAsList(result['data'], Article.fromJson);
      _hasMore = articles.length == 10;
      state = AsyncValue.data(articles);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 加载更多数据
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || state.value == null) return;

    _isLoadingMore = true;
    final currentMathLevel = ref.read(mathLevelProvider);
    final nextPage = _currentPage + 1;

    try {
      final result = await ArticleHttp.loadArticles(
        articleType: _currentArticleType,
        level: currentMathLevel.value,
        branch: _currentBranch,
        pageNo: nextPage,
        pageSize: 10,
      );

      final newArticles =
          DataUtils.dataAsList(result['data'], Article.fromJson);

      if (newArticles.isNotEmpty) {
        // 追加新数据到现有列表
        final allArticles = [...state.value!, ...newArticles];
        _currentPage = nextPage;
        _hasMore = newArticles.length == 10;
        state = AsyncValue.data(allArticles);
      } else {
        _hasMore = false;
      }
    } catch (e) {
      // 加载更多失败，不更新状态，只记录错误
      debugPrint('加载更多数据失败: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  /// 根据分支筛选数据
  Future<void> filterByBranch(String branch) async {
    // 重置分页状态
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _currentBranch = branch;

    final currentMathLevel = ref.read(mathLevelProvider);

    try {
      final result = await ArticleHttp.loadArticles(
        articleType: _currentArticleType,
        level: currentMathLevel.value,
        branch: _currentBranch,
        pageNo: _currentPage,
        pageSize: 10,
      );

      final articles = DataUtils.dataAsList(result['data'], Article.fromJson);
      _hasMore = articles.length == 10;
      state = AsyncValue.data(articles);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 根据分类ID筛选数据
  Future<void> filterByCategory(int categoryId) async {
    // 重置分页状态
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;

    final currentMathLevel = ref.read(mathLevelProvider);

    try {
      String branch = '';
      if (categoryId != ALL_CATEGORY) {
        final categories = GlobalState.get(CATEGORIES_KEY);
        branch = categories[categoryId.toString()] ?? '';
      }

      _currentBranch = branch;

      final result = await ArticleHttp.loadArticles(
        articleType: _currentArticleType,
        level: currentMathLevel.value,
        branch: _currentBranch,
        pageNo: _currentPage,
        pageSize: 10,
      );

      final articles = DataUtils.dataAsList(result['data'], Article.fromJson);
      _hasMore = articles.length == 10;
      state = AsyncValue.data(articles);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 获取分页状态
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}

/// 提供者定义
final knowledgeListProvider =
    AsyncNotifierProvider<KnowledgeListNotifier, List<Article>>(
  () => KnowledgeListNotifier(),
);

/// 知识列表页面
class KnowledgeListView extends ConsumerStatefulWidget {
  const KnowledgeListView({super.key});

  @override
  ConsumerState<KnowledgeListView> createState() => _KnowledgeListViewState();
}

class _KnowledgeListViewState extends ConsumerState<KnowledgeListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMathLevel = ref.watch(mathLevelProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: '搜索...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // TODO: 实现搜索功能
            debugPrint('搜索: $value');
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 分类标签区域
            CategoryPanel(
              onItemTap: (int categoryId) {
                ref
                    .read(knowledgeListProvider.notifier)
                    .filterByCategory(categoryId);
              },
            ),
            // 数学级别显示区域
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const Icon(Icons.school, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '当前级别: ${currentMathLevel.value}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // 切换数学级别
                      final newLevel = currentMathLevel == MATH_LEVEL.Primary
                          ? MATH_LEVEL.Advanced
                          : MATH_LEVEL.Primary;
                      ref.read(mathLevelProvider.notifier).state = newLevel;
                    },
                    child: const Text('切换级别', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            // 列表区域
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final articlesAsync = ref.watch(knowledgeListProvider);

                  return articlesAsync.when(
                    data: (articles) {
                      if (articles.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.article_outlined,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('暂无知识内容',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.read(knowledgeListProvider.notifier).refresh();
                        },
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            // 检查是否滚动到底部
                            if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                              // 触发加载更多
                              ref
                                  .read(knowledgeListProvider.notifier)
                                  .loadMore();
                            }
                            return false;
                          },
                          child: ListView.builder(
                            itemCount: articles.length +
                                (ref
                                        .read(knowledgeListProvider.notifier)
                                        .hasMore
                                    ? 1
                                    : 0),
                            itemBuilder: (context, index) {
                              // 如果是最后一个item且还有更多数据，显示加载指示器
                              if (index == articles.length) {
                                return _buildLoadMoreIndicator();
                              }

                              final article = articles[index];
                              return _buildArticleItem(context, article);
                            },
                          ),
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('加载失败: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(knowledgeListProvider.notifier)
                                  .refresh();
                            },
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  /// 构建文章项
  Widget _buildArticleItem(BuildContext context, Article article) {
    return GestureDetector(
      onTap: () {
        context.push("/article", extra: article);
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
                    colors: _getIconForArticle(article.id)['colors'],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getIconForArticle(article.id)['colors'][0]
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getIconForArticle(article.id)['icon'],
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
                      article.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // 级别和分支信息
                    if (article.level.isNotEmpty || article.branch.isNotEmpty)
                      Row(
                        children: [
                          if (article.level.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Text(
                                article.level,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (article.level.isNotEmpty &&
                              article.branch.isNotEmpty)
                            const SizedBox(width: 8),
                          if (article.branch.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.green.shade200),
                              ),
                              child: Text(
                                article.branch,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    if (article.level.isNotEmpty || article.branch.isNotEmpty)
                      const SizedBox(height: 8),
                    Row(
                      children: [
                        // 日期
                        Expanded(
                          child: Text(
                            DateUtil.formatDate(article.date),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.red.shade200, width: 1),
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
                                    '${article.id % 100 + 10}', // 模拟点赞数
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.blue.shade200, width: 1),
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
                                    '${article.id % 500 + 50}', // 模拟阅览数
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.amber.shade200, width: 1),
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
                                    '${article.id % 30 + 5}', // 模拟收藏数
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
  }

  /// 构建加载更多指示器
  Widget _buildLoadMoreIndicator() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoadingMore =
            ref.read(knowledgeListProvider.notifier).isLoadingMore;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: isLoadingMore
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('加载中...', style: TextStyle(color: Colors.grey)),
                    ],
                  )
                : const Text('上拉加载更多', style: TextStyle(color: Colors.grey)),
          ),
        );
      },
    );
  }

  /// 根据文章ID获取对应的图标和颜色
  Map<String, dynamic> _getIconForArticle(int articleId) {
    // 使用文章ID的哈希值来选择图标，确保同一篇文章总是显示相同的图标
    final index = articleId.abs() % mathIconSet.length;
    return mathIconSet[index];
  }
}
