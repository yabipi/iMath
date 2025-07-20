import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:flutter/material.dart';

import 'package:imath/models/user.dart';
import 'package:imath/route/router.dart';
import 'package:imath/services/connectivity_service.dart';
import 'package:imath/utils/device_util.dart';

// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:imath/http/index.dart';

import 'package:imath/config/api_config.dart';

import 'config/constants.dart';

import 'core/context.dart';
import 'core/global.dart';
import 'db/Storage.dart';
import 'http/category.dart';


// 创建一个简单的 AppState 类来管理状态
// class AppState with ChangeNotifier {
//   Map<int, String> categories = {};
//
//   void setCategories(Map<int, String> newCategories) {
//     categories = newCategories;
//     notifyListeners(); // 通知监听器状态已更改
//   }
// }

/**
 * 允许加载自签名的ssl证书
 * 注意: X509Certificate在webview_flutter包中也有定义，所以如果引入webview_flutter会出现冲突
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
    Map<String, String> _categories = {ALL_CATEGORY.toString(): '全部'};
    // 单独存放初等数学和高等数学分类
    Map<String, String> primary_categories = {};
    Map<String, String> advanced_categories = {};
    for (var item in categories) {
      _categories[item['ID'].toString()] = item['CategoryName'];
      if (item['level'] == MATH_LEVEL.Primary.value) {
        primary_categories[item['ID'].toString()] = item['CategoryName'];
      }
      if (item['level'] == MATH_LEVEL.Advanced.value) {
        advanced_categories[item['ID'].toString()] = item['CategoryName'];
      }
    }
    Global.set(MATH_LEVEL.Primary.value, primary_categories);
    Global.set(MATH_LEVEL.Advanced.value, advanced_categories);
    GStorage.mathdata.put(CATEGORIES_KEY, json.encode(_categories));

  } else {
    // String? categoriesStr = GStorage.mathdata.get(CATEGORIES_KEY);
    // if (categoriesStr != null) {
    //   Map<String, dynamic> _categories = json.decode(categoriesStr?? '{}');
    //   // context.set(CATEGORIES_KEY, _categories);
    //   // return;
    // }
  }
}

void initWebView() {
  // Run `LinuxWebViewPlugin.initialize()` first before creating a WebView.
  // LinuxWebViewPlugin.initialize(options: <String, String?>{
  //   'user-agent': 'UA String',
  //   'remote-debugging-port': '8888',
  //   'autoplay-policy': 'no-user-gesture-required',
  // });

  // Configure [WebView] to use the [LinuxWebView].
  // WebView.platform = LinuxWebView();
}

Future<void> initializeApp() async {
  // final dio = Dio();

  await initMathData();
  if (DeviceUtil.isMobile) {
    // Initialize FFI
    // sqfliteFfiInit();
    // databaseFactory = databaseFactoryFfi;
  }

  //  初始化认证服务
  // AuthApiService authApiService = Get.put(AuthApiService());
  // await authApiService.initCredentials();
  // Get.put(AuthController(authApiService), permanent: true);
  // log('Initialize');
}


void main() async {
  logger.d('Starting app...', version());

  WidgetsFlutterBinding.ensureInitialized();
  await GStorage.init();

  Request();
  await Request.setCookie();

  String env = const String.fromEnvironment('ENV', defaultValue: 'DEV');
  ApiConfig.environment = Environment.values.byName(env.toUpperCase());
  if (kReleaseMode) {
    ApiConfig.environment = Environment.PROD;
  }
  // ApiConfig.environment = Environment.DEV; // 或 Environment.PROD
  logger.d('environment: ${ApiConfig.environment}, SERVER_BASE_URL: ${ApiConfig.SERVER_BASE_URL}');

  HttpOverrides.global = MyHttpOverrides();
  await initializeApp();
  if (DeviceUtil.isLinux) {
    // initWebView();
  }

  runApp(ProviderScope(
      child: MyApp()
  ));
}


class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 将初始数据挂载到context上
    context.refreshToken();
    final originalMap = GStorage.userInfo.get('user');
    if (originalMap != null) {
      final Map<String, dynamic> userJson = Map<String, dynamic>.from(originalMap);
      if (userJson != null) {
        final user = User.fromJson(userJson);
        context.currentUser = user;
      }
    }

    String? categoriesStr = GStorage.mathdata.get(CATEGORIES_KEY);
    if (categoriesStr != null) {
      Map<String, dynamic> _categories = json.decode(categoriesStr ?? '{}');
      context.set(CATEGORIES_KEY, _categories);
    }
    return _buildScreenFitApp(context);
  }

  /**
   * 创建路由Wrapper
   */
  Widget _buildRouterApp(BuildContext context) {
    return MaterialApp.router(
      title: '数学宝典',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        textTheme: TextTheme(
            bodyLarge: TextStyle(fontSize: 10.sp),
            bodyMedium: TextStyle(fontSize: 8.sp),
            bodySmall: TextStyle(fontSize: 6.sp)
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
      builder: FlutterSmartDialog.init(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
    );
  }

  /**
   * 创建适配屏幕的App
   */
  Widget _buildScreenFitApp(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_ , child) {
        return _buildRouterApp(context);
      },
      // child: const HomePage(title: 'First Method'),
    );
  }
}



