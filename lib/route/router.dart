import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/models/user.dart';
import 'package:imath/pages/admin/admin_screen.dart';
import 'package:imath/pages/admin/camera_screen.dart';
import 'package:imath/pages/admin/pdf_uploader.dart';
import 'package:imath/pages/admin/test_functions.dart';
import 'package:imath/pages/culture/add_article.dart';
import 'package:imath/pages/culture/add_mathematician.dart';
import 'package:imath/pages/culture/article_viewer.dart';
import 'package:imath/pages/culture/culture_screen.dart';
import 'package:imath/pages/culture/edit_article.dart';
import 'package:imath/pages/knowledge/add_knowledge.dart';
import 'package:imath/pages/knowledge/edit_knowledge.dart';
import 'package:imath/pages/knowledge/knowledge_screen.dart';
import 'package:imath/pages/paper/add_paper_screen.dart';
import 'package:imath/pages/question/add_question.dart';
import 'package:imath/pages/question/edit_question.dart';
import 'package:imath/pages/question/questions_screen.dart';
import 'package:imath/pages/user/about_me.dart';
import 'package:imath/pages/user/login_screen.dart';
import 'package:imath/pages/user/pincode_input.dart';

import 'package:imath/pages/user/profile_screen.dart';
import 'package:imath/pages/user/register.dart';


final router = GoRouter(
  initialLocation: '/culture',
  observers: [FlutterSmartDialog.observer],
  redirect: (context, state) => state.uri.toString() == '/' ? '/knowledge' : null,
  routes: [
    GoRoute(
      path: '/knowledge',
      builder: (context, state) => const KnowledgeScreen(),
    ),
    GoRoute(
      path: '/culture',
      builder: (context, state) {
        final String index = state.uri.queryParameters['tab']?? '0';
        return CultureScreen(initialIndex: int.parse(index));
      },

      routes: <RouteBase>[ // Add child routes
        GoRoute(
          path: 'article',
          builder: (context, state) {
            final article = state.extra as Map<String, dynamic>;
            return ArticleViewer(title: article['title'], articleId: article['id']);
          },
        ),
      ],
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
    // 管理员入口
    GoRoute(
      path: '/admin',
      builder: (context, state) => AdminScreen(),
      routes: <RouteBase>[ // Add child routes
          GoRoute(
            path: 'addmathematician',
            builder: (context, state) => AddMathematicianScreen(),
          ),
          GoRoute(
            path: 'addArticle',
            builder: (context, state) => AddArticlePage(),
          ),
        GoRoute(
            path: 'editArticle/:articleId',
            builder: (context, state) {
              final articleId = state.pathParameters['articleId'];
              return EditArticlePage(articleId: int.parse(articleId!));
            },
          ),
          GoRoute(
            path: 'addpaper',
            builder: (context, state) => AddPaperScreen(),
          ),

          GoRoute(
            path: 'addquestion',
            builder: (context, state) => AddQuestionScreen(paperId: -1),
          ),

          GoRoute(
            path: 'editquestion',
            builder: (context, state) => const QuestionEditView(),
          ),

          GoRoute(
            path: 'addknow',
            builder: (context, state) => const AddKnowledgeView(),
          ),
          GoRoute(
            path: 'editknow',
            builder: (context, state) => const EditKnowledgeView(),
          ),

          GoRoute(
            path: 'addByOCR',
            builder: (context, state) => const CameraScreen(),
          ),
          GoRoute(
            path: 'addByPDF',
            builder: (context, state) => PdfUploader(),
          ),
          // 测试页面
          GoRoute(
            path: 'test',
            builder: (context, state) => TestFunctionsPage(),
          ),
        ],

    ),


  ],
);