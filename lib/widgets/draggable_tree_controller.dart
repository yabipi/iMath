import 'dart:convert';

/// 树节点数据类
class TreeNode {
  final String id;
  final String label;
  final List<TreeNode> children;
  bool isExpanded;

  TreeNode({
    required this.id,
    required this.label,
    this.children = const [],
    this.isExpanded = false,
  });

  /// 从JSON创建树节点
  factory TreeNode.fromJson(Map<String, dynamic> json) {
    return TreeNode(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      isExpanded: json['isExpanded'] ?? false,
      children: (json['children'] as List<dynamic>?)
              ?.map((child) => TreeNode.fromJson(child))
              .toList() ??
          [],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'isExpanded': isExpanded,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  /// 复制节点
  TreeNode copyWith({
    String? id,
    String? label,
    List<TreeNode>? children,
    bool? isExpanded,
  }) {
    return TreeNode(
      id: id ?? this.id,
      label: label ?? this.label,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TreeNode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 拖拽位置类型
enum DragPosition {
  child, // 作为子节点
  siblingAbove, // 作为兄弟节点，位于上方
  siblingBelow, // 作为兄弟节点，位于下方
}

/// 可拖拽树控制器
class DraggableTreeController {
  List<TreeNode> _tree = [];
  TreeNode? _selectedNode;
  TreeNode? _draggedNode;
  TreeNode? _dragTargetNode;
  DragPosition? _dragPosition;

  // 回调函数
  Function()? onTreeChanged;
  Function(TreeNode?)? onNodeSelected;
  Function(TreeNode?)? onDragStarted;
  Function()? onDragEnded;

  /// 获取当前树数据
  List<TreeNode> get tree => _tree;

  /// 获取选中的节点
  TreeNode? get selectedNode => _selectedNode;

  /// 获取拖拽的节点
  TreeNode? get draggedNode => _draggedNode;

  /// 获取拖拽目标节点
  TreeNode? get dragTargetNode => _dragTargetNode;

  /// 获取拖拽位置
  DragPosition? get dragPosition => _dragPosition;

  /// 从JSON字符串初始化树
  void loadFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      _tree = jsonList.map((item) => TreeNode.fromJson(item)).toList();
      _notifyTreeChanged();
    } catch (e) {
      print('Error loading tree from JSON: $e');
      _tree = [];
    }
  }

  /// 从JSON对象列表初始化树
  void loadFromJsonList(List<Map<String, dynamic>> jsonList) {
    _tree = jsonList.map((item) => TreeNode.fromJson(item)).toList();
    _notifyTreeChanged();
  }

  /// 获取树的JSON数据
  String getTreeData() {
    return json.encode(_tree.map((node) => node.toJson()).toList());
  }

  /// 获取树的JSON对象列表
  List<Map<String, dynamic>> getTreeJsonList() {
    return _tree.map((node) => node.toJson()).toList();
  }

  /// 设置选中节点
  void selectNode(TreeNode? node) {
    _selectedNode = node;
    onNodeSelected?.call(node);
  }

  /// 开始拖拽
  void startDrag(TreeNode node) {
    _draggedNode = node;
    onDragStarted?.call(node);
  }

  /// 结束拖拽
  void endDrag() {
    _draggedNode = null;
    _dragTargetNode = null;
    _dragPosition = null;
    onDragEnded?.call();
  }

  /// 更新拖拽状态
  void updateDragState(TreeNode targetNode, DragPosition position) {
    _dragTargetNode = targetNode;
    _dragPosition = position;
  }

  /// 执行拖拽操作
  void performDrag(
      TreeNode draggedNode, TreeNode targetNode, DragPosition position) {
    if (_isDescendant(draggedNode, targetNode)) {
      return; // 防止拖拽到自己或子节点
    }

    // 从原位置移除节点
    _removeNodeFromTree(draggedNode, _tree);

    switch (position) {
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

    _notifyTreeChanged();
  }

  /// 添加新节点
  void addNode(String label, {TreeNode? parent}) {
    final newNode = TreeNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
    );

    if (parent != null) {
      _addAsChild(newNode, parent);
    } else {
      _tree.add(newNode);
    }

    _notifyTreeChanged();
  }

  /// 删除节点
  void removeNode(TreeNode node) {
    _removeNodeFromTree(node, _tree);
    if (_selectedNode == node) {
      _selectedNode = null;
      onNodeSelected?.call(null);
    }
    _notifyTreeChanged();
  }

  /// 切换节点展开状态
  void toggleNode(TreeNode node) {
    node.isExpanded = !node.isExpanded;
    _notifyTreeChanged();
  }

  /// 展开所有节点
  void expandAll() {
    _expandAllNodes(_tree);
    _notifyTreeChanged();
  }

  /// 折叠所有节点
  void collapseAll() {
    _collapseAllNodes(_tree);
    _notifyTreeChanged();
  }

  // 私有方法

  void _notifyTreeChanged() {
    onTreeChanged?.call();
  }

  void _addAsChild(TreeNode draggedNode, TreeNode targetNode) {
    final newChildren = <TreeNode>[
      ...targetNode.children,
      draggedNode,
    ];

    final newTargetNode = targetNode.copyWith(
      children: newChildren,
      isExpanded: true,
    );

    _replaceNodeInTree(targetNode, newTargetNode, _tree);
  }

  void _addAsSibling(TreeNode draggedNode, TreeNode targetNode,
      {required bool above}) {
    final parent = _findParentNode(targetNode, _tree);

    if (parent != null) {
      final parentChildren = List<TreeNode>.from(parent.children);
      final targetIndex = parentChildren.indexOf(targetNode);
      final insertIndex = above ? targetIndex : targetIndex + 1;
      parentChildren.insert(insertIndex, draggedNode);

      final newParent = parent.copyWith(children: parentChildren);
      _replaceNodeInTree(parent, newParent, _tree);
    } else {
      final targetIndex = _tree.indexOf(targetNode);
      final insertIndex = above ? targetIndex : targetIndex + 1;
      _tree.insert(insertIndex, draggedNode);
    }
  }

  bool _isDescendant(TreeNode parent, TreeNode child) {
    if (parent == child) return true;
    for (final node in parent.children) {
      if (_isDescendant(node, child)) return true;
    }
    return false;
  }

  void _removeNodeFromTree(TreeNode node, List<TreeNode> tree) {
    for (int i = 0; i < tree.length; i++) {
      if (tree[i] == node) {
        tree.removeAt(i);
        return;
      }
      _removeNodeFromTree(node, tree[i].children);
    }
  }

  void _replaceNodeInTree(
      TreeNode oldNode, TreeNode newNode, List<TreeNode> tree) {
    for (int i = 0; i < tree.length; i++) {
      if (tree[i] == oldNode) {
        tree[i] = newNode;
        return;
      }
      _replaceNodeInTree(oldNode, newNode, tree[i].children);
    }
  }

  TreeNode? _findParentNode(TreeNode targetNode, List<TreeNode> tree) {
    for (final node in tree) {
      if (node.children.contains(targetNode)) {
        return node;
      }
      final parent = _findParentNode(targetNode, node.children);
      if (parent != null) return parent;
    }
    return null;
  }

  void _expandAllNodes(List<TreeNode> nodes) {
    for (final node in nodes) {
      node.isExpanded = true;
      _expandAllNodes(node.children);
    }
  }

  void _collapseAllNodes(List<TreeNode> nodes) {
    for (final node in nodes) {
      node.isExpanded = false;
      _collapseAllNodes(node.children);
    }
  }
}
