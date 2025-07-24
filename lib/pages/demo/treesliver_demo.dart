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

/// 拖拽位置类型
enum DragPosition {
  child,    // 作为子节点
  siblingAbove,  // 作为兄弟节点，位于上方
  siblingBelow,  // 作为兄弟节点，位于下方
}

/// Flutter code sample for [TreeSliver] with intelligent drag and drop functionality.

void main() => runApp(const TreeSliverExampleApp());

class TreeSliverExampleApp extends StatelessWidget {
  const TreeSliverExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: TreeSliverExample());
  }
}

class TreeSliverExample extends StatefulWidget {
  const TreeSliverExample({super.key});

  @override
  State<TreeSliverExample> createState() => _TreeSliverExampleState();
}

class _TreeSliverExampleState extends State<TreeSliverExample> {
  CustomTreeNode? _selectedNode;
  CustomTreeNode? _draggedNode;
  CustomTreeNode? _dragTargetNode;
  DragPosition? _dragPosition;
  final GlobalKey _listKey = GlobalKey();
  
  final List<CustomTreeNode> _tree = <CustomTreeNode>[
    CustomTreeNode('First'),
    CustomTreeNode(
      'Second',
      children: <CustomTreeNode>[
        CustomTreeNode(
          'alpha',
          children: <CustomTreeNode>[
            CustomTreeNode('uno'),
            CustomTreeNode('dos'),
            CustomTreeNode('tres'),
          ],
        ),
        CustomTreeNode('beta'),
        CustomTreeNode('kappa'),
      ],
    ),
    CustomTreeNode(
      'Third',
      isExpanded: true,
      children: <CustomTreeNode>[
        CustomTreeNode('gamma'),
        CustomTreeNode('delta'),
        CustomTreeNode('epsilon'),
      ],
    ),
    CustomTreeNode('Fourth'),
  ];

  // 拖拽相关方法
  void _onDragStarted(CustomTreeNode node) {
    setState(() {
      _draggedNode = node;
    });
  }

  void _onDragEnd() {
    setState(() {
      _draggedNode = null;
      _dragTargetNode = null;
      _dragPosition = null;
    });
  }

  void _onDragUpdate(DragTargetDetails<CustomTreeNode> details, CustomTreeNode targetNode) {
    setState(() {
      _dragTargetNode = targetNode;
      _dragPosition = _calculateDragPosition(details, targetNode);
      
      // 调试信息
      final targetLevel = _getNodeLevel(targetNode, _tree);
      final targetLeft = 16.0 + (targetLevel * 20.0);
      final textWidth = targetNode.data.length * 10.0 + 20.0 + 16.0;
      final targetRight = targetLeft + textWidth;
      
      print('拖拽调试: dragLeft=${details.offset.dx}, targetRight=$targetRight, 目标节点="${targetNode.data}", 层级=$targetLevel');
    });
  }

  DragPosition _calculateDragPosition(DragTargetDetails<CustomTreeNode> details, CustomTreeNode targetNode) {
    // 获取目标节点的渲染对象
    final RenderBox? renderBox = _listKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return DragPosition.child;

    // 获取目标节点在列表中的位置
    final targetIndex = _findNodeIndex(targetNode, _tree);
    if (targetIndex == -1) return DragPosition.child;

    // 计算目标节点的位置信息
    const nodeHeight = 48.0;
    const padding = 16.0;
    final targetTop = padding + (targetIndex * nodeHeight);
    final targetCenter = targetTop + (nodeHeight / 2);
    final targetBottom = targetTop + nodeHeight;
    
    // 获取拖拽位置
    final dragTop = details.offset.dy;
    final dragLeft = details.offset.dx;
    
    // 计算目标节点的水平位置（根据层级缩进）
    final targetLevel = _getNodeLevel(targetNode, _tree);
    final targetLeft = padding + (targetLevel * 20.0); // 每层缩进20px
    
    // 估算目标节点文本的右边缘位置
    // 文本宽度 = 文本长度 * 字符宽度(约10px) + 图标宽度(20px) + 间距(16px) + 缩进(level * 20)
    final textWidth = targetNode.data.length * 10.0 + 20.0 + 16.0;
    final targetRight = targetLeft + textWidth;
    
    // 判断逻辑：首先检查水平位置
    if (dragLeft > targetRight) {
      // 源节点左边缘超过目标节点右边缘，成为子节点
      return DragPosition.child;
    } else {
      // 其他情况根据垂直位置判断兄弟节点位置
      if (dragTop < targetCenter) {
        return DragPosition.siblingAbove;
      } else {
        return DragPosition.siblingBelow;
      }
    }
  }

  int _findNodeIndex(CustomTreeNode node, List<CustomTreeNode> tree, [int currentIndex = 0]) {
    for (int i = 0; i < tree.length; i++) {
      if (tree[i] == node) {
        return currentIndex + i;
      }
      if (tree[i].isExpanded) {
        final childIndex = _findNodeIndex(node, tree[i].children, currentIndex + i + 1);
        if (childIndex != -1) return childIndex;
      }
    }
    return -1;
  }

