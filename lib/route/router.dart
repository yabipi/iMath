import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/models/article.dart';
import 'package:imath/models/knowledges.dart';
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
import 'package:imath/pages/culture/edit_mathematician.dart';
import 'package:imath/pages/culture/experience_screen.dart';
import 'package:imath/pages/culture/mathematician_listview.dart';
import 'package:imath/pages/culture/mathematician_screen.dart';
import 'package:imath/pages/culture/problems_screen.dart';
import 'package:imath/pages/demo/pageview_demo.dart';
import 'package:imath/pages/home/book_listview.dart';
import 'package:imath/pages/home/home_screen.dart';
import 'package:imath/pages/home/news_detail.dart';
import 'package:imath/pages/knowledge/add_knowledge.dart';
import 'package:imath/pages/knowledge/edit_knowledge.dart';
import 'package:imath/pages/knowledge/knowledge_detail.dart';
import 'package:imath/pages/knowledge/knowledge_screen.dart';
import 'package:imath/pages/paper/add_paper_screen.dart';
import 'package:imath/pages/question/add_question.dart';
import 'package:imath/pages/question/edit_question.dart';
import 'package:imath/pages/question/questions_main.dart';
import 'package:imath/pages/question/questions_screen.dart';
import 'package:imath/pages/user/about_me.dart';
import 'package:imath/pages/user/avatar_edit.dart';
import 'package:imath/pages/user/login_screen.dart';
import 'package:imath/pages/user/phone_login.dart';
import 'package:imath/pages/user/pincode_input.dart';

import 'package:imath/pages/user/profile_screen.dart';
import 'package:imath/pages/user/register.dart';
import 'package:imath/pages/user/settings.dart';
import 'package:imath/pages/user/slider_captcha_client_verify.dart';


final router = GoRouter(
  initialLocation: '/home',
  observers: [FlutterSmartDialog.observer],
  redirect: (context, state) => state.uri.toString() == '/' ? '/knowledge' : null,
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/knowledge',
      builder: (context, state) => const KnowledgeScreen(),
    ),
    GoRoute(
      path: '/mathematician',
      builder: (context, state) => MathematicianScreen(),
    ),

    GoRoute(
      path: '/article',
      builder: (context, state) {
        final article = state.extra as Article;
        return ArticleViewer(title: article.title, articleId: article.id);
      },
    ),
    GoRoute(
      path: '/knowdetail',
      builder: (context, state) {
        final knowledgeId = state.uri.queryParameters['knowledgeId'] ?? '0';
        return KnowledgeDetailScreen(knowledgeId: int.parse(knowledgeId));
      }
    ),
    GoRoute(
      path: '/booklist',
      builder: (context, state) => BookListView(),
    ),
    GoRoute(
      path: '/experience',
      builder: (context, state) => ExperienceScreen(),
    ),
    GoRoute(
      path: '/problems',
      builder: (context, state) => ProblemsScreen(),
    ),
    //
    GoRoute(
      path: '/newsdetail',
      builder: (context, state) => NewsDetailPage(),
    ),

    GoRoute(
      path: '/questions',
      builder: (context, state) => const QuestionsMain(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final user = state.extra as User?;
        return ProfileScreen(user:  user);
      },
      routes: <RouteBase>[ // Add child routes
        GoRoute(
          path: 'settings',
          builder: (context, state) => SettingsPage(),
        ),
        GoRoute(
          path: 'about',
          builder: (context, state) => AboutMePage(),
        ),
        GoRoute(
          path: 'avatarEdit',
          builder: (context, state) {
            final user = state.extra as User?;
            return AvatarEditScreen(
              currentAvatarBase64: user?.avatar,
            );
          },
        ),
        
      ]
    ),

    // 用户登录管理相关
    GoRoute(
      path: '/login',
      builder: (context, state) => PhoneLoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterPage(),
    ),
    GoRoute(
      path: '/captcha',
      builder: (context, state) => SliderCaptchaClientVerify(title: '人机验证',),
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
          path: 'editknow',
          builder: (context, state) {
            final knowledgeId = state.uri.queryParameters['knowledgeId'];
            return EditKnowledgeView(knowledgeId: int.parse(knowledgeId!));
          },
        ),
          GoRoute(
            path: 'editQuestion',
            builder: (context, state) {
              final questionId = state.uri.queryParameters['questionId'];
              return QuestionEditView(questionId: int.parse(questionId!));
            },
          ),
          GoRoute(
            path: 'editMathematician',
            builder: (context, state) {
              final mathematicianId = state.uri.queryParameters['mathematicianId'];
              return EditMathematicianScreen(mathematicianId: int.parse(mathematicianId!));
            },
          ),
          GoRoute(
            path: 'addknow',
            builder: (context, state) => const AddKnowledgeView(),
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

        //
        ],

    ),
    GoRoute(
      path: '/pageview',
      builder: (context, state) => PageViewDemo(),
    ),

  ],
);