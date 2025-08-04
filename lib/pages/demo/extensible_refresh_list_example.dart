import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/refresh/extensible_refresh_list.dart';

/// 示例：文章数据模型
class Article {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime publishDate;
  final String category;
  final bool isPublished;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.publishDate,
    required this.category,
    required this.isPublished,
  });
}

/// 示例：文章刷新条件
class ArticleRefreshConditions extends BaseRefreshConditions {
  final String? category;
  final String? searchKeyword;
  final String? sortBy;
  final bool? isPublished;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const ArticleRefreshConditions({
    super.page,
    this.category,
    this.searchKeyword,
    this.sortBy,
    this.isPublished,
    this.dateFrom,
    this.dateTo,
  });

  @override
  ArticleRefreshConditions copyWith({
    int? page,
    String? category,
    String? searchKeyword,
    String? sortBy,
    bool? isPublished,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearPage = false,
  }) {
    return ArticleRefreshConditions(
      page: clearPage ? 1 : (page ?? this.page),
      category: category ?? this.category,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      sortBy: sortBy ?? this.sortBy,
      isPublished: isPublished ?? this.isPublished,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArticleRefreshConditions &&
        other.page == page &&
        other.category == category &&
        other.searchKeyword == searchKeyword &&
        other.sortBy == sortBy &&
        other.isPublished == isPublished &&
        other.dateFrom == dateFrom &&
        other.dateTo == dateTo;
  }

  @override
  int get hashCode {
    return Object.hash(
      page,
      category,
      searchKeyword,
      sortBy,
      isPublished,
      dateFrom,
      dateTo,
    );
  }
}

/// 示例：文章列表状态
class ArticleListState extends BaseListState<Article> {
  const ArticleListState({
    super.items,
    super.isLoading,
    super.hasMore,
    super.error,
    super.totalCount,
  });

  @override
  ArticleListState copyWith({
    List<Article>? items,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? totalCount,
  }) {
    return ArticleListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// 示例：文章刷新条件管理器
class ArticleRefreshConditionsNotifier
    extends BaseRefreshConditionsNotifier<ArticleRefreshConditions> {
  ArticleRefreshConditionsNotifier() : super(const ArticleRefreshConditions());

  void updateCategory(String? category) {
    state = state.copyWith(category: category, clearPage: true);
  }

  void updateSearchKeyword(String? keyword) {
    state = state.copyWith(searchKeyword: keyword, clearPage: true);
  }

  void updateSortBy(String? sortBy) {
    state = state.copyWith(sortBy: sortBy, clearPage: true);
  }

  void updateIsPublished(bool? isPublished) {
    state = state.copyWith(isPublished: isPublished, clearPage: true);
  }

  void updateDateRange(DateTime? dateFrom, DateTime? dateTo) {
    state = state.copyWith(dateFrom: dateFrom, dateTo: dateTo, clearPage: true);
  }

  @override
  ArticleRefreshConditions createInitialState() {
    return const ArticleRefreshConditions();
  }
}

/// 示例：文章列表数据管理器
class ArticleListNotifier extends BaseListNotifier<Article,
    ArticleRefreshConditions, ArticleListState> {
  ArticleListNotifier(
      Ref ref,
      StateNotifierProvider<
              BaseRefreshConditionsNotifier<ArticleRefreshConditions>,
              ArticleRefreshConditions>
          conditionsProvider)
      : super(ref, conditionsProvider, const ArticleListState());

  @override
  ArticleListState createInitialState() {
    return const ArticleListState();
  }

  @override
  Future<List<Article>> generateData(
      ArticleRefreshConditions conditions) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 500));

    final articles = <Article>[];
    final baseIndex = (conditions.page - 1) * getPageSize();

    for (int i = 0; i < getPageSize(); i++) {
      final index = baseIndex + i;

      // 根据搜索条件过滤
      if (conditions.searchKeyword != null &&
          conditions.searchKeyword!.isNotEmpty) {
        final title = '文章标题 $index';
        if (!title
            .toLowerCase()
            .contains(conditions.searchKeyword!.toLowerCase())) {
          continue;
        }
      }

      // 根据分类过滤
      if (conditions.category != null && conditions.category != 'all') {
        final categories = ['tech', 'news', 'sports', 'entertainment'];
        final articleCategory = categories[index % categories.length];
        if (articleCategory != conditions.category) {
          continue;
        }
      }

      // 根据发布状态过滤
      if (conditions.isPublished != null) {
        final isPublished = index % 2 == 0; // 模拟发布状态
        if (isPublished != conditions.isPublished) {
          continue;
        }
      }

      articles.add(Article(
        id: 'article_$index',
        title: '文章标题 $index',
        content: '这是文章 $index 的内容，包含了一些示例文本...',
        author: '作者 $index',
        publishDate: DateTime.now().subtract(Duration(days: index)),
        category: ['tech', 'news', 'sports', 'entertainment'][index % 4],
        isPublished: index % 2 == 0,
      ));
    }

    return articles;
  }

  @override
  int getPageSize() => 8;

  @override
  int getTotalCount(List<Article> items) => 50;
}

/// 提供者定义
final articleRefreshConditionsProvider = StateNotifierProvider<
    ArticleRefreshConditionsNotifier, ArticleRefreshConditions>(
  (ref) => ArticleRefreshConditionsNotifier(),
);

final articleListProvider =
    StateNotifierProvider<ArticleListNotifier, ArticleListState>(
  (ref) => ArticleListNotifier(ref, articleRefreshConditionsProvider),
);

