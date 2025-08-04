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