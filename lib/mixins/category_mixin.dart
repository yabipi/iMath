import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/core/global.dart';
import 'package:imath/state/settings_provider.dart';


mixin CategoryMixin {
  Map<String, String> getCategories(WidgetRef ref) {
    Map<String, String> categories = Map();
    final MATH_LEVEL level = ref.watch(mathLevelProvider);
    if (level == MATH_LEVEL.Primary) {
      categories = Global.get(MATH_LEVEL.Primary.value);
    } else if (level == MATH_LEVEL.Advanced) {
      categories = Global.get(MATH_LEVEL.Advanced.value);
    }
    return categories;
  }
}