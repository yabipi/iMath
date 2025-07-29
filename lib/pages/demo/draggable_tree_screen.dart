import 'package:flutter/material.dart';
import 'dart:convert';

class CustomTreeNode {
  String key;
  String label;
  List<CustomTreeNode> children;
  bool isExpanded;

  CustomTreeNode({
    required this.key,
    required this.label,
    List<CustomTreeNode>? children,
    this.isExpanded = true,
  }) : children = children ?? <CustomTreeNode>[];

  factory CustomTreeNode.fromJson(Map<String, dynamic> json) {
    return CustomTreeNode(
      key: json['key'] as String,
      label: json['label'] as String,
      isExpanded: json['isExpanded'] ?? true,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => CustomTreeNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <CustomTreeNode>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'isExpanded': isExpanded,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
}

class DraggableTreeScreen extends StatefulWidget {
  const DraggableTreeScreen({super.key});

  @override
  State<DraggableTreeScreen> createState() => _DraggableTreeScreenState();
}

class _DraggableTreeScreenState extends State<DraggableTreeScreen> {
  late List<CustomTreeNode> roots;
  final TextEditingController _jsonController = TextEditingController();
  CustomTreeNode? draggedNode;
  CustomTreeNode? dragTargetNode;

  @override
  void initState() {
    super.initState();
    roots = [
      CustomTreeNode(
        key: '1',
        label: '数学',
        children: [
          CustomTreeNode(
            key: '1.1',
            label: '代数',
            children: [
              CustomTreeNode(
                key: '1.1.1',
                label: '方程',
              ),
              CustomTreeNode(
                key: '1.1.2',
                label: '不等式',
              ),
            ],
          ),
          CustomTreeNode(
            key: '1.2',
            label: '几何',
            children: [
              CustomTreeNode(
                key: '1.2.1',
                label: '三角形',
              ),
              CustomTreeNode(
                key: '1.2.2',
                label: '圆',
              ),
            ],
          ),
        ],
      ),
    ];
    _updateJsonDisplay();
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  void _updateJsonDisplay() {
    final json = jsonEncode(roots.map((e) => e.toJson()).toList());
    _jsonController.text = json;
  }

  void _toggleNode(CustomTreeNode node) {
    setState(() {
      node.isExpanded = !node.isExpanded;
      _updateJsonDisplay();
    });
  }

  void _addNode(String parentKey) {
    setState(() {
      final parent = _findNodeByKey(parentKey, roots);
      if (parent != null) {
        final newKey = '${parent.key}.${parent.children.length + 1}';
        parent.children.add(
          CustomTreeNode(
            key: newKey,
            label: '新节点 $newKey',
          ),
        );
      }
      _updateJsonDisplay();
    });
  }

  CustomTreeNode? _findNodeByKey(String key, List<CustomTreeNode> nodes) {
    for (var node in nodes) {
      if (node.key == key) return node;
      final result = _findNodeByKey(key, node.children);
      if (result != null) return result;
    }
    return null;
  }

  void _addRootNode() {
    setState(() {
      roots.add(
        CustomTreeNode(
          key: '${roots.length + 1}',
          label: '新根节点 ${roots.length + 1}',
        ),
      );
      _updateJsonDisplay();
    });
  }

  void _removeNode(CustomTreeNode node) {
    setState(() {
      _removeNodeFromList(node, roots);
      _updateJsonDisplay();
    });
  }

  void _removeNodeFromList(CustomTreeNode node, List<CustomTreeNode> list) {
    list.removeWhere((item) {
      if (item == node) return true;
      _removeNodeFromList(node, item.children);
      return false;
    });
  }

  void _moveNode(
      CustomTreeNode draggedNode, CustomTreeNode targetNode, bool asChild) {
    if (draggedNode == targetNode) return;

    setState(() {
      // 从原位置移除节点
      _removeNodeFromList(draggedNode, roots);

      if (asChild) {
        // 作为子节点添加
        targetNode.children.add(draggedNode);
        targetNode.isExpanded = true;
      } else {
        // 作为兄弟节点添加
        final parent = _findParentNode(targetNode, roots);
        if (parent != null) {
          final index = parent.children.indexOf(targetNode);
          parent.children.insert(index, draggedNode);
        } else {
          final index = roots.indexOf(targetNode);
          roots.insert(index, draggedNode);
        }
      }
      _updateJsonDisplay();
    });
  }

  CustomTreeNode? _findParentNode(
      CustomTreeNode targetNode, List<CustomTreeNode> nodes) {
    for (var node in nodes) {
      if (node.children.contains(targetNode)) return node;
      final result = _findParentNode(targetNode, node.children);
      if (result != null) return result;
    }
    return null;
  }

  Widget _buildTreeNode(CustomTreeNode node, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Draggable<CustomTreeNode>(
          data: node,
          feedback: Material(
            elevation: 8.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.drag_handle, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    node.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildNodeContent(node, level),
          ),
          onDragStarted: () {
            setState(() {
              draggedNode = node;
            });
          },
          onDragEnd: (_) {
            setState(() {
              draggedNode = null;
              dragTargetNode = null;
            });
          },
          child: DragTarget<CustomTreeNode>(
            onWillAcceptWithDetails: (details) {
              return details.data != node;
            },
            onAcceptWithDetails: (details) {
              _moveNode(details.data, node, true);
            },
            onMove: (details) {
              setState(() {
                dragTargetNode = node;
              });
            },
            builder: (context, candidateData, rejectedData) {
              return _buildNodeContent(node, level);
            },
          ),
        ),
        if (node.isExpanded && node.children.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
              children: node.children
                  .map((child) => _buildTreeNode(child, level + 1))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildNodeContent(CustomTreeNode node, int level) {
    return Container(
      padding: EdgeInsets.only(left: level * 20.0, top: 8, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
        color: dragTargetNode == node ? Colors.blue[50] : null,
      ),
      child: Row(
        children: [
          if (node.children.isNotEmpty)
            GestureDetector(
              onTap: () => _toggleNode(node),
              child: Icon(
                node.isExpanded ? Icons.expand_more : Icons.chevron_right,
                size: 20,
                color: Colors.grey[600],
              ),
            )
          else
            const SizedBox(width: 20),
          const SizedBox(width: 8),
          const Icon(Icons.drag_handle, color: Colors.grey, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              node.label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 16),
            onPressed: () => _removeNode(node),
            color: Colors.red[400],
          ),
        ],
      ),
    );
  }

  Widget _buildTree() {
    return Column(
      children: roots.map((root) => _buildTreeNode(root, 0)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识点树'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('树结构已保存')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 拖拽状态提示
          if (draggedNode != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const Icon(Icons.drag_handle, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '正在拖拽: ${draggedNode!.label}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          // 树形结构
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildTree(),
            ),
          ),
          // JSON数据显示区域
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.code, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'JSON数据',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _jsonController,
                      maxLines: null,
                      expands: true,
                      readOnly: true,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRootNode,
        child: const Icon(Icons.add),
      ),
    );
  }
}
