import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

mixin MyMixin {
  /// 初始页码
  int _initPage = 1;
  void test1() {
    print('test1');
  }

  void sayHello();

  void increment() {
    _initPage++;
    print(_initPage);
  }
}

class MyClass with MyMixin {
  void sayHello() {
    print('hello');
  }
}

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
    // Map<int, String> _categories = {1:'1', 2:'2'};
    // final result = jsonEncode(_categories);
    // final jsonData = jsonDecode(result);
    // print(result);
  });

  group('test3', () {
    print('test3');
    MyMixin mix = MyClass();

    mix.increment();
    mix.sayHello();
  });
}