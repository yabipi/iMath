import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:imath/widgets/bottom_navigation_bar.dart';
import '../../models/mathematician.dart';
import 'mathematician_detail_screen.dart';
import 'mathematician_listview.dart';

class CultureScreen extends StatefulWidget {
  const CultureScreen({super.key});

  @override
  _CultureScreenState createState()  => _CultureScreenState();

}

class _CultureScreenState extends State<CultureScreen> {
  final GlobalKey<_MathematicianListviewState> _mathematicianListKey = GlobalKey<_MathematicianListviewState>();

  void initState() {
    super.initState();
    // 获取分类数据
    print('CultureScreen initState');
  }

  @override
  Widget build(BuildContext context) {
    bool reload = Get.arguments?['reload'] ?? false;
    if (reload) {
      // setState(() {});
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('数学文化'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '人物'),
              Tab(text: '数学故事'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 数学人物标签页
            MathematicianListview(key: _mathematicianListKey),
            // 数学故事标签页
            ListView.builder(
              itemCount: 10, // 示例数据
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.auto_stories),
                    title: Text('数学故事 ${index + 1}'),
                    subtitle: const Text('故事简介...'),
                    onTap: () {
                      // 导航到故事详情页
                    },
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(),
      ),
    );
  }

}

