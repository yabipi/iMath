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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/admin/addknow');
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 分类标签区域
          CategoryPanel(onItemTap: (int categoryId) {onChangeCategory(categoryId);}),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: knowledges.length,
                itemBuilder: (BuildContext context, int index){
                  if (knowledges.length > 0) {
                    return _buildKnowItem(knowledges[index]);
                    // return ListTile(
                    //   title: Text(knowledges[index].title),
                    // );
                  } else {
                    return ListTile(
                      title: Text('无效数据'),
                    );
                  }
                }
            )
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  /**
   * 此处items不能用List<Map<String, dynamic>>声明
   */
  Widget _buildKnowItem(Knowledge item) {
    return ListTile(
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      subtitle: Text(
        item.subtitle ?? '',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          context.push('/admin/editknow?knowledgeId=${item.id}');
        },
      ),
      onTap: () {
        context.push('/knowdetail?knowledgeId=${item.id}');
      },
    );
  }

  void onChangeCategory(int categoryId) {
    ref.read(knowledgesProvider.notifier).onChangeCategory(categoryId);
  }

}

