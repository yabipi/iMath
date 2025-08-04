import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imath/widgets/refresh/constructor.dart';
import 'package:imath/widgets/refresh/paging_mixin.dart';

/// 用户数据模型
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

/// 刷新条件状态
class RefreshConditions {
  final int page;
  final String? category;
  final String? searchKeyword;
  final String? sortBy;
  final bool? isActive;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const RefreshConditions({
    this.page = 1,
    this.category,
    this.searchKeyword,
    this.sortBy,
    this.isActive,
    this.dateFrom,
    this.dateTo,
  });

  RefreshConditions copyWith({
    int? page,
    String? category,
    String? searchKeyword,
    String? sortBy,
    bool? isActive,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearPage = false,
  }) {
    return RefreshConditions(
      page: clearPage ? 1 : (page ?? this.page),
      category: category ?? this.category,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      sortBy: sortBy ?? this.sortBy,
      isActive: isActive ?? this.isActive,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RefreshConditions &&
        other.page == page &&
        other.category == category &&
        other.searchKeyword == searchKeyword &&
        other.sortBy == sortBy &&
        other.isActive == isActive &&
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
      isActive,
      dateFrom,
      dateTo,
    );
  }

  @override
  String toString() {
    return 'RefreshConditions(page: $page, category: $category, searchKeyword: $searchKeyword, sortBy: $sortBy, isActive: $isActive, dateFrom: $dateFrom, dateTo: $dateTo)';
  }
}

/// 刷新条件状态提供者
final refreshConditionsProvider =
    StateNotifierProvider<RefreshConditionsNotifier, RefreshConditions>(
  (ref) => RefreshConditionsNotifier(),
);

/// 刷新条件状态管理器
class RefreshConditionsNotifier extends StateNotifier<RefreshConditions> {
  RefreshConditionsNotifier() : super(const RefreshConditions());

  /// 更新页码
  void updatePage(int page) {
    state = state.copyWith(page: page);
  }

  /// 更新分类
  void updateCategory(String? category) {
    state = state.copyWith(category: category, clearPage: true);
  }

  /// 更新搜索关键词
  void updateSearchKeyword(String? keyword) {
    state = state.copyWith(searchKeyword: keyword, clearPage: true);
  }

  /// 更新排序方式
  void updateSortBy(String? sortBy) {
    state = state.copyWith(sortBy: sortBy, clearPage: true);
  }

  /// 更新激活状态
  void updateIsActive(bool? isActive) {
    state = state.copyWith(isActive: isActive, clearPage: true);
  }

  /// 更新日期范围
  void updateDateRange(DateTime? dateFrom, DateTime? dateTo) {
    state = state.copyWith(dateFrom: dateFrom, dateTo: dateTo, clearPage: true);
  }

  /// 重置所有条件
  void resetConditions() {
    state = const RefreshConditions();
  }

  /// 刷新数据（重置页码）
  void refresh() {
    state = state.copyWith(page: 1);
  }
}

/// 用户列表数据状态
class UserListState {
  final List<User> users;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int totalCount;

  const UserListState({
    this.users = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.totalCount = 0,
  });

