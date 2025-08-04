import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 通用的刷新条件基类
abstract class BaseRefreshConditions {
  final int page;

  const BaseRefreshConditions({this.page = 1});

  BaseRefreshConditions copyWith({int? page, bool clearPage = false});

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}

/// 通用的列表状态基类
abstract class BaseListState<T> {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int totalCount;

  const BaseListState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.totalCount = 0,
  });

  BaseListState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? totalCount,
  });
}

/// 通用的列表数据管理器接口
abstract class BaseListNotifier<T, C extends BaseRefreshConditions,
    S extends BaseListState<T>> extends StateNotifier<S> {
  final Ref _ref;
  final StateNotifierProvider<dynamic, C> conditionsProvider;

  BaseListNotifier(this._ref, this.conditionsProvider, super.initialState) {
    // 监听刷新条件变化
    _ref.listen<C>(
      conditionsProvider,
      (previous, next) {
        if (previous != next) {
          _handleLoadData(next);
        }
      },
    );
  }

  /// 创建初始状态（子类重写）
  S createInitialState() {
    throw UnimplementedError('子类必须重写 createInitialState 方法');
  }

  /// 处理数据加载
  Future<void> _handleLoadData(C conditions) async {
    if (conditions.page == 1) {
      // 第一页，重置数据
      state = state.copyWith(isLoading: true, error: null, items: []) as S;
    } else {
      // 加载更多，保持现有数据
      state = state.copyWith(isLoading: true, error: null) as S;
    }

    try {
      // 生成数据
      final newItems = await generateData(conditions);

      if (conditions.page == 1) {
        // 第一页，替换数据
        state = state.copyWith(
          items: newItems,
          isLoading: false,
          hasMore: newItems.length == getPageSize(),
          totalCount: getTotalCount(newItems),
        ) as S;
      } else {
        // 加载更多，追加数据
        final allItems = [...state.items, ...newItems];
        state = state.copyWith(
          items: allItems,
          isLoading: false,
          hasMore: newItems.length == getPageSize(),
        ) as S;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      ) as S;
    }
  }

  /// 生成数据（子类实现）
  Future<List<T>> generateData(C conditions);

  /// 刷新数据
  Future<void> refresh() async {
    final notifier = _ref.read(conditionsProvider.notifier);
    if (notifier is BaseRefreshConditionsNotifier) {
      notifier.refresh();
    }
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final currentConditions = _ref.read(conditionsProvider);
    final nextPage = currentConditions.page + 1;

    final notifier = _ref.read(conditionsProvider.notifier);
    if (notifier is BaseRefreshConditionsNotifier) {
      notifier.updatePage(nextPage);
    }
  }

  /// 获取每页大小（子类可重写）
  int getPageSize() => 10;

  /// 获取总数（子类可重写）
  int getTotalCount(List<T> items) => 100;
}

/// 通用的刷新条件管理器基类
abstract class BaseRefreshConditionsNotifier<C extends BaseRefreshConditions>
    extends StateNotifier<C> {
  BaseRefreshConditionsNotifier(super.initialState);

  /// 更新页码
  void updatePage(int page) {
    state = state.copyWith(page: page) as C;
  }

  /// 刷新数据（重置页码）
  void refresh() {
    state = state.copyWith(page: 1) as C;
  }

  /// 重置所有条件
  void resetConditions() {
    state = createInitialState();
  }

  /// 创建初始状态（子类实现）
  C createInitialState();
}

/// 通用的可扩展刷新列表组件
class ExtensibleRefreshList<T, C extends BaseRefreshConditions,
    S extends BaseListState<T>> extends ConsumerStatefulWidget {
  final StateNotifierProvider<BaseListNotifier<T, C, S>, S> listProvider;
  final StateNotifierProvider<BaseRefreshConditionsNotifier<C>, C>
      conditionsProvider;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Widget? header;
  final Widget? emptyView;
  final Widget? loadingView;
  final Widget? errorView;
  final Widget? filterButton;
  final Widget? Function(C conditions)? conditionDisplayBuilder;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final bool enablePullToRefresh;
  final bool enableInfiniteScroll;
  final ScrollController? scrollController;

  const ExtensibleRefreshList({
    super.key,
    required this.listProvider,
    required this.conditionsProvider,
    required this.itemBuilder,
    this.separatorBuilder,
    this.header,
    this.emptyView,
    this.loadingView,
    this.errorView,
    this.filterButton,
    this.conditionDisplayBuilder,
    this.onRefresh,
    this.onLoadMore,
    this.enablePullToRefresh = true,
    this.enableInfiniteScroll = true,
    this.scrollController,
  });

  @override
  ConsumerState<ExtensibleRefreshList<T, C, S>> createState() =>
      _ExtensibleRefreshListState<T, C, S>();
}

