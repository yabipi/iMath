import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';

class CategoryPanel extends StatelessWidget {
  Map<String, dynamic> categories = Context.get(CATEGORIES_KEY);
  Function(int)? onItemTap; // 点击 item 的回调函数

  int _selectedCategoryId = -1;

  CategoryPanel({this.onItemTap});


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: TabBar(
        isScrollable: true,
        tabs: categories.entries.map((entry) {
          return Tab(
            text: entry.value,
            // onTap: () => onItemTap(entry.key), // Tab 可以直接绑定 onTap
          );
        }).toList(),
        onTap: (int index){
          String categoryId = categories.keys.toList()[index];
          // print('点击${categories[categoryId.toString()]}');
          onItemTap!(int.parse(categoryId));
        }, // 当前 tab 被点击时触发回调
      ),
    );
  }

  Widget _buildNormalPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8.0, // 水平间距
        runSpacing: 8.0, // 垂直间距
        children: [
          // 新增：全部分类标签
          GestureDetector(
            onTap: () {
              // setState(() {
              //   _selectedCategoryId = -1;
              // });
            },
            child: Chip(
              label: const Text('全部'),
              labelStyle: TextStyle(
                color: _selectedCategoryId == -1
                    ? Colors.white
                    : Colors.black,
              ),
              backgroundColor: _selectedCategoryId == -1
                  ? Colors.blue
                  : Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          ...categories?.keys.map((key) {
                final categoryId = key;
                final categoryName = categories![categoryId];
                return GestureDetector(
                  onTap: () {
                    // setState(() {
                    //   _selectedCategoryId = categoryId! as int;
                    // });
                  },
                  child: Chip(
                    label: Text(categoryName!),
                    labelStyle: TextStyle(
                      color: _selectedCategoryId == categoryId
                          ? Colors.white
                          : Colors.black,
                    ),
                    backgroundColor: _selectedCategoryId == categoryId
                        ? Colors.blue
                        : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList() ??
              [],
        ],
      ),
    );

  }
}