/// 示例：使用可扩展刷新列表的页面
class ExtensibleRefreshListExample extends ConsumerWidget {
  const ExtensibleRefreshListExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('可扩展刷新列表示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
          ),
        ],
      ),
      body: ExtensibleRefreshList<Article, ArticleRefreshConditions,
          ArticleListState>(
        listProvider: articleListProvider,
        conditionsProvider: articleRefreshConditionsProvider,
        itemBuilder: (context, index, article) =>
            _buildArticleItem(context, article),
        separatorBuilder: (context, index) => const Divider(height: 1),
        conditionDisplayBuilder: (conditions) =>
            _buildConditionDisplay(conditions),
        loadingView: const Center(child: CircularProgressIndicator()),
        emptyView: const Center(child: Text('暂无文章')),
        errorView: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('加载失败'),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建文章项
  Widget _buildArticleItem(BuildContext context, Article article) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getCategoryColor(article.category),
        child: Text(
          article.category[0].toUpperCase(),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        article.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(article.content, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                article.author,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Text(
                _formatDate(article.publishDate),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              if (article.isPublished)
                const Chip(
                  label: Text('已发布', style: TextStyle(fontSize: 10)),
                  backgroundColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.white),
                )
              else
                const Chip(
                  label: Text('草稿', style: TextStyle(fontSize: 10)),
                  backgroundColor: Colors.orange,
                  labelStyle: TextStyle(color: Colors.white),
                ),
            ],
          ),
        ],
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('点击了: ${article.title}')),
        );
      },
    );
  }

  /// 构建条件显示
  Widget? _buildConditionDisplay(ArticleRefreshConditions conditions) {
    final hasConditions = conditions.category != null ||
        (conditions.searchKeyword != null &&
            conditions.searchKeyword!.isNotEmpty) ||
        conditions.sortBy != null ||
        conditions.isPublished != null;

    if (!hasConditions) return null;

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _buildConditionText(conditions),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () {
              // 重置条件
              // 这里需要通过ref来访问，所以需要重构
            },
            child: const Text('清除', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  /// 构建条件文本
  String _buildConditionText(ArticleRefreshConditions conditions) {
    final parts = <String>[];

    if (conditions.category != null) {
      parts.add('分类: ${conditions.category}');
    }
    if (conditions.searchKeyword != null &&
        conditions.searchKeyword!.isNotEmpty) {
      parts.add('搜索: ${conditions.searchKeyword}');
    }
    if (conditions.sortBy != null) {
      parts.add('排序: ${conditions.sortBy}');
    }
    if (conditions.isPublished != null) {
      parts.add('状态: ${conditions.isPublished! ? "已发布" : "草稿"}');
    }

    return parts.join(', ');
  }

  /// 显示筛选对话框
  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _ArticleFilterDialog(),
    );
  }

  /// 获取分类颜色
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'tech':
        return Colors.blue;
      case 'news':
        return Colors.red;
      case 'sports':
        return Colors.green;
      case 'entertainment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// 文章筛选对话框
class _ArticleFilterDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditions = ref.watch(articleRefreshConditionsProvider);

    return AlertDialog(
      title: const Text('筛选条件'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 分类选择
          DropdownButtonFormField<String>(
            value: conditions.category,
            decoration: const InputDecoration(labelText: '分类'),
            items: const [
              DropdownMenuItem(value: null, child: Text('全部')),
              DropdownMenuItem(value: 'tech', child: Text('科技')),
              DropdownMenuItem(value: 'news', child: Text('新闻')),
              DropdownMenuItem(value: 'sports', child: Text('体育')),
              DropdownMenuItem(value: 'entertainment', child: Text('娱乐')),
            ],
            onChanged: (value) {
              ref
                  .read(articleRefreshConditionsProvider.notifier)
                  .updateCategory(value);
            },
          ),

          const SizedBox(height: 16),

          // 搜索关键词
          TextField(
            decoration: const InputDecoration(
              labelText: '搜索关键词',
              hintText: '输入文章标题关键词',
            ),
            controller:
                TextEditingController(text: conditions.searchKeyword ?? ''),
            onChanged: (value) {
              ref
                  .read(articleRefreshConditionsProvider.notifier)
                  .updateSearchKeyword(value.isEmpty ? null : value);
            },
          ),

          const SizedBox(height: 16),

          // 排序方式
          DropdownButtonFormField<String>(
            value: conditions.sortBy,
            decoration: const InputDecoration(labelText: '排序方式'),
            items: const [
              DropdownMenuItem(value: null, child: Text('默认')),
              DropdownMenuItem(value: 'date', child: Text('按日期')),
              DropdownMenuItem(value: 'title', child: Text('按标题')),
              DropdownMenuItem(value: 'author', child: Text('按作者')),
            ],
            onChanged: (value) {
              ref
                  .read(articleRefreshConditionsProvider.notifier)
                  .updateSortBy(value);
            },
          ),

          const SizedBox(height: 16),

          // 发布状态
          DropdownButtonFormField<bool>(
            value: conditions.isPublished,
            decoration: const InputDecoration(labelText: '发布状态'),
            items: const [
              DropdownMenuItem(value: null, child: Text('全部')),
              DropdownMenuItem(value: true, child: Text('已发布')),
              DropdownMenuItem(value: false, child: Text('草稿')),
            ],
            onChanged: (value) {
              ref
                  .read(articleRefreshConditionsProvider.notifier)
                  .updateIsPublished(value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref
                .read(articleRefreshConditionsProvider.notifier)
                .resetConditions();
            Navigator.of(context).pop();
          },
          child: const Text('重置'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
