
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/db/Storage.dart';
import 'package:imath/models/user.dart';
import 'package:imath/state/global_state.dart';
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

  // static final Map<String, dynamic> _data = {};

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

  int getCategoryId(String category) {
    Map<String, dynamic> categories = GlobalState.get(CATEGORIES_KEY);
    return categories[category] as int;
  }


}


String version() {
  return '1.0.0';
}