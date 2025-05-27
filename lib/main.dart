import 'dart:convert';
import 'dart:io';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:imath/config/api_config.dart';
import 'package:provider/provider.dart'; // 引入 provider 包
import 'config/constants.dart';
import 'core/context.dart';
import 'screens/home_screen.dart';

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

void main() async {
  // 判断当前运行环境
  if (Platform.isAndroid) {
    print('当前运行环境是 Android');
  } else if (Platform.isIOS) {
    print('当前运行环境是 iOS');
  } else if (Platform.isLinux) {
    print('当前运行环境是 Web');
    // await TeXRenderingServer.start();
  } else {
    print('当前运行环境是其他平台');
  }

  // ApiConfig.environment = Environment.DEV; // 或 Environment.PROD
  ApiConfig.environment =
      const String.fromEnvironment('ENV', defaultValue: 'DEV');
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await init();
  runApp(MyApp());
}

Future<void> init() async {
  final response = await http
      .get(Uri.parse('${ApiConfig.SERVER_BASE_URL}/api/category/list'));
  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    Map<int, String> categories = {};
    for (var item in data) {
      categories[item['ID']] = item['CategoryName'];
    }
    Context().set(CATEGORIES_KEY, categories);
  } else {
    throw Exception('Failed to load categories');
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(), // 使用 ChangeNotifierProvider 提供状态
      child: MaterialApp(
        title: 'iMath',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          // '/add_paper': (context) => const AddPaperScreen(),
        },
      ),
    );
  }
}
