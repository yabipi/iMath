// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:imath/pages/culture_screen.dart';
import 'package:imath/pages/home_screen.dart';
import 'package:imath/pages/knowledge_screen.dart';
import 'package:imath/pages/questions_screen.dart';

import '../bindings/login_binding.dart';
import '../db/Storage.dart';
import '../pages/about_me.dart';
import '../pages/login_screen.dart';
import '../pages/profile_screen.dart';

class Routes {
  static String HOME = '/';
  static String LOGIN = '/login';
  static String LOGIN_WEBVIEW = '/login-webview';
  static String SIGNUP = '/signup';

  static final List<GetPage<dynamic>> getPages = [
    // 首页(推荐)
    CustomGetPage(name: '/', page: () => const HomeScreen()),
    CustomGetPage(name: '/knowledge', page: () => KnowledgeScreen()),
    CustomGetPage(name: '/culture', page: () => CultureScreen()),
    CustomGetPage(name: '/questions', page: () => QuestionsScreen()),
    // 登录
    GetPage(
        name: Routes.LOGIN,
        page: () => LoginScreen(),
        binding: LoginBinding(),
        transition: Transition.noTransition),
    // CustomGetPage(name: '/login', page: () => const LoginScreen(), binding: LoginBinding(),),
    // 热门
    CustomGetPage(name: '/profile', page: () => ProfileScreen()),
    CustomGetPage(name: '/about', page: () => AboutMePage()),


  ];
}

class CustomGetPage extends GetPage<dynamic> {
  CustomGetPage({
    required super.name,
    required super.page,
    this.fullscreen,
    super.transitionDuration,
  }) : super(
          curve: Curves.linear,
          transition: Transition.native,
          showCupertinoParallax: false,
          popGesture: false,
          fullscreenDialog: fullscreen != null && fullscreen,
        );
  bool? fullscreen = false;
}
