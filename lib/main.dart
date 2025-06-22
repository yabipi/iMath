import 'dart:convert';
import 'dart:io';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:imath/pages/knowledge/knowledge_screen.dart';
import 'package:imath/services/auth_api_service.dart';
import 'package:imath/services/connectivity_service.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:imath/db/provider/userinfo_db_provider.dart';
import 'package:imath/http/index.dart';

import 'package:imath/config/api_config.dart';

import 'package:imath/route/app_pages.dart';
import 'package:provider/provider.dart'; // 引入 provider 包
import 'bindings/app_binding.dart';

import 'config/constants.dart';
import 'controllers/auth_controller.dart';
import 'core/context.dart';
import 'db/Storage.dart';
import 'http/category.dart';


// 创建一个简单的 AppState 类来管理状态
class AppState with ChangeNotifier {
  Map<int, String> categories = {};

  void setCategories(Map<int, String> newCategories) {
    categories = newCategories;
    notifyListeners(); // 通知监听器状态已更改
  }
}

/**
 * 允许加载自签名的ssl证书
 */
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = 
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> initMathData() async {
  // 获取分类数据
  bool isConnected = await ConnectivityService.isConnected();
  if (isConnected) {
    final categories = await CategoryHttp.getCategories();
    Map<String, String> _categories = {'-1': '全部'};
    for (var item in categories) {
      _categories[item['ID'].toString()] = item['CategoryName'];
    }
    Context.set(CATEGORIES_KEY, _categories);
    GStorage.mathdata.put(CATEGORIES_KEY, json.encode(_categories));
  } else {
    String? categoriesStr = GStorage.mathdata.get(CATEGORIES_KEY);
    if (categoriesStr != null) {
      Map<String, dynamic> _categories = json.decode(categoriesStr?? '{}');
      Context.set(CATEGORIES_KEY, _categories);
      // return;
    }
  }
}

Future<void> initializeApp() async {
  // final dio = Dio();
  Context.refresh();

  await initMathData();
  // Initialize FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  //  初始化认证服务
  AuthApiService authApiService = Get.put(AuthApiService());
  await authApiService.initCredentials();
  Get.put(AuthController(authApiService), permanent: true);
  // log('Initialize');
}


void main() async {
  logger.d('Starting app...', version());

  // 判断当前运行环境
  if (Platform.isAndroid) {
    logger.d('当前运行环境是 Android');
  } else if (Platform.isIOS) {
    logger.d('当前运行环境是 iOS');
  } else if (Platform.isLinux) {
    logger.d('当前运行环境是 Web');
    // await TeXRenderingServer.start();
  } else {
    logger.d('当前运行环境是其他平台');
  }

  WidgetsFlutterBinding.ensureInitialized();
  await GStorage.init();
  Request();
  // ApiConfig.environment = Environment.DEV; // 或 Environment.PROD
  ApiConfig.environment =
      const String.fromEnvironment('ENV', defaultValue: 'DEV');
  logger.d('environment: ${ApiConfig.environment}, SERVER_BASE_URL: ${ApiConfig.SERVER_BASE_URL}');

  HttpOverrides.global = MyHttpOverrides();
  await initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(), // 使用 ChangeNotifierProvider 提供状态
      child: GetMaterialApp(
        title: '数学宝典',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const KnowledgeScreen(),
        getPages: Routes.getPages,
        // initialRoute: Routes.HOME,
        initialBinding: AppBinding(),
        // routes: {
        //   // '/add_paper': (context) => const AddPaperScreen(),
        // },
      ),
    );
  }
}
