//

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('test1', () {
    var nums = <int>{1, 2, 3};
    print(nums);
    Map<String, String> _categories = {'haha':'1', '2':'2'};
    final result = json.encode(_categories);
    print(result);
  });

  group('test2', () {
    // key值不能是String以外类型
    Map<int, String> _categories = {1:'1', 2:'2'};
    final result = jsonEncode(_categories);
    final jsonData = jsonDecode(result);
    print(result);
  });
}