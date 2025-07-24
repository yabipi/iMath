import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:imath/mixins/category_mixin.dart';
import 'package:imath/models/knowledges.dart';
import 'package:imath/pages/common/category_panel.dart';

import 'package:imath/config/api_config.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/pages/common/bottom_navigation_bar.dart';
import 'package:imath/state/knowledges_provider.dart';


class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  _KnowledgeScreenState createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> with CategoryMixin {
  late Map<String, String> categories;
  
  // 定义10个不同的图标和对应的渐变色
  final List<Map<String, dynamic>> _iconSet = [
    {
      'icon': Icons.school,
      'colors': [Colors.deepPurple.shade300, Colors.purple.shade400],
    },
    {
      'icon': Icons.science,
      'colors': [Colors.blue.shade300, Colors.blue.shade500],
    },
    {
      'icon': Icons.calculate,
      'colors': [Colors.green.shade300, Colors.green.shade500],
    },
    {
      'icon': Icons.functions,
      'colors': [Colors.orange.shade300, Colors.orange.shade500],
    },
    {
      'icon': Icons.timeline,
      'colors': [Colors.red.shade300, Colors.red.shade500],
    },
    {
      'icon': Icons.analytics,
      'colors': [Colors.teal.shade300, Colors.teal.shade500],
    },
    {
      'icon': Icons.pie_chart,
      'colors': [Colors.indigo.shade300, Colors.indigo.shade500],
    },
    {
      'icon': Icons.trending_up,
      'colors': [Colors.cyan.shade300, Colors.cyan.shade500],
    },
    {
      'icon': Icons.data_usage,
      'colors': [Colors.pink.shade300, Colors.pink.shade500],
    },
    {
      'icon': Icons.psychology,
      'colors': [Colors.amber.shade300, Colors.amber.shade500],
    },
  ];

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    categories = getCategories(ref);
    List<Knowledge> knowledges = ref.watch(knowledgesProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: TextField(
          // controller: _searchController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // Perform search functionality here
          },
        ),
      ),
      // appBar: AppBar(
      //   // title: const Text(''),
      //   // centerTitle: true, // 确保标题居中
      //   flexibleSpace: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Spacer(),
      //       SizedBox(
      //         width: 0.5.sw, // 使用屏幕宽度的70%
      //         child: TextField(
      //           decoration: InputDecoration(
      //             hintText: '搜索...',
      //             prefixIcon: Icon(Icons.search, size: 20.sp),
      //             border: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(24.r),
      //             ),
      //             contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      //           ),
      //           onChanged: (value) {
      //             // 在这里处理搜索逻辑
      //           },
      //         )
      //       ),
      //       Spacer(),
      //     ],
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/admin/addknow');
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 分类标签区域
            CategoryPanel(onItemTap: (int categoryId) {onChangeCategory(categoryId);}),
            Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: knowledges.length,
                    itemBuilder: (BuildContext context, int index){
                      if (knowledges.length > 0) {
                        return _buildKnowItem(knowledges[index]);
                      } else {
                        return const Card(
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            title: Text('暂无知识点数据'),
                            leading: Icon(Icons.info_outline, color: Colors.grey),
                          ),
                        );
                      }
                    }
                )
            ),
          ],
        )
      ),

      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  /**
   * 此处items不能用List<Map<String, dynamic>>声明
   */
  Widget _buildKnowItem(Knowledge item) {
    // 根据知识点ID选择图标，确保同一个知识点总是显示相同的图标
    final iconData = _getIconForKnowledge(item.id);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: iconData['colors'],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: iconData['colors'][0].withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            iconData['icon'],
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.subtitle ?? '',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              context.push('/admin/editknow?knowledgeId=${item.id}');
            },
          ),
        ),
        onTap: () {
          context.push('/knowdetail?knowledgeId=${item.id}');
        },
      ),
    );
  }

  // 根据知识点ID获取对应的图标和颜色
  Map<String, dynamic> _getIconForKnowledge(int? knowledgeId) {
    if (knowledgeId == null) {
      return _iconSet[0]; // 默认返回第一个图标
    }
    
    // 使用知识点ID的哈希值来选择图标，确保同一个知识点总是显示相同的图标
    final index = knowledgeId.abs() % _iconSet.length;
    return _iconSet[index];
  }

  void onChangeCategory(int categoryId) {
    ref.read(knowledgesProvider.notifier).onChangeCategory(categoryId);
  }

}

