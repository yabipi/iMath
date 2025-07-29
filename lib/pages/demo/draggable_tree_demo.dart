import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/draggable_tree.dart';
import '../../widgets/draggable_tree_controller.dart';

/// 可拖拽树组件演示页面
class DraggableTreeDemo extends StatefulWidget {
  const DraggableTreeDemo({super.key});

  @override
  State<DraggableTreeDemo> createState() => _DraggableTreeDemoState();
}

class _DraggableTreeDemoState extends State<DraggableTreeDemo> {
  late DraggableTreeController _controller;
  final TextEditingController _nodeNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = DraggableTreeController();

    // 设置回调函数
    _controller.onTreeChanged = () {
      setState(() {});
    };

    _controller.onNodeSelected = (node) {
      setState(() {});
    };

    _controller.onDragStarted = (node) {
      setState(() {});
    };

    _controller.onDragEnded = () {
      setState(() {});
    };

    // 加载示例数据
    _loadSampleData();
  }

  @override
  void dispose() {
    _nodeNameController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    // 从JSON字符串加载数据
    const sampleJson = '''
    [
      {
        "id": "1",
        "label": "数学基础",
        "isExpanded": true,
        "children": [
          {
            "id": "1-1",
            "label": "代数",
            "isExpanded": false,
            "children": [
              {
                "id": "1-1-1",
                "label": "线性代数",
                "isExpanded": false,
                "children": [
                  {"id": "1-1-1-1", "label": "矩阵", "isExpanded": false, "children": []},
                  {"id": "1-1-1-2", "label": "向量", "isExpanded": false, "children": []},
                  {"id": "1-1-1-3", "label": "行列式", "isExpanded": false, "children": []}
                ]
              },
              {"id": "1-1-2", "label": "多项式", "isExpanded": false, "children": []},
              {"id": "1-1-3", "label": "方程", "isExpanded": false, "children": []}
            ]
          },
          {
            "id": "1-2",
            "label": "几何",
            "isExpanded": true,
            "children": [
              {"id": "1-2-1", "label": "平面几何", "isExpanded": false, "children": []},
              {"id": "1-2-2", "label": "立体几何", "isExpanded": false, "children": []},
              {"id": "1-2-3", "label": "解析几何", "isExpanded": false, "children": []}
            ]
          }
        ]
      },
      {
        "id": "2",
        "label": "微积分",
        "isExpanded": false,
        "children": [
          {"id": "2-1", "label": "微分", "isExpanded": false, "children": []},
          {"id": "2-2", "label": "积分", "isExpanded": false, "children": []}
        ]
      },
      {
        "id": "3",
        "label": "概率统计",
        "isExpanded": false,
        "children": [
          {"id": "3-1", "label": "概率论", "isExpanded": false, "children": []},
          {"id": "3-2", "label": "数理统计", "isExpanded": false, "children": []}
        ]
      }
    ]
    ''';

    _controller.loadFromJson(sampleJson);
  }

  void _addNewNode() {
    if (_nodeNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入节点名称')),
      );
      return;
    }

    _controller.addNode(
      _nodeNameController.text.trim(),
      parent: _controller.selectedNode,
    );
    _nodeNameController.clear();
  }

  void _removeSelectedNode() {
    if (_controller.selectedNode != null) {
      _controller.removeNode(_controller.selectedNode!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择一个节点')),
      );
    }
  }

  void _showTreeData() {
    final jsonData = _controller.getTreeData();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('当前树数据 (JSON)'),
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
        title: const Text('可拖拽树组件演示'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          if (_controller.selectedNode != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _removeSelectedNode,
              tooltip: '删除选中节点',
            ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: _showTreeData,
            tooltip: '查看JSON数据',
          ),
        ],
      ),
      body: Column(
        children: [
          // 拖拽状态提示
          if (_controller.draggedNode != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const Icon(Icons.drag_handle, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '正在拖拽: ${_controller.draggedNode!.label}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (_controller.dragTargetNode != null &&
                      _controller.dragPosition != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPositionColor(_controller.dragPosition!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getPositionText(_controller.dragPosition!),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),

          // 操作说明
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '操作说明:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• 点击箭头: 展开/折叠子节点'),
                const Text('• 点击节点: 选中节点'),
                const Text('• 长按节点: 开始拖拽'),
                const Text('• 拖拽到节点右侧: 成为子节点（绿色边框）'),
                const Text('• 拖拽到节点上方: 成为上方兄弟节点（蓝色横线）'),
                const Text('• 拖拽到节点下方: 成为下方兄弟节点（蓝色横线）'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(width: 16, height: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text('子节点', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    Container(width: 16, height: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('兄弟节点', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // 添加节点区域
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nodeNameController,
                    decoration: const InputDecoration(
                      hintText: '输入新节点名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addNewNode,
                  child: const Text('添加节点'),
                ),
              ],
            ),
          ),

          // 选中节点信息
          if (_controller.selectedNode != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.purple[50],
              child: Text(
                '选中节点: ${_controller.selectedNode!.label}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          // 树形结构
          Expanded(
            child: DraggableTree(
              controller: _controller,
              nodeHeight: 48.0,
              indentWidth: 20.0,
              showDragIndicator: true,
              showSelection: true,
              selectedColor: Colors.purple[100],
              dragIndicatorColor: Colors.blue,
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'expand_all',
            onPressed: () => _controller.expandAll(),
            backgroundColor: Colors.orange,
            tooltip: '展开所有',
            child: const Icon(Icons.expand_more),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'collapse_all',
            onPressed: () => _controller.collapseAll(),
            backgroundColor: Colors.red,
            tooltip: '折叠所有',
            child: const Icon(Icons.expand_less),
          ),
        ],
      ),
    );
  }

  Color _getPositionColor(DragPosition position) {
    switch (position) {
      case DragPosition.child:
        return Colors.green;
      case DragPosition.siblingAbove:
        return Colors.blue;
      case DragPosition.siblingBelow:
        return Colors.blue;
    }
  }

  String _getPositionText(DragPosition position) {
    switch (position) {
      case DragPosition.child:
        return '作为子节点';
      case DragPosition.siblingAbove:
        return '作为兄弟节点(上方)';
      case DragPosition.siblingBelow:
        return '作为兄弟节点(下方)';
    }
  }
}
