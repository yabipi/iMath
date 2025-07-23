import 'package:imath/db/Storage.dart';
import 'package:imath/models/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
/**
 * 记录每个用户的全局状态
 */
class GlobalState {
  static final _state = Map<String, dynamic>();

  static String? token = null;
  static User? _currentUser;
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

  static User? get currentUser => _currentUser;

  static set currentUser(User? user) {
    _currentUser = user;
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
    _currentUser = null;
  }
}