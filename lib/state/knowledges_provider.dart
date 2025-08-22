import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imath/config/api_config.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/http/article.dart';
import 'package:imath/http/init.dart';

import 'package:imath/models/article.dart';

import 'package:imath/state/global_state.dart';
import 'package:imath/utils/data_util.dart';

import 'settings_provider.dart';

// 分类ID提供者
final knowledgeCategoryProvider = StateProvider<int>((ref) => ALL_CATEGORY);

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
      // debugPrint('加载更多数据失败: $e');
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

class KnowledgesNotifier extends AsyncNotifier<List<Article>>{
  @override
  Future<List<Article>> build() async {
    final MATH_LEVEL level = ref.watch(mathLevelProvider);
    final categoryId = ref.watch(knowledgeCategoryProvider);
    final knowledges = await fetchKnowledges(level, categoryId);
    return knowledges;
  }

  void onChangeCategory(int newCategoryId) async {
    if (ref.read(knowledgeCategoryProvider) == newCategoryId) {
      return;
    }
    state.value?.clear();
    final MATH_LEVEL level = ref.watch(mathLevelProvider);
    ref.read(knowledgeCategoryProvider.notifier).state = newCategoryId;
    final items = await fetchKnowledges(level, newCategoryId);

    state = AsyncValue.data(items);

  }
}

final knowledgesProvider = AsyncNotifierProvider<KnowledgesNotifier, List<Article>>(KnowledgesNotifier.new);

Future<List<Article>> fetchKnowledges(MATH_LEVEL level, int category) async {
  final categories = GlobalState.get(CATEGORIES_KEY);
  String branch = categories[category];
  final result = await ArticleHttp.loadKnowledges(level: level.value, branch: branch);
  final items = DataUtils.dataAsList(result['data'], Article.fromJson);
  return items;
}