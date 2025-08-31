import 'package:shared_preferences/shared_preferences.dart';

/// 存储工具类
class StorageUtil {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  
  /// 获取token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  /// 保存token
  static Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_tokenKey, token);
  }
  
  /// 移除token
  static Future<bool> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_tokenKey);
  }
  
  /// 获取用户ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }
  
  /// 保存用户ID
  static Future<bool> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_userIdKey, userId);
  }
  
  /// 获取用户名
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }
  
  /// 保存用户名
  static Future<bool> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_usernameKey, username);
  }
  
  /// 清除所有用户数据
  static Future<bool> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
  
  /// 检查是否已登录
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
