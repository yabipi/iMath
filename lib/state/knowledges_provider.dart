import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imath/config/api_config.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/http/init.dart';
import 'package:imath/http/knowledge.dart';
import 'package:imath/models/knowledges.dart';
import 'package:imath/utils/data_util.dart';

import 'settings_provider.dart';

// 分类ID提供者
final knowledgeCategoryProvider = StateProvider<int>((ref) => ALL_CATEGORY);

class KnowledgesNotifier extends AsyncNotifier<List<Knowledge>>{
  @override
  Future<List<Knowledge>> build() async {
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

final knowledgesProvider = AsyncNotifierProvider<KnowledgesNotifier, List<Knowledge>>(KnowledgesNotifier.new);

Future<List<Knowledge>> fetchKnowledges(MATH_LEVEL level, int category) async {
  final result = await KnowledgeHttp.listKnowledges(level, category);
  final items = DataUtils.dataAsList(result['data'], Knowledge.fromJson);
  return items;
}