  int _getNodeLevel(CustomTreeNode targetNode, List<CustomTreeNode> tree, [int level = 0]) {
    for (final node in tree) {
      if (node == targetNode) {
        return level;
      }
      if (node.isExpanded) {
        final childLevel = _getNodeLevel(targetNode, node.children, level + 1);
        if (childLevel != -1) return childLevel;
      }
    }
    return -1;
  }

  void _onDragAccepted(CustomTreeNode draggedNode, CustomTreeNode targetNode) {
    if (_dragPosition == null) return;
    
    setState(() {
      // 检查是否试图拖拽到自己或自己的子节点
      if (_isDescendant(draggedNode, targetNode)) {
        return;
      }
      
      // 从原位置移除节点
      _removeNodeFromTree(draggedNode, _tree);
      
      switch (_dragPosition!) {
        case DragPosition.child:
          _addAsChild(draggedNode, targetNode);
          break;
        case DragPosition.siblingAbove:
          _addAsSibling(draggedNode, targetNode, above: true);
          break;
        case DragPosition.siblingBelow:
          _addAsSibling(draggedNode, targetNode, above: false);
          break;
      }
    });
  }

  void _addAsChild(CustomTreeNode draggedNode, CustomTreeNode targetNode) {
    // 将节点添加到目标位置
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
  }

  void _addAsSibling(CustomTreeNode draggedNode, CustomTreeNode targetNode, {required bool above}) {
    // 找到目标节点的父节点
    final parent = _findParentNode(targetNode, _tree);
    
    if (parent != null) {
      // 作为兄弟节点添加到父节点
      final parentChildren = List<CustomTreeNode>.from(parent.children);
      final targetIndex = parentChildren.indexOf(targetNode);
      final insertIndex = above ? targetIndex : targetIndex + 1;
      parentChildren.insert(insertIndex, draggedNode);
      
      final newParent = parent.copyWith(children: parentChildren);
      _replaceNodeInTree(parent, newParent, _tree);
    } else {
      // 目标节点是根节点
      final targetIndex = _tree.indexOf(targetNode);
      final insertIndex = above ? targetIndex : targetIndex + 1;
      _tree.insert(insertIndex, draggedNode);
    }
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

  CustomTreeNode? _findParentNode(CustomTreeNode targetNode, List<CustomTreeNode> tree) {
    for (final node in tree) {
      if (node.children.contains(targetNode)) {
        return node;
      }
      final parent = _findParentNode(targetNode, node.children);
      if (parent != null) return parent;
    }
    return null;
  }

  void _addNewNode() {
    setState(() {
      final newNode = CustomTreeNode('New Node ${_tree.length + 1}');
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
        // 上方横线指示器（当拖拽到上方兄弟节点时）
        if (_dragTargetNode == node && _dragPosition == DragPosition.siblingAbove)
          Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        
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
              onMove: (details) {
                _onDragUpdate(details, node);
              },
              builder: (context, candidateData, rejectedData) {
                Widget result = _buildNodeContent(node, level);
                
                // 拖拽悬停效果
                if (candidateData.isNotEmpty) {
                  Color borderColor = Colors.blue;
                  Color backgroundColor = Colors.blue.withValues(alpha: 0.1);
                  
                  // 根据拖拽位置显示不同的视觉效果
                  if (_dragTargetNode == node && _dragPosition != null) {
                    switch (_dragPosition!) {
                      case DragPosition.child:
                        borderColor = Colors.green;
                        backgroundColor = Colors.green.withValues(alpha: 0.1);
                        break;
                      case DragPosition.siblingAbove:
                        borderColor = Colors.orange;
                        backgroundColor = Colors.orange.withValues(alpha: 0.1);
                        break;
                      case DragPosition.siblingBelow:
                        borderColor = Colors.purple;
                        backgroundColor = Colors.purple.withValues(alpha: 0.1);
                        break;
                    }
                  }
                  
                  result = Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      color: backgroundColor,
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
        
        // 下方横线指示器（当拖拽到下方兄弟节点时）
        if (_dragTargetNode == node && _dragPosition == DragPosition.siblingBelow)
          Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
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
        title: const Text('TreeSliver Demo with Intelligent Drag & Drop'),
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
                  if (_dragTargetNode != null && _dragPosition != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPositionColor(_dragPosition!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getPositionText(_dragPosition!),
                        style: const TextStyle(fontSize: 12, color: Colors.white),
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
                  '智能拖拽说明:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• 点击箭头: 展开/折叠子节点'),
                const Text('• 点击节点: 选中节点'),
                const Text('• 长按节点: 开始拖拽'),
                const Text('• 拖拽到节点右侧: 成为子节点（绿色边框）'),
                const Text('• 拖拽到节点上方: 成为上方兄弟节点（蓝色横线）'),
                const Text('• 拖拽到节点下方: 成为下方兄弟节点（蓝色横线）'),
              ],
            ),
          ),
          
          // 树形结构
          Expanded(
            child: ListView.builder(
              key: _listKey,
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
            tooltip: '添加新节点',
            child: const Icon(Icons.add),
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
            tooltip: '展开所有',
            child: const Icon(Icons.expand_more),
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

  void _expandAll(CustomTreeNode node) {
    node.isExpanded = true;
    for (final child in node.children) {
      _expandAll(child);
    }
  }
}