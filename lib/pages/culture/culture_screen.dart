import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:imath/widgets/bottom_navigation_bar.dart';
import '../../models/mathematician.dart';
import 'article_listview.dart';
import 'mathematician_detail_screen.dart';
import 'mathematician_listview.dart';

class CultureScreen extends StatefulWidget {
  const CultureScreen({super.key});

  @override
  _CultureScreenState createState()  => _CultureScreenState();

}

class _CultureScreenState extends State<CultureScreen> {
  final GlobalKey<MathematicianListviewState> _mathematicianListKey = GlobalKey<MathematicianListviewState>();

  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('数学世界'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '人物'),
              Tab(text: '文章'),
            ],
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

