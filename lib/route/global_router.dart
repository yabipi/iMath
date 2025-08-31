import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 全局路由管理器
/// 可以在任何地方使用，无需context
class GlobalRouter {
  static GoRouter? _router;
  
  /// 初始化路由管理器
  static void init(GoRouter router) {
    _router = router;
  }
  
  /// 跳转到登录页
  static void goToLogin() {
    if (_router != null) {
      _router!.go('/login');
    } else {
      debugPrint('GlobalRouter not initialized');
    }
  }
  
  /// 跳转到指定路径
  static void go(String path) {
    if (_router != null) {
      _router!.go(path);
    } else {
      debugPrint('GlobalRouter not initialized');
    }
  }
  
  /// 推入指定路径
  static void push(String path) {
    if (_router != null) {
      _router!.push(path);
    } else {
      debugPrint('GlobalRouter not initialized');
    }
  }
  
  /// 返回上一页
  static void pop() {
    if (_router != null) {
      _router!.pop();
    } else {
      debugPrint('GlobalRouter not initialized');
    }
  }
}
