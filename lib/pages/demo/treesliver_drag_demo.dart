import 'package:flutter/material.dart';

/// 自定义树节点类
class CustomTreeNode {
  final String data;
  final List<CustomTreeNode> children;
  bool isExpanded;

  CustomTreeNode(this.data, {this.children = const [], this.isExpanded = false});

  CustomTreeNode copyWith({
    String? data,
    List<CustomTreeNode>? children,
    bool? isExpanded,
  }) {
    return CustomTreeNode(
      data ?? this.data,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// 专门演示TreeSliver拖拽功能的页面

class TreeSliverDragDemo extends StatefulWidget {
  const TreeSliverDragDemo({super.key});

  @override
  State<TreeSliverDragDemo> createState() => _TreeSliverDragDemoState();
}

class _TreeSliverDragDemoState extends State<TreeSliverDragDemo> {
  CustomTreeNode? _selectedNode;
  CustomTreeNode? _draggedNode;
  
  // 创建一个更复杂的树结构用于演示
  final List<CustomTreeNode> _tree = <CustomTreeNode>[
    CustomTreeNode('数学基础'),
    CustomTreeNode(
      '代数',
      children: <CustomTreeNode>[
        CustomTreeNode(
          '线性代数',
          children: <CustomTreeNode>[
            CustomTreeNode('矩阵'),
            CustomTreeNode('向量'),
            CustomTreeNode('行列式'),
          ],
        ),
        CustomTreeNode('多项式'),
        CustomTreeNode('方程'),
      ],
    ),
    CustomTreeNode(
      '几何',
      isExpanded: true,
      children: <CustomTreeNode>[
        CustomTreeNode('平面几何'),
        CustomTreeNode('立体几何'),
        CustomTreeNode('解析几何'),
      ],
    ),
    CustomTreeNode('微积分'),
  ];

  void _onDragStarted(CustomTreeNode node) {
    setState(() {
      _draggedNode = node;
    });
  }

  void _onDragEnd() {
    setState(() {
      _draggedNode = null;
    });
  }

  void _onDragAccepted(CustomTreeNode draggedNode, CustomTreeNode targetNode) {
    setState(() {
      // 防止拖拽到自己或子节点
      if (_isDescendant(draggedNode, targetNode)) {
        return;
      }
      
      // 从原位置移除
      _removeNodeFromTree(draggedNode, _tree);
      
      // 添加到目标位置
      final newChildren = <CustomTreeNode>[
        ...targetNode.children,
        draggedNode,
      ];
      
      // 创建新的节点来替换原节点
      final newTargetNode = targetNode.copyWith(
        children: newChildren,
        isExpanded: true,
      );
      
      // 替换原节点
      _replaceNodeInTree(targetNode, newTargetNode, _tree);
    });
  }

  bool _isDescendant(CustomTreeNode parent, CustomTreeNode child) {
    if (parent == child) return true;
    for (final node in parent.children) {
      if (_isDescendant(node, child)) return true;
    }
    return false;
  }

  void _removeNodeFromTree(CustomTreeNode node, List<CustomTreeNode> tree) {
    for (int i = 0; i < tree.length; i++) {
      if (tree[i] == node) {
        tree.removeAt(i);
        return;
      }
      _removeNodeFromTree(node, tree[i].children);
    }
  }

  void _replaceNodeInTree(CustomTreeNode oldNode, CustomTreeNode newNode, List<CustomTreeNode> tree) {
    for (int i = 0; i < tree.length; i++) {
      if (tree[i] == oldNode) {
        tree[i] = newNode;
        return;
      }
      _replaceNodeInTree(oldNode, newNode, tree[i].children);
    }
  }

  void _addNewNode() {
    setState(() {
      final newNode = CustomTreeNode('新知识点 ${_tree.length + 1}');
      _tree.add(newNode);
    });
  }

  void _removeSelectedNode() {
    if (_selectedNode != null) {
      setState(() {
        _removeNodeFromTree(_selectedNode!, _tree);
        _selectedNode = null;
      });
    }
  }

  void _toggleNode(CustomTreeNode node) {
    setState(() {
      node.isExpanded = !node.isExpanded;
    });
  }

  Widget _buildTreeNode(CustomTreeNode node, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 节点本身
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedNode = node;
            });
          },
          onLongPress: () {
            setState(() {
              _draggedNode = node;
            });
          },
          child: Draggable<CustomTreeNode>(
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
                      node.data,
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
            onDragStarted: () => _onDragStarted(node),
            onDragEnd: (_) => _onDragEnd(),
            child: DragTarget<CustomTreeNode>(
              onWillAcceptWithDetails: (details) {
                return details.data != node && 
                       !_isDescendant(details.data, node);
              },
              onAcceptWithDetails: (details) {
                _onDragAccepted(details.data, node);
              },
              builder: (context, candidateData, rejectedData) {
                Widget result = _buildNodeContent(node, level);
                
                // 拖拽悬停效果
                if (candidateData.isNotEmpty) {
                  result = Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.blue.withValues(alpha: 0.1),
                    ),
                    child: result,
                  );
                }
                
                // 选中状态
                if (_selectedNode == node) {
                  result = Container(
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: result,
                  );
                }
                
                // 拖拽状态
                if (_draggedNode == node) {
                  result = Opacity(
                    opacity: 0.5,
                    child: result,
                  );
                }
                
                return result;
              },
            ),
          ),
        ),
        
        // 子节点
        if (node.isExpanded && node.children.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
              children: node.children.map((child) => _buildTreeNode(child, level + 1)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildNodeContent(CustomTreeNode node, int level) {
    return Container(
      padding: EdgeInsets.only(left: level * 20.0, top: 8, bottom: 8),
      child: Row(
        children: [
          if (node.children.isNotEmpty)
            GestureDetector(
              onTap: () => _toggleNode(node),
              child: Icon(
                node.isExpanded ? Icons.expand_more : Icons.chevron_right,
                size: 20,
              ),
            )
          else
            const SizedBox(width: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              node.data,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TreeSliver 拖拽演示'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedNode != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _removeSelectedNode,
              tooltip: '删除选中节点',
            ),
        ],
      ),
      body: Column(
        children: [
          // 拖拽状态提示
          if (_draggedNode != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const Icon(Icons.drag_handle, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '正在拖拽: ${_draggedNode!.data}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '拖拽到目标节点上',
                      style: TextStyle(fontSize: 12),
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
                const Text('• 拖拽到其他节点: 移动节点'),
                const Text('• 点击节点选中后可以删除'),
              ],
            ),
          ),
          
          // 树形结构
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tree.length,
              itemBuilder: (context, index) {
                return _buildTreeNode(_tree[index], 0);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addNewNode,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
            tooltip: '添加新节点',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                for (final node in _tree) {
                  _expandAll(node);
                }
              });
            },
            backgroundColor: Colors.orange,
            child: const Icon(Icons.expand_more),
            tooltip: '展开所有',
          ),
        ],
      ),
    );
  }

  void _expandAll(CustomTreeNode node) {
    node.isExpanded = true;
    for (final child in node.children) {
      _expandAll(child);
    }
  }
} 