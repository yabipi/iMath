# 可扩展刷新列表组件 (Extensible Refresh List)

这是一个基于Riverpod的可扩展刷新列表组件，支持多种刷新条件和数据类型的无限下拉列表。

## 🎯 主要特性

- ✅ **多条件刷新**: 支持分类、搜索、排序、状态等多种刷新条件
- ✅ **类型安全**: 使用泛型确保类型安全
- ✅ **状态管理**: 基于Riverpod的状态管理
- ✅ **无限滚动**: 支持无限下拉加载更多
- ✅ **下拉刷新**: 支持下拉刷新功能
- ✅ **条件显示**: 实时显示当前筛选条件
- ✅ **错误处理**: 完善的错误处理和重试机制
- ✅ **可扩展**: 易于扩展新的数据类型和刷新条件

## 📁 文件结构

```
lib/widgets/refresh/
├── extensible_refresh_list.dart          # 通用可扩展刷新列表组件
├── paging_mixin.dart                     # 原有分页混入（保持兼容）
├── constructor.dart                      # 原有构造函数（保持兼容）
└── README_extensible_refresh.md          # 使用说明
```

## 🚀 快速开始

### 1. 定义数据模型

```dart
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
```

### 2. 定义刷新条件

```dart
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
```

### 3. 定义列表状态

```dart
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
```

### 4. 实现条件管理器

```dart
class ArticleRefreshConditionsNotifier extends BaseRefreshConditionsNotifier<ArticleRefreshConditions> {
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
```

### 5. 实现数据管理器

```dart
class ArticleListNotifier extends BaseListNotifier<Article, ArticleRefreshConditions, ArticleListState> {
  ArticleListNotifier(Ref ref, StateNotifierProvider<BaseRefreshConditionsNotifier<ArticleRefreshConditions>, ArticleRefreshConditions> conditionsProvider)
      : super(ref, conditionsProvider);

  @override
  Future<List<Article>> generateData(ArticleRefreshConditions conditions) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 500));

    final articles = <Article>[];
    final baseIndex = (conditions.page - 1) * getPageSize();

    for (int i = 0; i < getPageSize(); i++) {
      final index = baseIndex + i;
      
      // 根据搜索条件过滤
      if (conditions.searchKeyword != null && conditions.searchKeyword!.isNotEmpty) {
        final title = '文章标题 $index';
        if (!title.toLowerCase().contains(conditions.searchKeyword!.toLowerCase())) {
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
        content: '这是文章 $index 的内容...',
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
```

### 6. 定义提供者

```dart
final articleRefreshConditionsProvider = StateNotifierProvider<ArticleRefreshConditionsNotifier, ArticleRefreshConditions>(
  (ref) => ArticleRefreshConditionsNotifier(),
);

final articleListProvider = StateNotifierProvider<ArticleListNotifier, ArticleListState>(
  (ref) => ArticleListNotifier(ref, articleRefreshConditionsProvider),
);
```

### 7. 使用组件

```dart
class ArticleListPage extends ConsumerWidget {
  const ArticleListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文章列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
          ),
        ],
      ),
      body: ExtensibleRefreshList<Article, ArticleRefreshConditions, ArticleListState>(
        listProvider: articleListProvider,
        conditionsProvider: articleRefreshConditionsProvider,
        itemBuilder: (context, index, article) => _buildArticleItem(context, article),
        separatorBuilder: (context, index) => const Divider(height: 1),
        conditionDisplayBuilder: (conditions) => _buildConditionDisplay(conditions),
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

  Widget _buildArticleItem(BuildContext context, Article article) {
    return ListTile(
      title: Text(article.title),
      subtitle: Text(article.content),
      // ... 更多UI细节
    );
  }

  Widget? _buildConditionDisplay(ArticleRefreshConditions conditions) {
    // 构建条件显示UI
    return null;
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    // 显示筛选对话框
  }
}
```

## 🔧 组件属性

### ExtensibleRefreshList 属性

| 属性 | 类型 | 必需 | 说明 |
|------|------|------|------|
| listProvider | StateNotifierProvider | ✅ | 列表数据提供者 |
| conditionsProvider | StateNotifierProvider | ✅ | 刷新条件提供者 |
| itemBuilder | Widget Function | ✅ | 列表项构建器 |
| separatorBuilder | Widget Function? | ❌ | 分割线构建器 |
| conditionDisplayBuilder | Widget Function? | ❌ | 条件显示构建器 |
| loadingView | Widget? | ❌ | 加载中视图 |
| emptyView | Widget? | ❌ | 空数据视图 |
| errorView | Widget? | ❌ | 错误视图 |
| onRefresh | VoidCallback? | ❌ | 自定义刷新回调 |
| onLoadMore | VoidCallback? | ❌ | 自定义加载更多回调 |
| enablePullToRefresh | bool | ❌ | 是否启用下拉刷新 |
| enableInfiniteScroll | bool | ❌ | 是否启用无限滚动 |
| scrollController | ScrollController? | ❌ | 滚动控制器 |

## 🎨 自定义样式

