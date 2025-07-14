import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer';

import 'package:imath/core/context.dart';
import 'package:imath/db/Storage.dart';
import 'package:imath/http/auth.dart';
import 'package:imath/models/user.dart';
import 'package:oauth2/oauth2.dart';

import '../../services/auth_api_service.dart';

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



  Future<void> sendVerificationCode(String phone, String verifyCode) async {

  }

  Future<void> loginWithPhone(String phone, String verifyCode) async {

  }

  Future<void> loginWithWechat() async {

  }

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
    if (value != null && value.isEmpty) {
      return 'Please this field must be filled';
    }
    return null;
  }

  Future<void> login() async {
    log('${emailController.text}, ${passwordController.text}');
    try {
      final result = await AuthHttp.signIn(emailController.text, passwordController.text);
      String token = result['token'];
      final user = User.fromJson(result['user']);
      if (token.isNotEmpty) {
        GStorage.userInfo.put('token', token);
      }
      GStorage.userInfo.put('user', result['user']);
      // 刷新当前用户
      context.currentUser = user;
      context.go('/profile', extra:  user);
    } catch (err, _) {
      passwordController.clear();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await AuthHttp.signOut(context.currentUser?.username);
      context.go('/login');
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
