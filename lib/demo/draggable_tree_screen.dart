import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'dart:convert';

class CustomTreeNode {
  String key;
  String label;
  List<CustomTreeNode> children;

  CustomTreeNode({
    required this.key,
    required this.label,
    this.children = const [],
  });

  factory CustomTreeNode.fromJson(Map<String, dynamic> json) {
    return CustomTreeNode(
      key: json['key'] as String,
      label: json['label'] as String,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => CustomTreeNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
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
  final TreeController _treeController = TreeController(allNodesExpanded: true);
  late List<CustomTreeNode> roots;

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
    });
  }

  Widget _buildTreeNode(CustomTreeNode node, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReorderableDragStartListener(
          key: ValueKey(node.key),
          index: level,
          child: Container(
            padding: EdgeInsets.only(left: level * 40.0),
            child: Row(
              children: [
                const Icon(Icons.drag_handle),
                const SizedBox(width: 8),
                Text(node.label),
              ],
            ),
          ),
        ),
        if (node.children.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: node.children.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = node.children.removeAt(oldIndex);
                node.children.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              return _buildTreeNode(node.children[index], level + 1);
            },
          ),
      ],
    );
  }

  Widget _buildTree() {
    return ReorderableListView.builder(
      itemCount: roots.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = roots.removeAt(oldIndex);
          roots.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        return _buildTreeNode(roots[index], 0);
      },
    );
  }

  void _removeNodeByKey(String key, List<CustomTreeNode> nodes) {
    nodes.removeWhere((node) {
      if (node.key == key) return true;
      _removeNodeByKey(key, node.children);
      return false;
    });
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
              final json = jsonEncode(roots
                  .map((e) => {
                        'key': e.key,
                        'label': e.label,
                        'children': e.children
                            .map((child) => {
                                  'key': child.key,
                                  'label': child.label,
                                  'children': child.children,
                                })
                            .toList(),
                      })
                  .toList());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('树结构已保存: $json')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildTree(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRootNode,
        child: const Icon(Icons.add),
      ),
    );
  }
}
