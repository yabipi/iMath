import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:imath/pages/common/bottom_navigation_bar.dart';
import '../../models/mathematician.dart';
import 'article_listview.dart';
import 'mathematician_detail_screen.dart';
import 'mathematician_listview.dart';

class CultureScreen extends StatefulWidget {
  int initialIndex;
  CultureScreen({super.key, this.initialIndex = 0});

  @override
  _CultureScreenState createState() => _CultureScreenState();
}

class _CultureScreenState extends State<CultureScreen> {
  final GlobalKey<MathematicianListviewState> _mathematicianListKey = GlobalKey<MathematicianListviewState>();
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: currentIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('数学世界'),
          bottom: TabBar(
            tabs: [
              Tab(text: '人物'),
              Tab(text: '文章'),
            ],
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),
        body: TabBarView(
          children: [
            // 数学人物标签页
            MathematicianListview(),
            // 数学故事标签页
            ArticleListView(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(),
      ),
    );
  }
}