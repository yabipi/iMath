import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/config/config.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/pages/article/article_refresh_list.dart';

import 'package:imath/pages/common/bottom_navigation_bar.dart';

import 'mathematician_listview.dart';

class ExperienceScreen extends StatefulWidget {
  ExperienceScreen({super.key});

  @override
  _ExperienceScreenState createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  final GlobalKey<MathematicianListviewState> _mathematicianListKey = GlobalKey<MathematicianListviewState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          HOME_COLUMN.EXPERIENCE.value,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),// 确保标题居中
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/admin/addArticle');
        },
        child: const Icon(Icons.add),
      ),
      body: ArticleRefreshListScreen(articleType: ArticleType.experience),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}