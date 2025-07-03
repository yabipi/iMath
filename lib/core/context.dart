
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/db/Storage.dart';
import 'package:imath/models/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // 显示的堆栈帧数
    errorMethodCount: 8, // 错误堆栈帧数
    lineLength: 120, // 每行最大长度
    colors: true, // 启用彩色输出
    printEmojis: true, // 显示表情符号
    printTime: false, // 是否显示时间
  ),
);

extension Context on BuildContext{
  // 私有构造函数，防止外部实例化
  // Context._internal();

  // 静态变量保存唯一的实例
  // static final Context _instance = Context._internal();

  // 工厂方法返回唯一的实例
  // factory Context() => _instance;

  static final Map<String, dynamic> _data = {};
  static String? token = null;
  static User? currentUser;

  void showMsg(String msg) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void showDlg(String msg) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }


  void refreshToken() {
    token = GStorage.userInfo.get('token') ?? '';
    if (token!.isNotEmpty) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
        // final role = decodedToken['role'];
        // print('Role: $role');
        currentUser = User(username: decodedToken['username']);
        print(currentUser?.username);
        // final exp = decodedToken['exp'];
        // 格式化 exp 时间戳为可读的日期时间格式
        // final formattedExp = DateTime.fromMillisecondsSinceEpoch(exp * 1000).toString();
        // print('Token Expiration Time: $formattedExp');
      } catch (e) {
        log('Error decoding token: $e');
      }
    }
  }

  // 设置键值对
  void set(String key, dynamic value) {
    _data[key] = value;
  }

  // 获取键值对
  dynamic get(String key) {
    return _data[key];
  }

  // 删除键值对
  void remove(String key) {
    _data.remove(key);
  }

  User? getCurrentUser() {
    return currentUser;
  }

  int getCategoryId(String category) {
    Map<String, dynamic> categories = get(CATEGORIES_KEY);
    return categories[category] as int;
  }

  bool isLoggedIn() {
    bool hasExpired = JwtDecoder.isExpired(token!);
    if (!hasExpired) {
      return true;
    } else {
      return false;
    }
  }

  void logout() {
    GStorage.userInfo.delete('token');
    token = null;
    currentUser = null;
  }
}


String version() {
  return '1.0.0';
}