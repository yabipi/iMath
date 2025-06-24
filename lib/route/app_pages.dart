// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:imath/pages/knowledge/add_knowledge.dart';
import 'package:imath/pages/question/add_question.dart';
import 'package:imath/pages/culture/culture_screen.dart';
import 'package:imath/pages/knowledge/edit_knowledge.dart';
import 'package:imath/pages/question/edit_question.dart';
import 'package:imath/pages/todo/todo_screen.dart';
import 'package:imath/pages/todo/add_todo_screen.dart';
import 'package:imath/pages/todo/edit_todo_screen.dart';

import 'package:imath/pages/knowledge/knowledge_screen.dart';
import 'package:imath/pages/question/questions_screen.dart';

import '../bindings/login_binding.dart';
import '../bindings/todo_binding.dart';
import '../db/Storage.dart';
import '../pages/user/about_me.dart';
import '../pages/user/login_screen.dart';
import '../pages/user/profile_screen.dart';

class Routes {
  static String HOME = '/';
  static String LOGIN = '/login';
  static String LOGIN_WEBVIEW = '/login-webview';
  static String SIGNUP = '/signup';
  static String TODO = '/todo';
  static String ADD_TODO = '/add-todo';
  static String EDIT_TODO = '/edit-todo';

  static final List<GetPage<dynamic>> getPages = [
    // 首页(推荐)
    // CustomGetPage(name: '/', page: () => const HomeScreen()),
    CustomGetPage(name: '/knowledge', page: () => KnowledgeScreen()),
    CustomGetPage(name: '/culture', page: () => CultureScreen()),
    CustomGetPage(name: '/questions', page: () => QuestionsScreen()),
    // Todo routes
    GetPage(
      name: Routes.TODO,
      page: () => const TodoScreen(),
      binding: TodoBinding(),
    ),
    GetPage(
      name: Routes.ADD_TODO,
      page: () => const AddTodoScreen(),
      binding: TodoBinding(),
    ),
    GetPage(
      name: Routes.EDIT_TODO,
      page: () => EditTodoScreen(todo: Get.arguments),
      binding: TodoBinding(),
    ),
    // 登录
    GetPage(
        name: Routes.LOGIN,
        page: () => LoginScreen(),
        binding: LoginBinding(),
        transition: Transition.noTransition),
    // CustomGetPage(name: '/login', page: () => const LoginScreen(), binding: LoginBinding(),)
    // 热门
    CustomGetPage(name: '/profile', page: () => ProfileScreen()),
    CustomGetPage(name: '/about', page: () => AboutMePage()),

    //管理页面
    CustomGetPage(name: '/addquestion', page: () => AddQuestionScreen(paperId: -1)),
    CustomGetPage(name: '/editquestion', page: () => QuestionEditView()),
    CustomGetPage(name: '/addknow', page: () => AddKnowledgeView()),
    CustomGetPage(name: '/editknow', page: () => EditKnowledgeView()),
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
