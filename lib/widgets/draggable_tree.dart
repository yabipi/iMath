import 'package:flutter/material.dart';
import 'draggable_tree_controller.dart';

/// 可拖拽树组件
class DraggableTree extends StatefulWidget {
  final DraggableTreeController controller;
  final double nodeHeight;
  final double indentWidth;
  final EdgeInsets padding;
  final bool showDragIndicator;
  final bool showSelection;
  final Widget Function(TreeNode node, int level)? nodeBuilder;
  final Widget Function(TreeNode node)? dragFeedbackBuilder;
  final Color? selectedColor;
  final Color? dragIndicatorColor;

  const DraggableTree({
    super.key,
    required this.controller,
    this.nodeHeight = 48.0,
    this.indentWidth = 20.0,
    this.padding = const EdgeInsets.all(16.0),
    this.showDragIndicator = true,
    this.showSelection = true,
    this.nodeBuilder,
    this.dragFeedbackBuilder,
    this.selectedColor,
    this.dragIndicatorColor,
  });

  @override
  State<DraggableTree> createState() => _DraggableTreeState();
}

class _DraggableTreeState extends State<DraggableTree> {
  final GlobalKey _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.controller.onTreeChanged = _onTreeChanged;
  }

  @override
  void dispose() {
    widget.controller.onTreeChanged = null;
    super.dispose();
  }

  void _onTreeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: _listKey,
      padding: widget.padding,
      itemCount: widget.controller.tree.length,
      itemBuilder: (context, index) {
        return _buildTreeNode(widget.controller.tree[index], 0);
      },
    );
  }

  Widget _buildTreeNode(TreeNode node, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 上方拖拽指示器
        if (widget.showDragIndicator &&
            widget.controller.dragTargetNode == node &&
            widget.controller.dragPosition == DragPosition.siblingAbove)
          Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: widget.dragIndicatorColor ?? Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

        // 节点本身
        _buildNodeContent(node, level),

        // 下方拖拽指示器
        if (widget.showDragIndicator &&
            widget.controller.dragTargetNode == node &&
            widget.controller.dragPosition == DragPosition.siblingBelow)
          Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: widget.dragIndicatorColor ?? Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

        // 子节点
        if (node.isExpanded && node.children.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: widget.indentWidth),
            child: Column(
              children: node.children
                  .map((child) => _buildTreeNode(child, level + 1))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildNodeContent(TreeNode node, int level) {
    return GestureDetector(
      onTap: () {
        if (widget.showSelection) {
          widget.controller.selectNode(node);
        }
      },
      onLongPress: () {
        widget.controller.startDrag(node);
      },
      child: Draggable<TreeNode>(
        data: node,
        feedback: widget.dragFeedbackBuilder?.call(node) ??
            _buildDefaultDragFeedback(node),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildNodeWidget(node, level),
        ),
        onDragStarted: () => widget.controller.startDrag(node),
        onDragEnd: (_) => widget.controller.endDrag(),
        child: DragTarget<TreeNode>(
          onWillAcceptWithDetails: (details) {
            return details.data != node && !_isDescendant(details.data, node);
          },
          onAcceptWithDetails: (details) {
            final position = _calculateDragPosition(details, node);
            widget.controller.performDrag(details.data, node, position);
          },
          onMove: (details) {
            final position = _calculateDragPosition(details, node);
            widget.controller.updateDragState(node, position);
          },
          builder: (context, candidateData, rejectedData) {
            Widget result = _buildNodeWidget(node, level);

            // 拖拽悬停效果
            if (candidateData.isNotEmpty) {
              Color borderColor = Colors.blue;
              Color backgroundColor = Colors.blue.withValues(alpha: 0.1);

              if (widget.controller.dragTargetNode == node &&
                  widget.controller.dragPosition != null) {
                switch (widget.controller.dragPosition!) {
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
            if (widget.showSelection &&
                widget.controller.selectedNode == node) {
              result = Container(
                decoration: BoxDecoration(
                  color: widget.selectedColor ?? Colors.purple[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: result,
              );
            }

            // 拖拽状态
            if (widget.controller.draggedNode == node) {
              result = Opacity(
                opacity: 0.5,
                child: result,
              );
            }

            return result;
          },
        ),
      ),
    );
  }

  Widget _buildNodeWidget(TreeNode node, int level) {
    if (widget.nodeBuilder != null) {
      return widget.nodeBuilder!(node, level);
    }

    return Container(
      height: widget.nodeHeight,
      padding: EdgeInsets.only(left: level * widget.indentWidth),
      child: Row(
        children: [
          if (node.children.isNotEmpty)
            GestureDetector(
              onTap: () => widget.controller.toggleNode(node),
              child: Icon(
                node.isExpanded ? Icons.expand_more : Icons.chevron_right,
                size: 20,
              ),
            )
          else
            SizedBox(width: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              node.label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultDragFeedback(TreeNode node) {
    return Material(
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
    );
  }

  DragPosition _calculateDragPosition(
      DragTargetDetails<TreeNode> details, TreeNode targetNode) {
    final dragLeft = details.offset.dx;
    final dragTop = details.offset.dy;

    // 计算目标节点的位置信息
    final targetLevel = _getNodeLevel(targetNode, widget.controller.tree);
    final targetLeft = widget.padding.left + (targetLevel * widget.indentWidth);
    final textWidth = targetNode.label.length * 10.0 + 20.0 + 16.0;
    final targetRight = targetLeft + textWidth;

    // 判断逻辑：首先检查水平位置
    if (dragLeft > targetRight) {
      return DragPosition.child;
    } else {
      // 其他情况根据垂直位置判断兄弟节点位置
      final targetCenter = widget.nodeHeight / 2;
      if (dragTop < targetCenter) {
        return DragPosition.siblingAbove;
      } else {
        return DragPosition.siblingBelow;
      }
    }
  }

  int _getNodeLevel(TreeNode targetNode, List<TreeNode> tree, [int level = 0]) {
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

  bool _isDescendant(TreeNode parent, TreeNode child) {
    if (parent == child) return true;
    for (final node in parent.children) {
      if (_isDescendant(node, child)) return true;
    }
    return false;
  }
}
