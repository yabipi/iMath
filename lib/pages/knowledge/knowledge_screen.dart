import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:imath/mixins/category_mixin.dart';
import 'package:imath/pages/common/category_panel.dart';

import 'package:imath/config/api_config.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/pages/common/bottom_navigation_bar.dart';
import 'package:imath/state/settings_provider.dart';

import '../../http/init.dart';

class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  _KnowledgeScreenState createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> with CategoryMixin {
  // 新增：当前选中的分类ID
  String? _selectedCategory;
  late Map<String, String> categories;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    categories = getCategories(ref);
    // final categories = Context().get(CATEGORIES_KEY);
    // SmartDialog.showToast('账号未登录');
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true, // 确保标题居中
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            SizedBox(
              width: 0.5.sw, // 使用屏幕宽度的70%
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索...',
                  prefixIcon: Icon(Icons.search, size: 20.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                onChanged: (value) {
                  // 在这里处理搜索逻辑
                },
              )
            ),
            Spacer(),
          ],
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/admin/addknow');
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 分类标签区域
          CategoryPanel(onItemTap: (int categoryId) {onChangeCategory(categoryId);}),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: fetchKnowledgePoints(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView(
                    padding: EdgeInsets.all(8.w),
                    children: buildKnowItems(snapshot.data!['items']),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  /**
   * 此处items不能用List<Map<String, dynamic>>声明
   */
  List<Widget> buildKnowItems(List<dynamic> items) {
    final itemList = items.map((_knowledge) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Stack(
          children: [
            ListTile(
              title: Text(
                _knowledge['Title'],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              subtitle: Text(
                _knowledge['Content'].length > 100
                    ? '${_knowledge['Content'].substring(0, 100)}...'
                    : _knowledge['Content'],
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        KnowledgeDetailScreen(
                            knowledge: _knowledge),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: IconButton(
                icon: Icon(Icons.edit, size: 20.sp),
                onPressed: () {
                  context.go('/admin/editknow?knowledgeId=${_knowledge['ID']}');
                },
              ),
            ),
          ],
        ),
      );
    }).toList();
    return itemList;
  }

  void onChangeCategory(int categoryId) {
    setState(() {
      if (categoryId == ALL_CATEGORY) {
        _selectedCategory = null;
      } else {
        _selectedCategory = categories[categoryId.toString()];
      }
    });
  }
  // 新增：获取知识点列表的函数
  Future<Map<String, dynamic>> fetchKnowledgePoints() async {
    final MATH_LEVEL level = ref.watch(mathLevelProvider);
    String url;
    if (_selectedCategory != null) {
      url = '${ApiConfig.SERVER_BASE_URL}/api/know/list?level=${level.value}&category=${_selectedCategory}';
    } else {
      url = '${ApiConfig.SERVER_BASE_URL}/api/know/list?level=${level.value}';
    }
    final response = await Request().get(url);
    if (response.statusCode == 200) {
      // return json.decode(response.body);
      return response.data;
    } else {
      throw Exception('Failed to load knowledge points');
    }
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: GptMarkdown(
              knowledge['Content'],
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}