class _ExtensibleRefreshListState<T, C extends BaseRefreshConditions,
        S extends BaseListState<T>>
    extends ConsumerState<ExtensibleRefreshList<T, C, S>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();

    // 初始加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(widget.listProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(widget.listProvider);
    final conditions = ref.watch(widget.conditionsProvider);

    return Column(
      children: [
        // 条件显示区域
        if (widget.conditionDisplayBuilder != null)
          widget.conditionDisplayBuilder!(conditions) ??
              const SizedBox.shrink(),

        // 列表区域
        Expanded(
          child: _buildList(listState),
        ),
      ],
    );
  }

  /// 构建列表
  Widget _buildList(S state) {
    if (state.isLoading && state.items.isEmpty) {
      return widget.loadingView ??
          const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return widget.errorView ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('加载失败: ${state.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(widget.listProvider.notifier).refresh(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
    }

    if (state.items.isEmpty) {
      return widget.emptyView ?? const Center(child: Text('暂无数据'));
    }

    Widget listWidget;

    if (widget.separatorBuilder != null) {
      listWidget = ListView.separated(
        controller: _scrollController,
        itemCount: state.items.length +
            (state.hasMore && widget.enableInfiniteScroll ? 1 : 0),
        separatorBuilder: widget.separatorBuilder!,
        itemBuilder: (context, index) => _buildItem(context, index, state),
      );
    } else {
      listWidget = ListView.builder(
        controller: _scrollController,
        itemCount: state.items.length +
            (state.hasMore && widget.enableInfiniteScroll ? 1 : 0),
        itemBuilder: (context, index) => _buildItem(context, index, state),
      );
    }

    // 添加滚动监听
    if (widget.enableInfiniteScroll) {
      listWidget = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            // 滚动到底部，加载更多
            if (widget.onLoadMore != null) {
              widget.onLoadMore!();
            } else {
              ref.read(widget.listProvider.notifier).loadMore();
            }
          }
          return false;
        },
        child: listWidget,
      );
    }

    // 添加下拉刷新
    if (widget.enablePullToRefresh) {
      listWidget = RefreshIndicator(
        onRefresh: () async {
          if (widget.onRefresh != null) {
            widget.onRefresh!();
          } else {
            ref.read(widget.listProvider.notifier).refresh();
          }
        },
        child: listWidget,
      );
    }

    return listWidget;
  }

  /// 构建列表项
  Widget _buildItem(BuildContext context, int index, S state) {
    if (index == state.items.length) {
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

    return widget.itemBuilder(context, index, state.items[index]);
  }
}

/// 通用的筛选对话框基类
abstract class BaseFilterDialog<C extends BaseRefreshConditions>
    extends ConsumerWidget {
  const BaseFilterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref);

  /// 构建筛选表单（子类实现）
  Widget buildFilterForm(BuildContext context, WidgetRef ref, C conditions);

  /// 获取条件提供者（子类实现）
  StateNotifierProvider<BaseRefreshConditionsNotifier<C>, C>
      getConditionsProvider();
}

/// 通用的筛选对话框实现
class GenericFilterDialog<C extends BaseRefreshConditions>
    extends BaseFilterDialog<C> {
  final StateNotifierProvider<BaseRefreshConditionsNotifier<C>, C>
      conditionsProvider;
  final Widget Function(BuildContext context, WidgetRef ref, C conditions)
      formBuilder;

  const GenericFilterDialog({
    super.key,
    required this.conditionsProvider,
    required this.formBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditions = ref.watch(conditionsProvider);

    return AlertDialog(
      title: const Text('筛选条件'),
      content: formBuilder(context, ref, conditions),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(conditionsProvider.notifier).resetConditions();
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

  @override
  Widget buildFilterForm(BuildContext context, WidgetRef ref, C conditions) {
    return formBuilder(context, ref, conditions);
  }

  @override
  StateNotifierProvider<BaseRefreshConditionsNotifier<C>, C>
      getConditionsProvider() {
    return conditionsProvider;
  }
}
