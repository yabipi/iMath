import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/widgets/draggable_tree.dart';
import 'package:imath/widgets/draggable_tree_controller.dart';


/// 可拖拽树组件演示页面
class DraggableTreeDemo extends StatefulWidget {
  const DraggableTreeDemo({super.key});

  @override
  State<DraggableTreeDemo> createState() => _DraggableTreeDemoState();
}

class _DraggableTreeDemoState extends State<DraggableTreeDemo> {
  late DraggableTreeController _controller;
  final TextEditingController _nodeNameController = TextEditingController();
  bool _showJsonData = false; // 新增：控制是否显示JSON数据
  bool _jsonDataUpdated = false; // 新增：标记JSON数据是否已更新

  @override
  void initState() {
    super.initState();
    _controller = DraggableTreeController();

    // 设置回调函数
    _controller.onTreeChanged = () {
      setState(() {
        _jsonDataUpdated = true;
      });
      // 如果JSON数据区域是显示的，可以在这里添加一些视觉反馈
      if (_showJsonData) {
        // 可以添加一个短暂的闪烁效果来提示数据已更新
      }
    };

    _controller.onNodeSelected = (node) {
      setState(() {});
    };

    _controller.onDragStarted = (node) {
      setState(() {});
    };

    _controller.onDragEnded = () {
      setState(() {});
      // 拖放结束后，如果JSON数据区域是显示的，可以添加提示
      if (_showJsonData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('树结构已更新，JSON数据已刷新'),
            duration: Duration(seconds: 1),
          ),
        );
      }
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
            icon: Icon(_showJsonData ? Icons.code_off : Icons.code),
            onPressed: () {
              setState(() {
                _showJsonData = !_showJsonData;
                if (_showJsonData) {
                  _jsonDataUpdated = false; // 重置更新标记
                }
              });
            },
            tooltip: _showJsonData ? '隐藏JSON数据' : '显示JSON数据',
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
            child: Column(
              children: [
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
                
                // JSON数据显示区域
                if (_showJsonData) ...[
                  const Divider(height: 1),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                                 Row(
                           children: [
                             Row(
                               children: [
                                 const Text(
                                   'JSON数据:',
                                   style: TextStyle(
                                     fontWeight: FontWeight.bold,
                                     fontSize: 14,
                                   ),
                                 ),
                                 if (_jsonDataUpdated) ...[
                                   const SizedBox(width: 8),
                                   Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                     decoration: BoxDecoration(
                                       color: Colors.green,
                                       borderRadius: BorderRadius.circular(8),
                                     ),
                                     child: const Text(
                                       '已更新',
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontSize: 10,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                   ),
                                 ],
                               ],
                             ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 16),
                              onPressed: () {
                                final jsonData = _controller.getTreeData();
                                final formattedJson = _formatJson(jsonData);
                                Clipboard.setData(ClipboardData(text: formattedJson));
                                setState(() {
                                  _jsonDataUpdated = false; // 重置更新标记
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('格式化JSON数据已复制到剪贴板'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              tooltip: '复制格式化JSON数据',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                _formatJson(_controller.getTreeData()),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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

  // 格式化JSON字符串，使其更易读
  String _formatJson(String jsonString) {
    try {
      // 解析JSON并重新格式化
      final jsonData = json.decode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonData);
    } catch (e) {
      // 如果解析失败，返回原始字符串
      return jsonString;
    }
  }
}
