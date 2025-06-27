import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

class MyClass {
  final String name;
  final int age;

  MyClass(this.name, this.age);

  factory MyClass.fromJson(Map<String, dynamic> json) {
    return MyClass(json['name'], json['age']);
  }
}

void main() {
  group('test1', () {
    final obj = MyClass('kuku', 50);
    print("${obj.name} age is ${obj.age}");
  });

}