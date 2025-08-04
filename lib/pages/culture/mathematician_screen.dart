import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/config/config.dart';

import 'package:imath/pages/common/bottom_navigation_bar.dart';
import '../../models/mathematician.dart';
import '../article/article_listview.dart';
import 'mathematician_detail_screen.dart';
import 'mathematician_listview.dart';

class MathematicianScreen extends StatefulWidget {
  int initialIndex;
  MathematicianScreen({super.key, this.initialIndex = 0});

  @override
  _MathematicianScreenState createState() => _MathematicianScreenState();
}

class _MathematicianScreenState extends State<MathematicianScreen> {
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
          title: Text(HOME_COLUMN.PEOPLE.value),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.go('/admin/addmathematician');
          },
          child: const Icon(Icons.add),
        ),
        body: MathematicianListview(),
        bottomNavigationBar: CustomBottomNavigationBar(),
      ),
    );
  }
}