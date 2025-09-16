import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/db/Storage.dart';
import 'package:imath/models/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// 登录状态
final loggingStateProvider = StateProvider<bool>((ref)  {
  // 先检测是否已登录过期
  String token = GStorage.userInfo.get(Constants.USER_TOKEN) ?? '';
  if (token.isEmpty) {
    return false;
  }
  bool hasExpired = JwtDecoder.isExpired(token);
  DateTime expiredDate = JwtDecoder.getExpirationDate(token);
  print(expiredDate);
  return !hasExpired && GlobalState.currentUser != null;
});

class GlobalState {
  static final _state = Map<String, dynamic>();

  static String? token = null;
  static User? _currentUser;

  static User? get currentUser => _currentUser;
  // 设置键值对
  static void set(String key, dynamic value) {
    _state[key] = value;
  }

  // 获取键值对
  static dynamic get(String key) {
    return _state[key];
  }

  // 删除键值对
  static void remove(String key) {
    _state.remove(key);
  }

  static set currentUser(User? user) {
    _currentUser = user;
  }

  static bool isLogged() {
    if (token == null || token!.isEmpty) {
      return false;
    }
    bool hasExpired = JwtDecoder.isExpired(token!);
    if (hasExpired) {
      return false;
    } else {
      return true;
    }
  }

  static void logout() {
    GStorage.userInfo.delete('token');
    token = null;
    _currentUser = null;
  }

  static void refreshToken() {
    token = GStorage.userInfo.get('token') ?? '';
    // if (token!.isNotEmpty) {
    //   try {
    //     Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    //     final role = decodedToken['role'];
    //     print('Role: $role');
    //     currentUser = User(username: decodedToken['username']);
    //     print(currentUser?.username);
    //     final exp = decodedToken['exp'];
    //     // 格式化 exp 时间戳为可读的日期时间格式
    //     final formattedExp = DateTime.fromMillisecondsSinceEpoch(exp * 1000).toString();
    //     print('Token Expiration Time: $formattedExp');
    //   } catch (e) {
    //     log('Error decoding token: $e');
    //   }
    // }
  }


}