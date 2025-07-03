import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user.dart';

class UserController {
  // const UserController();
  // 模拟用户数据
  static final Map<String, User> _users = {
    '13800138000': User(
      id: 1,
      username: '测试用户',
      phone: '13800138000',
      createdAt: DateTime.now(),
    ),
  };

  // var tokenEntiy = UserTokenEntity().obs;
  // var loginState = false.obs;
  // logout(){
  //   loginState.value = false;
  //   UserManager.instance.logout();
  //   update();
  // }

  /*用户token同步*/
  // login(UserTokenEntity userTokenEntity) {
  //   tokenEntiy.value = userTokenEntity;
  //   loginState.value = true;
  //   UserManager.instance.saveUserToken(userTokenEntity);
  //
  //   /// 首页的用户状态需求更新
  //   HomeLogic homeLogic = Get.find<HomeLogic>();
  //   homeLogic.state.refreshController.requestRefresh();
  //   update();
  // }

  /*加载本地用户Token*/
  // localUserToken() {
  //   UserTokenEntity? entity = UserManager.instance.loadLocalToken();
  //   if (entity != null) {
  //     tokenEntiy.value = entity;
  //     loginState.value = true;
  //     update();
  //     localUserInfo();
  //   }
  // }

  loadNetUserInfo() {
    // if (loginState.value == true) {
    //
    //   asyncRequestNetwork<UserTokenEntity>('', onSuccess: (data){
    //     /// 用户登录态未过期可以接着使用
    //     tokenEntiy.value = data!;
    //     loginState.value = true;
    //     update();
    //   }, onError: (code, msg){
    //   });
    // }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    // super.onInit();

    // localUserToken();
  }
  // 发送验证码
  Future<void> sendVerificationCode(String phone) async {
    // 模拟发送验证码
    await Future.delayed(const Duration(seconds: 1));
    // TODO: 实现实际的验证码发送逻辑
  }

  Future<Map<String, dynamic>> loginWithUsernameAndPassword(String username, String password) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.SERVER_BASE_URL}/api/user/login',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // final List<dynamic> content = data['data'] ?? [];
      String token = response.headers['token'] as String;
      // Get.put(token);
      return data;
    }
    throw Exception('登录失败');
  }
  // 手机号登录
  Future<User?> loginWithPhone(String phone, String code) async {
    return null;
    // 模拟登录
    // await Future.delayed(const Duration(seconds: 1));
    // // TODO: 实现实际的登录逻辑
    // if (code != '123456') {
    //   throw Exception('验证码错误');
    // }
    //
    // // 检查用户是否存在
    // if (_users.containsKey(phone)) {
    //   return _users[phone];
    // }
    //
    // // 创建新用户
    // final user = User(
    //   id: DateTime.now().millisecondsSinceEpoch.toString(),
    //   username: '用户${phone.substring(7)}',
    //   phone: phone,
    //   createdAt: DateTime.now(),
    // );
    // _users[phone] = user;
    // return user;
  }

  // 微信登录
  Future<User?> loginWithWechat() async {
    // 模拟微信登录
    // await Future.delayed(const Duration(seconds: 1));
    // // TODO: 实现实际的微信登录逻辑
    // final user = User(
    //   id: DateTime.now().millisecondsSinceEpoch.toString(),
    //   username: '微信用户',
    //   wechatId: 'wx_${DateTime.now().millisecondsSinceEpoch}',
    //   createdAt: DateTime.now(),
    // );
    // return user;
    return null;
  }

  // 退出登录
  Future<void> logout() async {
    // 模拟退出登录
    await Future.delayed(const Duration(seconds: 1));
    // TODO: 实现实际的退出登录逻辑
  }
} 