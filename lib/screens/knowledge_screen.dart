import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:imath/components/math_cell.dart';
import 'dart:convert';

import 'package:imath/config/api_config.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';
import 'package:markdown_widget/widget/markdown.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _KnowledgeScreenState createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  // Future<List<dynamic>> fetchCategories() async {
  //   final response = await http
  //       .get(Uri.parse('${ApiConfig.SERVER_BASE_URL}/api/category/list'));
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to load categories');
  //   }
  // }
  // 使用 Context 获取全局数据
  //

  Future<List<dynamic>> fetchKnowledgePoints(int categoryId) async {
    final response = await http.get(Uri.parse(
        '${ApiConfig.SERVER_BASE_URL}/api/know/list?categoryId=$categoryId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load knowledge points');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Context().get(CATEGORIES_KEY) as Map<int, String>?;
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识点'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                '数学知识体系',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // if (categories != null) // 检查 categories 是否为 null
            ...?categories?.keys.map((key) {
                return ListTile(
                  leading: const Icon(Icons.category),
                  title: Text(categories![key]!),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            KnowledgeListScreen(categoryId: key),
                      ),
                    );
                  },
                );
              }).toList(),
          ],
        ),
      ),
      body: const Center(
        child: Text('选择左侧菜单查看具体知识点'),
      ),
    );
  }
}

class KnowledgeListScreen extends StatefulWidget {
  final int categoryId;

  const KnowledgeListScreen({super.key, required this.categoryId});

  @override
  // ignore: library_private_types_in_public_api
  _KnowledgeListScreenState createState() => _KnowledgeListScreenState();
}

class _KnowledgeListScreenState extends State<KnowledgeListScreen> {
  Future<List<dynamic>> fetchKnowledgePoints() async {
    final response = await http.get(Uri.parse(
        '${ApiConfig.SERVER_BASE_URL}/api/know/list?categoryId=${widget.categoryId}'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load knowledge points');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识点列表'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchKnowledgePoints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView(
              padding: const EdgeInsets.all(8.0),
              children: snapshot.data!.map((knowledge) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      knowledge['Title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    subtitle: Text(
                      knowledge['Content'].length > 100
                          ? '${knowledge['Content'].substring(0, 100)}...'
                          : knowledge['Content'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              KnowledgeDetailScreen(knowledge: knowledge),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

class KnowledgeDetailScreen extends StatelessWidget {
  final dynamic knowledge;

  const KnowledgeDetailScreen({super.key, required this.knowledge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(knowledge['Title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GptMarkdown(
            knowledge['Content'],
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
