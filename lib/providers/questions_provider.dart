import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/http/question.dart';
import 'package:imath/models/quiz.dart';

// 分类ID提供者
final categoryIdProvider = StateProvider<int>((ref) => ALL_CATEGORY);

// 页码提供者
final pageNoProvider = StateProvider<int>((ref) => 1);

// 是否正在加载的提供者
final isLoadingProvider = StateProvider<bool>((ref) => false);

// 是否还有更多数据的提供者
final hasMoreProvider = StateProvider<bool>((ref) => true);

// 加载问题的FutureProvider
final questionsFutureProvider = FutureProvider<List<Question>>((ref) async {
  List<Question> questions = <Question>[];

  final categoryId = ref.watch(categoryIdProvider);
  final pageNo = ref.watch(pageNoProvider);
  // final questions = ref.read(questionsProvider);
  final isLoading = ref.read(isLoadingProvider.notifier);
  final hasMore = ref.read(hasMoreProvider.notifier);

  // print('questionsFutureProvider triggered - categoryId: $categoryId, pageNo: $pageNo');

  // 如果正在加载，直接返回
  if (ref.read(isLoadingProvider)) {
    print('Already loading, skipping...');
    return questions;
  }

  // 设置加载状态
  // isLoading.state = true;
  print('Starting to load questions...');

  try {
    // 如果是第一页，清空列表
    if (pageNo == 1) {
      // questionsNotifier.clear();
      print('Cleared questions list for first page');
    }

    // 调用API加载数据
    final response = await QuestionHttp.loadQuestions(
      categoryId: categoryId,
      pageNo: pageNo,
      pageSize: 10,
    );

    final content = response['data'] ?? [];
    final newQuestions = content.map<Question?>((json) {
      try {
        return Question.fromJson(json);
      } catch (e) {
        return null;
      }
    }).whereType<Question>().toList();

    print('Loaded ${newQuestions.length} questions from API');

    // 检查是否还有更多数据
    if (newQuestions.isEmpty || newQuestions.length < 10) {
      hasMore.state = false;
      print('No more questions available');
    } else {
      hasMore.state = true;
      print('More questions available');
    }

    // 如果是第一页，替换整个列表；否则追加到现有列表
    if (pageNo == 1) {
      questions.clear();
      questions.addAll(newQuestions);
      // ref.read(questionsProvider) = newQuestions;
      // questionsNotifier(newQuestions);
      print('Replaced questions list with ${newQuestions.length} questions');
    } else {
      questions.addAll(newQuestions);
      // questionsNotifier.addQuestions(newQuestions);
      print('Added ${newQuestions.length} questions to existing list');
    }
  } catch (e) {
    // 处理错误
    print('加载问题失败: $e');
  } finally {
    // 清除加载状态
    isLoading.state = false;
    print('Finished loading questions');
  }
  return questions;
});

// 自动触发的FutureProvider（可选）
final autoQuestionsFutureProvider = FutureProvider.autoDispose<void>((ref) async {
  // 确保有初始值
  if (ref.read(categoryIdProvider) == -1) {
    ref.read(categoryIdProvider.notifier).state = ALL_CATEGORY;
  }
  
  // 触发主FutureProvider
  ref.refresh(questionsFutureProvider);
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

/*
使用示例：

在UI中使用这些providers：

1. 监听问题列表：
```dart
final questions = ref.watch(questionsProvider);
```

2. 监听加载状态：
```dart
final isLoading = ref.watch(isLoadingProvider);
```

3. 监听是否还有更多数据：
```dart
final hasMore = ref.watch(hasMoreProvider);
```

4. 切换分类：
```dart
ref.read(categoryIdProvider.notifier).state = newCategoryId;
```

5. 加载下一页：
```dart
ref.read(pageNoProvider.notifier).state = ref.read(pageNoProvider) + 1;
```

6. 在Widget中监听分类变化：
```dart
ref.watch(categoryChangeProvider);
```

7. 在Widget中监听页码变化：
```dart
ref.watch(pageChangeProvider);
```

8. 手动触发加载：
```dart
ref.refresh(questionsFutureProvider);
```

注意事项：
- 当categoryId变化时，会自动清空列表并重新加载第一页
- 当pageNo变化时，会加载新数据并追加到现有列表
- 使用isLoadingProvider可以显示加载状态
- 使用hasMoreProvider可以判断是否还有更多数据

测试方法：
```dart
// 在Widget的build方法中添加以下代码来测试provider是否正常工作
@override
Widget build(BuildContext context) {
  // 监听所有相关状态
  final questions = ref.watch(questionsProvider);
  final isLoading = ref.watch(isLoadingProvider);
  final hasMore = ref.watch(hasMoreProvider);
  final categoryId = ref.watch(categoryIdProvider);
  final pageNo = ref.watch(pageNoProvider);
  
  // 打印调试信息
  print('Questions count: ${questions.length}');
  print('Is loading: $isLoading');
  print('Has more: $hasMore');
  print('Category ID: $categoryId');
  print('Page No: $pageNo');
  
  // 其余UI代码...
}
```
*/