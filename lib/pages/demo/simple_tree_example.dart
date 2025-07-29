import 'package:flutter/material.dart';
import '../../widgets/draggable_tree.dart';
import '../../widgets/draggable_tree_controller.dart';

/// 简单的树组件使用示例
class SimpleTreeExample extends StatefulWidget {
  const SimpleTreeExample({super.key});

  @override
  State<SimpleTreeExample> createState() => _SimpleTreeExampleState();
}

class _SimpleTreeExampleState extends State<SimpleTreeExample> {
  late DraggableTreeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DraggableTreeController();

    // 设置回调函数
    _controller.onTreeChanged = () {
      setState(() {});
    };

    // 加载简单的示例数据
    _loadSimpleData();
  }

  void _loadSimpleData() {
    // 从JSON对象列表加载数据
    final sampleData = [
      {
        "id": "1",
        "label": "根节点1",
        "isExpanded": true,
        "children": [
          {"id": "1-1", "label": "子节点1-1", "isExpanded": false, "children": []},
          {"id": "1-2", "label": "子节点1-2", "isExpanded": false, "children": []}
        ]
      },
      {
        "id": "2",
        "label": "根节点2",
        "isExpanded": false,
        "children": [
          {"id": "2-1", "label": "子节点2-1", "isExpanded": false, "children": []}
        ]
      }
    ];

    _controller.loadFromJsonList(sampleData);
  }

  void _showJsonData() {
    final jsonData = _controller.getTreeData();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('当前树数据'),
        content: SingleChildScrollView(
          child: SelectableText(jsonData),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('简单树组件示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: _showJsonData,
            tooltip: '查看JSON数据',
          ),
        ],
      ),
      body: Column(
        children: [
          // 操作说明
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '简单使用示例:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• 点击箭头: 展开/折叠子节点'),
                Text('• 点击节点: 选中节点'),
                Text('• 长按节点: 开始拖拽'),
                Text('• 拖拽到节点右侧: 成为子节点'),
                Text('• 拖拽到节点上方/下方: 成为兄弟节点'),
              ],
            ),
          ),

          // 树形结构
          Expanded(
            child: DraggableTree(
              controller: _controller,
              // 可以自定义外观
              nodeHeight: 40.0,
              indentWidth: 24.0,
              showDragIndicator: true,
              showSelection: true,
              selectedColor: Colors.blue[100],
              dragIndicatorColor: Colors.green,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 添加新节点到根级别
          _controller.addNode('新节点 ${DateTime.now().millisecondsSinceEpoch}');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
