import 'package:imath/config/api_config.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';

import 'init.dart';

class CategoryHttp {

  static Future getCategories() async {
    try {
      final response = await Request().get(
          '${ApiConfig.SERVER_BASE_URL}/api/category/list'
      );

      if (response.statusCode == 200) {
        // final data = json.decode(response.body);
        final categories = response.data;
        Map<int, String> _categories = {};
        for (var item in categories) {
          _categories[item['ID']] = item['CategoryName'];
        }
        Context().set(CATEGORIES_KEY, _categories);

        return categories;
      }
    } catch (e) {}
  }
}