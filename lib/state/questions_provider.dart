import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/http/question.dart';
import 'package:imath/models/question.dart';
import 'package:imath/models/quiz.dart';
import 'package:imath/state/settings_provider.dart';

// 分类ID提供者
final categoryIdProvider = StateProvider<int>((ref) => ALL_CATEGORY);

// 页码提供者
final pageNoProvider = StateProvider<int>((ref) => 1);

// 是否正在加载的提供者
final isLoadingProvider = StateProvider<bool>((ref) => false);

// 是否还有更多数据的提供者
final hasMoreProvider = StateProvider<bool>((ref) => true);

class QuestionsNotifier extends AsyncNotifier<List<Question>> {

  @override
  Future<List<Question>> build() async {
    MATH_LEVEL level = ref.watch(mathLevelProvider);
    final newQuestions = await loadMoreQuestions(ALL_CATEGORY, 1, level.value);
    return newQuestions;
  }

  void onChangeCategory(int newCategoryId) async {
    if (ref.read(categoryIdProvider) == newCategoryId) {
      return;
    }
    state.value?.clear();
    ref.read(pageNoProvider.notifier).state = 1;
    ref.read(categoryIdProvider.notifier).state = newCategoryId;
    final newQuestions = await loadMoreQuestions(newCategoryId, 1, ref.watch(mathLevelProvider).value);
    // state.value?.addAll(newQuestions);

    state = AsyncValue.data(newQuestions);
    // await future;
  }

  void onChangePageNo(int newPageNo) async {
    // state = AsyncValue.loading();
    int categoryId = ref.read(categoryIdProvider);
    final newQuestions = await loadMoreQuestions(categoryId, newPageNo, ref.watch(mathLevelProvider).value);
    // state.value?.addAll(newQuestions);
    ref.read(pageNoProvider.notifier).state = newPageNo;
    state = AsyncValue.data([...?state.value, ...newQuestions]);
    // state = AsyncValue.data(questions);
  }

  // 新增：刷新题目列表的方法
  void refreshQuestions() async {
    // 重置页码
    ref.read(pageNoProvider.notifier).state = 1;
    ref.read(hasMoreProvider.notifier).state = true;
    
    // 重新加载第一页数据
    int categoryId = ref.read(categoryIdProvider);
    final newQuestions = await loadMoreQuestions(categoryId, 1, ref.watch(mathLevelProvider).value);
    state = AsyncValue.data(newQuestions);
  }
}

final questionsProvider = AsyncNotifierProvider<QuestionsNotifier, List<Question>>(QuestionsNotifier.new);

Future loadMoreQuestions(int categoryId, int pageNo, String level) async {
  // 重新加载第一页数据

  // 调用API加载数据
  final response = await QuestionHttp.loadQuestions(
    categoryId: categoryId,
    pageNo: pageNo,
    pageSize: 10,
    level: level,
  );

  final content = response['data'] ?? [];
  final newQuestions = content.map<Question?>((json) {
    try {
      return Question.fromJson(json);
    } catch (e) {
      return null;
    }
  }).whereType<Question>().toList();
  return newQuestions;
}

// 自动触发的FutureProvider（可选）
final autoQuestionsFutureProvider = FutureProvider.autoDispose<void>((ref) async {
  // 确保有初始值
  if (ref.read(categoryIdProvider) == -1) {
    ref.read(categoryIdProvider.notifier).state = ALL_CATEGORY;
  }
  
  // 触发主FutureProvider
  // ref.refresh(questionsFutureProvider);
});

// 监听分类变化，重置页码并重新加载
final categoryChangeProvider = Provider<void>((ref) {
  ref.watch(categoryIdProvider);
  // 注意：这里不直接修改其他provider的状态，避免无限循环
  // 实际的逻辑在 questionsFutureProvider 中处理
});

// 监听页码变化，加载更多数据
final pageChangeProvider = Provider<void>((ref) {
  ref.watch(pageNoProvider);
  // 注意：这里不直接修改其他provider的状态，避免无限循环
  // 实际的逻辑在 questionsFutureProvider 中处理
});
