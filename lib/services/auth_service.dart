import 'dart:async';
import '../models/user.dart';

class AuthService {
  const AuthService();
  // 模拟用户数据
  static final Map<String, User> _users = {
    '13800138000': User(
      id: '1',
      name: '测试用户',
      phone: '13800138000',
      createdAt: DateTime.now(),
    ),
  };

  // 发送验证码
  Future<void> sendVerificationCode(String phone) async {
    // 模拟发送验证码
    await Future.delayed(const Duration(seconds: 1));
    // TODO: 实现实际的验证码发送逻辑
  }

  // 手机号登录
  Future<User?> loginWithPhone(String phone, String code) async {
    // 模拟登录
    await Future.delayed(const Duration(seconds: 1));
    // TODO: 实现实际的登录逻辑
    if (code != '123456') {
      throw Exception('验证码错误');
    }

    // 检查用户是否存在
    if (_users.containsKey(phone)) {
      return _users[phone];
    }

    // 创建新用户
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '用户${phone.substring(7)}',
      phone: phone,
      createdAt: DateTime.now(),
    );
    _users[phone] = user;
    return user;
  }

  // 微信登录
  Future<User?> loginWithWechat() async {
    // 模拟微信登录
    await Future.delayed(const Duration(seconds: 1));
    // TODO: 实现实际的微信登录逻辑
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '微信用户',
      wechatId: 'wx_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    return user;
  }

  // 退出登录
  Future<void> logout() async {
    // 模拟退出登录
    await Future.delayed(const Duration(seconds: 1));
    // TODO: 实现实际的退出登录逻辑
  }
} 