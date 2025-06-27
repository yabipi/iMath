import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer';

import 'package:imath/core/context.dart';
import 'package:oauth2/oauth2.dart';

import '../../services/auth_api_service.dart';
import '../models/user.dart';


class LoginController {
  final GlobalKey<FormState> loginFormKey =
      GlobalKey<FormState>(debugLabel: '__loginFormKey__');

  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  late BuildContext context;
  late AuthApiService _authenticationService;

  LoginController(BuildContext context) {
    this.context = context;
    _authenticationService = AuthApiService();
  }

  Future<dynamic> signIn(String email, String password) async {
    try {
      log('Enter Signin');
      // return await _authenticationService.authGrantPassword(email, password);
      return await _authenticationService.signIn(email, password);
      // log('is logged in : ${crednetials!.accessToken}');
    } catch (e) {
      // printLog(e);
      // printError(info: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authenticationService.signOut();
      // _authenticationService.removeCredentails();
    } catch (e) {
      rethrow;
    }
  }


  Future<void> sendVerificationCode(String phone, String verifyCode) async {

  }

  Future<void> loginWithPhone(String phone, String verifyCode) async {

  }

  Future<void> loginWithWechat() async {

  }

  // Future<Response?> signUp(Map<String, dynamic> data) async {
  //   String error_m =
  //       'An error occurred while registering, please contact the administrator.';
  //   try {
  //     return await _authenticationService.signUp(data);
  //
  //     // if (response.statusCode == 200) {
  //     //   log('enter signup');
  //
  //     //   // tokenData = await signIn(data['email'], data['password']);
  //     // } else {
  //     //   // var message = response.body['error_description'];
  //
  //     //   throw Exception(error_m);
  //     // }
  //   } catch (e) {
  //     // printLog(e);
  //     printError(info: e.toString());
  //     throw Exception(error_m);
  //   }
  //   // return tokenData;
  // }

  Future<Credentials?> refreshToken() async {
    try {
      return _authenticationService.refreshToken();
    } catch (e) {
      // printError(info: 'exception refreshToken:  ${e.toString()}');
      rethrow;
    }
  }

  Credentials? tokenCredentials() => _authenticationService.credentials;



  bool isAuthenticated() {
    return !_authenticationService.sessionIsExpired();
  }

  // LoginController(AuthApiService authenticationService)
  //     : super(authenticationService);

  @override
  void onClose() {
    phoneController.dispose();
    emailController.dispose();
    codeController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    // super.onClose();
  }

  String? validator(String? value) {
    log('validatoooor');

    if (value != null && value.isEmpty) {
      return 'Please this field must be filled';
    }
    return null;
  }

  Future<void> login() async {
    log('${emailController.text}, ${passwordController.text}');
    try {
      final response = await signIn(emailController.text, passwordController.text);
      // debugPrint('response: $response');
      String username = response.data['exdata']['username'];
      // Get.toNamed('/profile', arguments: {'user': User(id: "0", name: username)}, preventDuplicates:  true);
      // print("切换到个人中心");
      // 刷新全局上下文的token
      context.refreshToken();
      context.go('/profile');
    } catch (err, _) {
      passwordController.clear();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      signOut();
      // Get.offAllNamed('/login');
    } catch (err, _) {
      rethrow;
    }
  }

  Future<void> loginWithBrowser() async {
    try {
      log('Login with browser');
      log('is authenticated: ${isAuthenticated()}');
      // await OAuthClient().createClient();
      // await signIn(emailController.text, passwordController.text);
    } catch (err, _) {
      rethrow;
    }
  }

  Future<void> sendCode() async {
    // if (!_formKey.currentState!.validate()) return;
    //
    // _isLoading = true;

    try {
      await sendVerificationCode(phoneController.text, codeController.text);
      // _showCodeInput = true;
      // _startCountdown();
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('验证码已发送')),
      //   );
      // }
    } catch (e) {
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('发送失败: $e')),
      //   );
      // }
    } finally {
      // if (mounted) {
      //   _isLoading = false;
      // }
    }
  }

  Future<void> loginWithPhoneCode() async {
    try {
      final user = await loginWithPhone(
        phoneController.text,
        codeController.text,
      );

    } catch (e) {
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('登录失败: $e')),
      //   );
      // }
    } finally {

    }
  }

  // Future<void> _loginWithUsernameAndPassword() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   _isLoading = true;
  //
  //   try {
  //     final response = await _authService.loginWithUsernameAndPassword(
  //       _usernameController.text,
  //       _passwordController.text,
  //     );
  //
  //     if (response != null && mounted) {
  //       debugPrint("response token : ${response['data']}");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(response['message'])),
  //       );
  //       Get.toNamed('/profile',
  //           arguments: {'user': User(id: "0", name: response['exdata']['username'])}
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('登录失败: $e')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       _isLoading = false;
  //     }
  //   }
  // }

  Future<void> _loginWithWechat() async {
    try {
      final user = await loginWithWechat();

    } catch (e) {
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('登录失败: $e')),
      //   );
      // }
    } finally {
      // if (mounted) {
      //   _isLoading = false;
      // }
    }
  }
}
