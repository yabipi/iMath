import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/config/config.dart';
import 'package:imath/config/constants.dart';

import 'package:imath/pages/common/bottom_navigation_bar.dart';
import 'package:imath/pages/culture/article_refresh_list.dart';
import '../../models/mathematician.dart';
import 'article_listview.dart';
import 'mathematician_detail_screen.dart';
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
        centerTitle: true, // 确保标题居中
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