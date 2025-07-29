# 可拖拽树组件 (DraggableTree)

这是一个可重用的Flutter树组件，支持拖拽操作和JSON数据管理。

## 功能特性

- ✅ 支持拖拽操作（子节点、兄弟节点）
- ✅ JSON数据输入/输出
- ✅ 节点展开/折叠
- ✅ 节点选择
- ✅ 自定义节点外观
- ✅ 控制器模式管理数据
- ✅ 防止循环引用

## 文件结构

```
lib/widgets/
├── draggable_tree_controller.dart  # 树控制器
├── draggable_tree.dart             # 可拖拽树组件
└── README_draggable_tree.md        # 使用说明
```

## 快速开始

### 1. 基本使用

```dart
import 'package:flutter/material.dart';
import 'widgets/draggable_tree.dart';
import 'widgets/draggable_tree_controller.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late DraggableTreeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DraggableTreeController();
    
    // 设置回调函数
    _controller.onTreeChanged = () {
      setState(() {});
    };

    // 加载数据
    _loadData();
  }

  void _loadData() {
    // 从JSON字符串加载
    const jsonString = '''
    [
      {
        "id": "1",
        "label": "根节点",
        "isExpanded": true,
        "children": [
          {"id": "1-1", "label": "子节点1", "isExpanded": false, "children": []},
          {"id": "1-2", "label": "子节点2", "isExpanded": false, "children": []}
        ]
      }
    ]
    ''';
    _controller.loadFromJson(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('我的树')),
      body: DraggableTree(
        controller: _controller,
      ),
    );
  }
}
```

### 2. 获取JSON数据

```dart
// 获取JSON字符串
String jsonData = _controller.getTreeData();

// 获取JSON对象列表
List<Map<String, dynamic>> jsonList = _controller.getTreeJsonList();
```

### 3. 操作节点

```dart
// 添加节点
_controller.addNode('新节点');

// 删除节点
if (_controller.selectedNode != null) {
  _controller.removeNode(_controller.selectedNode!);
}

// 展开/折叠节点
_controller.toggleNode(node);

// 展开所有节点
_controller.expandAll();

// 折叠所有节点
_controller.collapseAll();
```

## 组件属性

### DraggableTree 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| controller | DraggableTreeController | 必需 | 树控制器 |
| nodeHeight | double | 48.0 | 节点高度 |
| indentWidth | double | 20.0 | 缩进宽度 |
| padding | EdgeInsets | EdgeInsets.all(16.0) | 内边距 |
| showDragIndicator | bool | true | 是否显示拖拽指示器 |
| showSelection | bool | true | 是否显示选择状态 |
| selectedColor | Color? | Colors.purple[100] | 选中节点颜色 |
| dragIndicatorColor | Color? | Colors.blue | 拖拽指示器颜色 |
| nodeBuilder | Widget Function(TreeNode, int)? | null | 自定义节点构建器 |
| dragFeedbackBuilder | Widget Function(TreeNode)? | null | 自定义拖拽反馈构建器 |

### 自定义节点外观

```dart
DraggableTree(
  controller: _controller,
  nodeBuilder: (node, level) {
    return Container(
      height: 50,
      padding: EdgeInsets.only(left: level * 20),
      child: Row(
        children: [
          Icon(Icons.folder, color: Colors.blue),
          SizedBox(width: 8),
          Text(node.label, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  },
)
```

## 拖拽操作

### 拖拽位置类型

- **child**: 作为子节点（拖拽到节点右侧）
- **siblingAbove**: 作为上方兄弟节点（拖拽到节点上方）
- **siblingBelow**: 作为下方兄弟节点（拖拽到节点下方）

### 拖拽操作说明

1. **长按节点** 开始拖拽
2. **拖拽到节点右侧** 成为子节点（绿色边框）
3. **拖拽到节点上方** 成为上方兄弟节点（蓝色横线）
4. **拖拽到节点下方** 成为下方兄弟节点（蓝色横线）

## 控制器方法

### 数据管理

```dart
// 从JSON字符串加载
controller.loadFromJson(jsonString);

// 从JSON对象列表加载
controller.loadFromJsonList(jsonList);

// 获取JSON字符串
String jsonData = controller.getTreeData();

// 获取JSON对象列表
List<Map<String, dynamic>> jsonList = controller.getTreeJsonList();
```

### 节点操作

```dart
// 添加节点
controller.addNode(label, parent: parentNode);

// 删除节点
controller.removeNode(node);

// 切换节点展开状态
controller.toggleNode(node);

// 展开所有节点
controller.expandAll();

// 折叠所有节点
controller.collapseAll();
```

### 状态管理

```dart
// 设置选中节点
controller.selectNode(node);

// 开始拖拽
controller.startDrag(node);

// 结束拖拽
controller.endDrag();
```

## 回调函数

```dart
// 树数据变化回调
controller.onTreeChanged = () {
  setState(() {});
};

// 节点选择回调
controller.onNodeSelected = (node) {
  print('选中节点: ${node?.label}');
};

// 拖拽开始回调
controller.onDragStarted = (node) {
  print('开始拖拽: ${node.label}');
};

// 拖拽结束回调
controller.onDragEnded = () {
  print('拖拽结束');
};
```

## JSON数据格式

```json
[
  {
    "id": "1",
    "label": "根节点",
    "isExpanded": true,
    "children": [
      {
        "id": "1-1",
        "label": "子节点1",
        "isExpanded": false,
        "children": []
      },
      {
        "id": "1-2",
        "label": "子节点2",
        "isExpanded": false,
        "children": []
      }
    ]
  }
]
```

## 示例

查看以下示例文件了解详细用法：

- `lib/pages/demo/simple_tree_example.dart` - 简单使用示例
- `lib/pages/demo/draggable_tree_demo.dart` - 完整功能演示

## 注意事项

1. 确保在 `initState` 中初始化控制器
2. 设置 `onTreeChanged` 回调以更新UI
3. 拖拽操作会自动防止循环引用
4. 节点ID应该是唯一的
5. 控制器会在拖拽操作后自动通知UI更新

## 常见问题

### Hero Tag 错误

如果在使用多个 `FloatingActionButton` 时遇到 "There are multiple heroes that share the same tag within a subtree" 错误，请为每个按钮添加唯一的 `heroTag`：

```dart
floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    FloatingActionButton(
      heroTag: 'add_node',  // 添加唯一的 heroTag
      onPressed: () => controller.addNode('新节点'),
      child: const Icon(Icons.add),
    ),
    const SizedBox(height: 16),
    FloatingActionButton(
      heroTag: 'expand_all',  // 添加唯一的 heroTag
      onPressed: () => controller.expandAll(),
      child: const Icon(Icons.expand_more),
    ),
  ],
),
```

这样可以避免 Flutter 的 Hero 动画冲突。 