### 自定义列表项

```dart
itemBuilder: (context, index, article) => Card(
  child: ListTile(
    leading: CircleAvatar(
      backgroundColor: _getCategoryColor(article.category),
      child: Text(article.category[0].toUpperCase()),
    ),
    title: Text(article.title),
    subtitle: Text(article.content),
    trailing: article.isPublished 
      ? const Icon(Icons.check_circle, color: Colors.green)
      : const Icon(Icons.schedule, color: Colors.orange),
  ),
),
```

### 自定义条件显示

```dart
conditionDisplayBuilder: (conditions) {
  final hasConditions = conditions.category != null ||
      (conditions.searchKeyword != null && conditions.searchKeyword!.isNotEmpty) ||
      conditions.sortBy != null;

  if (!hasConditions) return null;

  return Container(
    padding: const EdgeInsets.all(8),
    color: Colors.grey[100],
    child: Row(
      children: [
        const Icon(Icons.filter_list, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(_buildConditionText(conditions)),
        ),
        TextButton(
          onPressed: () => ref.read(conditionsProvider.notifier).resetConditions(),
          child: const Text('清除'),
        ),
      ],
    ),
  );
},
```

## 🔄 刷新条件管理

### 更新条件

```dart
// 更新分类
ref.read(articleRefreshConditionsProvider.notifier).updateCategory('tech');

// 更新搜索关键词
ref.read(articleRefreshConditionsProvider.notifier).updateSearchKeyword('Flutter');

// 更新排序方式
ref.read(articleRefreshConditionsProvider.notifier).updateSortBy('date');

// 更新发布状态
ref.read(articleRefreshConditionsProvider.notifier).updateIsPublished(true);

// 更新日期范围
ref.read(articleRefreshConditionsProvider.notifier).updateDateRange(
  DateTime.now().subtract(const Duration(days: 7)),
  DateTime.now(),
);
```

### 重置条件

```dart
// 重置所有条件
ref.read(articleRefreshConditionsProvider.notifier).resetConditions();

// 刷新数据（重置页码）
ref.read(articleRefreshConditionsProvider.notifier).refresh();
```

## 📱 响应式设计

组件支持响应式设计，可以根据屏幕大小调整布局：

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      // 桌面端布局
      return Row(
        children: [
          // 筛选面板
          SizedBox(
            width: 300,
            child: FilterPanel(),
          ),
          // 列表区域
          Expanded(
            child: ExtensibleRefreshList(...),
          ),
        ],
      );
    } else {
      // 移动端布局
      return ExtensibleRefreshList(...);
    }
  },
),
```

## 🚨 错误处理

组件内置了完善的错误处理机制：

```dart
errorView: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, size: 64, color: Colors.red),
      const SizedBox(height: 16),
      Text('加载失败: ${state.error}'),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () => ref.read(listProvider.notifier).refresh(),
        child: const Text('重试'),
      ),
    ],
  ),
),
```

## 🔧 高级用法

### 自定义分页大小

```dart
@override
int getPageSize() => 20; // 每页20条数据
```

### 自定义总数计算

```dart
@override
int getTotalCount(List<Article> items) {
  // 根据实际业务逻辑计算总数
  return items.length + 100; // 示例：假设还有100条数据
}
```

### 条件变化防抖

```dart
class DebouncedRefreshConditionsNotifier extends BaseRefreshConditionsNotifier<ArticleRefreshConditions> {
  Timer? _debounceTimer;

  void updateSearchKeyword(String? keyword) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(searchKeyword: keyword, clearPage: true);
    });
  }
}
```

## 📋 最佳实践

1. **条件设计**: 将相关的条件组合在一起，避免条件过多导致状态复杂
2. **性能优化**: 使用 `const` 构造函数和 `copyWith` 方法优化性能
3. **错误处理**: 为每个可能的错误情况提供用户友好的提示
4. **加载状态**: 提供清晰的加载状态指示器
5. **空状态**: 为空数据状态提供有意义的提示
6. **条件显示**: 实时显示当前筛选条件，提高用户体验

## 🔄 迁移指南

### 从原有组件迁移

如果你正在使用原有的 `PagingMixin` 组件，可以按以下步骤迁移：

1. **保持原有组件**: 原有组件仍然可用，不会破坏现有功能
2. **逐步迁移**: 可以逐步将新页面迁移到新的可扩展组件
3. **并行使用**: 新旧组件可以并行使用，互不影响

### 迁移步骤

1. 定义新的数据模型和条件类
2. 实现新的状态管理器
3. 替换UI组件
4. 测试功能完整性
5. 移除旧代码

## 🎯 总结

这个可扩展刷新列表组件提供了：

- **强大的扩展性**: 支持任意数据类型和刷新条件
- **类型安全**: 完整的泛型支持
- **状态管理**: 基于Riverpod的响应式状态管理
- **用户体验**: 完善的加载、错误、空状态处理
- **开发效率**: 简化的API和可复用的组件

通过使用这个组件，你可以快速构建功能丰富的列表页面，同时保持代码的可维护性和扩展性。 