  UserListState copyWith({
    List<User>? users,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? totalCount,
  }) {
    return UserListState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// 用户列表数据提供者
final userListProvider = StateNotifierProvider<UserListNotifier, UserListState>(
  (ref) => UserListNotifier(ref),
);

/// 用户列表数据管理器
class UserListNotifier extends StateNotifier<UserListState> {
  final Ref _ref;

  UserListNotifier(this._ref) : super(const UserListState()) {
    // 监听刷新条件变化
    _ref.listen<RefreshConditions>(
      refreshConditionsProvider,
      (previous, next) {
        if (previous != next) {
          _loadData(next);
        }
      },
    );
  }

  /// 加载数据
  Future<void> _loadData(RefreshConditions conditions) async {
    if (conditions.page == 1) {
      // 第一页，重置数据
      state = state.copyWith(isLoading: true, error: null, users: []);
    } else {
      // 加载更多，保持现有数据
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      // 模拟网络请求
      await Future.delayed(const Duration(milliseconds: 500));

      // 根据条件生成数据
      final newUsers = _generateUsers(conditions);

      if (conditions.page == 1) {
        // 第一页，替换数据
        state = state.copyWith(
          users: newUsers,
          isLoading: false,
          hasMore: newUsers.length == 10, // 假设每页10条
          totalCount: 100, // 模拟总数
        );
      } else {
        // 加载更多，追加数据
        final allUsers = [...state.users, ...newUsers];
        state = state.copyWith(
          users: allUsers,
          isLoading: false,
          hasMore: newUsers.length == 10,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 根据条件生成用户数据
  List<User> _generateUsers(RefreshConditions conditions) {
    final users = <User>[];
    final baseIndex = (conditions.page - 1) * 10;

    for (int i = 0; i < 10; i++) {
      final index = baseIndex + i;

      // 根据搜索条件过滤
      if (conditions.searchKeyword != null &&
          conditions.searchKeyword!.isNotEmpty) {
        final name = 'name $conditions.page-$i';
        if (!name
            .toLowerCase()
            .contains(conditions.searchKeyword!.toLowerCase())) {
          continue;
        }
      }

      // 根据分类过滤
      if (conditions.category != null && conditions.category != 'all') {
        // 模拟分类过滤逻辑
        if (index % 2 == 0 && conditions.category == 'even') {
          // 偶数索引属于even分类
        } else if (index % 2 == 1 && conditions.category == 'odd') {
          // 奇数索引属于odd分类
        } else {
          continue;
        }
      }

      users.add(User(
        name: 'name ${conditions.page}-$i',
        avatar: 'https://picsum.photos/200/300?random=${conditions.page}-$i',
        desc: 'desc ${conditions.page}-$i (${conditions.category ?? 'all'})',
      ));
    }

    return users;
  }

  /// 刷新数据
  Future<void> refresh() async {
    _ref.read(refreshConditionsProvider.notifier).refresh();
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final currentConditions = _ref.read(refreshConditionsProvider);
    final nextPage = currentConditions.page + 1;
    _ref.read(refreshConditionsProvider.notifier).updatePage(nextPage);
  }
}

/// 使用Riverpod的无限下拉列表页面
class EasyRefreshListRiverpodScreen extends ConsumerStatefulWidget {
  const EasyRefreshListRiverpodScreen({super.key});

  @override
  ConsumerState<EasyRefreshListRiverpodScreen> createState() =>
      _EasyRefreshListRiverpodScreenState();
}

class _EasyRefreshListRiverpodScreenState
    extends ConsumerState<EasyRefreshListRiverpodScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 初始加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userListState = ref.watch(userListProvider);
    final refreshConditions = ref.watch(refreshConditionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('无限下拉列表 (Riverpod)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 条件显示区域
          if (refreshConditions.category != null ||
              refreshConditions.searchKeyword != null ||
              refreshConditions.sortBy != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '筛选条件: ${_buildConditionText(refreshConditions)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(refreshConditionsProvider.notifier)
                          .resetConditions();
                    },
                    child: const Text('清除', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          // 列表区域
          Expanded(
            child: _buildList(userListState),
          ),
        ],
      ),
    );
  }

  /// 构建列表
  Widget _buildList(UserListState state) {
    if (state.isLoading && state.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(userListProvider.notifier).refresh(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (state.users.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          // 滚动到底部，加载更多
          ref.read(userListProvider.notifier).loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref.read(userListProvider.notifier).refresh(),
        child: ListView.separated(
          controller: _scrollController,
          itemCount: state.users.length + (state.hasMore ? 1 : 0),
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            if (index == state.users.length) {
              // 加载更多指示器
              return Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: state.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('没有更多数据了'),
                ),
              );
            }

            final user = state.users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.avatar),
              ),
              title: Text(user.name),
              subtitle: Text(user.desc ?? ''),
            );
          },
        ),
      ),
    );
  }

  /// 构建条件文本
  String _buildConditionText(RefreshConditions conditions) {
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

    return parts.join(', ');
  }

  /// 显示筛选对话框
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(),
    );
  }
}

/// 筛选对话框
class _FilterDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditions = ref.watch(refreshConditionsProvider);

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
              DropdownMenuItem(value: 'all', child: Text('所有')),
              DropdownMenuItem(value: 'even', child: Text('偶数')),
              DropdownMenuItem(value: 'odd', child: Text('奇数')),
            ],
            onChanged: (value) {
              ref
                  .read(refreshConditionsProvider.notifier)
                  .updateCategory(value);
            },
          ),

          const SizedBox(height: 16),

          // 搜索关键词
          TextField(
            decoration: const InputDecoration(
              labelText: '搜索关键词',
              hintText: '输入搜索关键词',
            ),
            controller:
                TextEditingController(text: conditions.searchKeyword ?? ''),
            onChanged: (value) {
              ref
                  .read(refreshConditionsProvider.notifier)
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
              DropdownMenuItem(value: 'name', child: Text('按名称')),
              DropdownMenuItem(value: 'date', child: Text('按日期')),
            ],
            onChanged: (value) {
              ref.read(refreshConditionsProvider.notifier).updateSortBy(value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(refreshConditionsProvider.notifier).resetConditions();
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
