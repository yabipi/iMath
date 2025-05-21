import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:imath/config/api_config.dart';
import 'config/constants.dart';
import 'core/context.dart';
import 'screens/home_screen.dart';


void main() async {
  // ApiConfig.environment = Environment.DEV; // 或 Environment.PROD
  ApiConfig.environment =
      const String.fromEnvironment('ENV', defaultValue: 'DEV');
  // final Context context = Context(); // 初始化 Context 实例
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  // runApp(MyApp(context: Context()));
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
  // final Context context;
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iMath',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        // '/add_paper': (context) => const AddPaperScreen(),
      },
    );
  }
}

// final List<Widget> _pages = [
//   const HomeScreen(),
//   const PaperListScreen(),
//   const HistoryScreen(),
//   // const ProfileScreen(),
// ];
