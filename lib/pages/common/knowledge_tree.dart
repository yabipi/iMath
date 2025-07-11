import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:animated_tree_view/tree_view/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:imath/config/constants.dart';

import 'package:imath/core/context.dart';
import 'package:imath/core/global.dart';

final defaultTree = TreeNode.root()
  ..addAll([
    TreeNode(key: "0A", data: 'd_0A')
      ..add(TreeNode(key: "0A1A", data: 'd_0A1A')),
    TreeNode(key: "0C", data: 'd_0C')
      ..addAll([
        TreeNode(key: "0C1A", data: 'd_0C1A'),
        TreeNode(key: "0C1B", data: 'd_0C1B'),
        TreeNode(key: "0C1C", data: 'd_0C1C')
          ..addAll([TreeNode(key: "0C1C2A", data: 'd_0C1C2A')]),
      ]),
    TreeNode(key: "0D", data: 'd_0D'),
    TreeNode(key: "0E", data: 'd_0E'),
  ]);

final testTrees = <MapEntry<String, TreeNode>>[
  MapEntry("Default tree", defaultTree),

];

final Map<int, Color> colorMapper = {
  0: Colors.white,
  1: Colors.blueGrey[50]!,
  2: Colors.blueGrey[100]!,
  3: Colors.blueGrey[200]!,
  4: Colors.blueGrey[300]!,
  5: Colors.blueGrey[400]!,
  6: Colors.blueGrey[500]!,
  7: Colors.blueGrey[600]!,
  8: Colors.blueGrey[700]!,
  9: Colors.blueGrey[800]!,
  10: Colors.blueGrey[900]!,
};

class KnowledgeTree extends StatelessWidget {
  MATH_LEVEL level;
  // 定义mock的JSON数据
  late Map<String, dynamic> categories;
  void Function(int)? onChangeCategory;
  int stateCount = 0;
  KnowledgeTree({super.key, required this.level, this.onChangeCategory});

  @override
  Widget build(BuildContext context) {
    return _buildListView();
  }

  Widget _buildTree() {
    return TreeView.simple(
      tree: testTrees[stateCount].value,
      expansionBehavior: ExpansionBehavior.none,
      shrinkWrap: true,
      showRootNode: true,
      builder: (context, node) => Card(
        color: colorMapper[node.level.clamp(0, colorMapper.length - 1)]!,
        child: ListTile(
          title: Text("Item ${node.level}-${node.key}"),
          subtitle: Text('Data ${node.data}'),
        ),
      ),
    );
  }

  Widget _buildListView() {
    categories = Global.get(level.value);
    final keys = categories.keys.toList();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: keys.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            title: Text('初等数学', style: const TextStyle(fontSize: 18)), // 修改：字体加大一号
            onTap: () {
              onChangeCategory?.call(ALL_CATEGORY);
            },
          );
        }
        final item = categories[keys[index-1]];
        return ListTile(
          leading: Icon(Icons.arrow_right, color: Colors.blue), // 新增：添加图标
          title: Text(item),
          onTap: () {
            onChangeCategory?.call(int.parse(keys[index-1]));
          },
        );
      }
    );
  }
}