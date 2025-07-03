import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/models/user.dart';
import 'package:imath/pages/culture/culture_screen.dart';
import 'package:imath/pages/knowledge/add_knowledge.dart';
import 'package:imath/pages/knowledge/edit_knowledge.dart';
import 'package:imath/pages/knowledge/knowledge_screen.dart';
import 'package:imath/pages/question/add_question.dart';
import 'package:imath/pages/question/edit_question.dart';
import 'package:imath/pages/question/questions_screen.dart';
import 'package:imath/pages/user/about_me.dart';
import 'package:imath/pages/user/login_screen.dart';
import 'package:imath/pages/user/pincode_input.dart';

import 'package:imath/pages/user/profile_screen.dart';
import 'package:imath/pages/user/register.dart';


final router = GoRouter(
  initialLocation: '/knowledge',
  observers: [FlutterSmartDialog.observer],
  redirect: (context, state) => state.uri.toString() == '/' ? '/knowledge' : null,
  routes: [
    GoRoute(
      path: '/knowledge',
      builder: (context, state) => const KnowledgeScreen(),
    ),
    GoRoute(
      path: '/culture',
      builder: (context, state) => const CultureScreen(),
    ),
    GoRoute(
      path: '/questions',
      builder: (context, state) => const QuestionsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final user = state.extra as User?;
        return ProfileScreen(user:  user);
      },
    ),

    GoRoute(
      path: '/about',
      builder: (context, state) => AboutMePage(),
    ),

    GoRoute(
      path: '/addquestion',
      builder: (context, state) => AddQuestionScreen(paperId: -1),
    ),

    GoRoute(
      path: '/editquestion',
      builder: (context, state) => const QuestionEditView(),
    ),

    GoRoute(
      path: '/addknow',
      builder: (context, state) => const AddKnowledgeView(),
    ),
    GoRoute(
      path: '/editknow',
      builder: (context, state) => const EditKnowledgeView(),
    ),
    // GoRoute(
    //   path: '/profile',
    //   builder: (context, state) => const ProfileScreen(),
    // ),
    // 用户登录管理相关
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterPage(),
    ),
    GoRoute(
      path: '/verifycode',
      builder: (context, state) {
        final String? phone = state.uri.queryParameters['phone'];
        return PinputScreen(phone:  phone??'');
      },
    ),
  ],
);