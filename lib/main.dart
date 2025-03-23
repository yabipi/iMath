import 'package:flutter/material.dart';
import 'screens/geometry_solution_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_paper_screen.dart';
import 'screens/paper_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/history_screen.dart';
import 'config/api_config.dart';


void main() {
  ApiConfig.environment = Environment.PROD; // 或 Environment.PROD
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/add_paper': (context) => const AddPaperScreen(),
      },
    );
  }
}

final List<Widget> _pages = [
  const HomeScreen(),
  const PaperListScreen(),
  const HistoryScreen(),
  // const ProfileScreen(),
]; 