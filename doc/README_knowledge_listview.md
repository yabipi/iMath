# 知识列表组件 (KnowledgeListView)

这是一个基于 `ExtensibleRefreshList` 的知识列表组件，支持按 `level`、`branch` 和 `pageNo` 进行刷新。

## 🎯 主要特性

- ✅ **多条件刷新**: 支持 branch、pageNo 等多种刷新条件
- ✅ **数学级别状态**: 集成 mathLevelProvider 状态管理
- ✅ **自动刷新**: 当数学级别变化时自动刷新列表
- ✅ **分类筛选**: 集成 CategoryPanel 进行分类筛选
- ✅ **搜索功能**: 支持搜索框输入（待实现具体逻辑）
- ✅ **无限滚动**: 支持无限下拉加载更多
- ✅ **下拉刷新**: 支持下拉刷新功能
- ✅ **条件显示**: 实时显示当前筛选条件和数学级别
- ✅ **错误处理**: 完善的错误处理和重试机制
- ✅ **美观UI**: 保持与原有 knowledge_screen 一致的界面布局

## 📁 文件结构

```
lib/pages/knowledge/
├── knowledge_listview.dart              # 新的知识列表组件
├── knowledge_screen.dart                # 原有的知识页面（保持不变）
└── README_knowledge_listview.md         # 使用说明
```

## 🚀 使用方法

### 1. 基本使用

```dart
import 'package:imath/pages/knowledge/knowledge_listview.dart';

// 在路由中使用
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => KnowledgeListView(),
  ),
);
```

### 2. 刷新条件管理

组件支持以下刷新条件：

- **level**: 知识级别
- **branch**: 知识分支
- **pageNo**: 页码
- **articleType**: 文章类型

### 3. 条件更新

```dart
// 更新数学级别（会自动刷新列表）
ref.read(mathLevelProvider.notifier).state = MATH_LEVEL.Advanced;

// 更新分支
ref.read(knowledgeRefreshConditionsProvider.notifier).updateBranch('代数');

// 更新文章类型
ref.read(knowledgeRefreshConditionsProvider.notifier).updateArticleType(ArticleType.normal);

// 更新分类（会自动映射到 branch）
ref.read(knowledgeRefreshConditionsProvider.notifier).updateCategory(categoryId);
```

## 🔧 组件结构

### KnowledgeRefreshConditions
刷新条件类，包含：
- `page`: 页码
- `branch`: 知识分支
- `articleType`: 文章类型

**注意**: 数学级别 (`level`) 现在通过 `mathLevelProvider` 状态管理，不在刷新条件中。

### KnowledgeListState
列表状态类，包含：
- `items`: 文章列表
- `isLoading`: 加载状态
- `hasMore`: 是否有更多数据
- `error`: 错误信息
- `totalCount`: 总数

### KnowledgeRefreshConditionsNotifier
条件管理器，提供：
- `updateBranch()`: 更新分支
- `updateArticleType()`: 更新文章类型
- `updateCategory()`: 更新分类
- `resetConditions()`: 重置所有条件

**注意**: 数学级别通过 `mathLevelProvider` 管理，不在条件管理器中。

### KnowledgeListNotifier
数据管理器，负责：
- 调用 API 获取数据
- 处理分页逻辑
- 错误处理
- **监听 mathLevelProvider 变化并自动刷新**

## 🎨 界面特性

### 1. 搜索框
- 位于 AppBar 中
- 支持实时搜索（待实现具体逻辑）

### 2. 数学级别显示
- 显示当前选择的数学级别
- 提供切换级别的按钮
- 级别变化时自动刷新列表

### 3. 分类面板
- 使用 CategoryPanel 组件
- 支持分类筛选
- 点击分类会自动更新刷新条件

### 4. 条件显示
- 实时显示当前筛选条件
- 支持一键清除所有条件

### 5. 文章卡片
- 保持与原有界面一致的样式
- 显示级别和分支标签
- 包含点赞、阅览、收藏统计
- 支持点击跳转到文章详情

## 🔄 数据流程

1. **初始化**: 组件初始化时自动加载第一页数据
2. **数学级别变化**: 当 mathLevelProvider 状态变化时，自动刷新列表
3. **条件变化**: 当 branch 等条件变化时，自动重置页码并重新加载
4. **分页加载**: 滚动到底部时自动加载下一页
5. **下拉刷新**: 下拉时重新加载第一页数据
6. **错误处理**: 加载失败时显示错误信息和重试按钮

## 🚨 错误处理

组件内置了完善的错误处理机制：

- **网络错误**: 显示错误信息和重试按钮
- **空数据**: 显示友好的空状态提示
- **加载状态**: 显示加载指示器

## 📱 响应式设计

组件支持响应式设计：
- 适配不同屏幕尺寸
- 保持良好的用户体验

## 🔧 自定义配置

### 修改分页大小

```dart
@override
int getPageSize() => 20; // 修改为每页20条
```

### 自定义错误处理

```dart
errorView: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, size: 64, color: Colors.red),
      const SizedBox(height: 16),
      Text('自定义错误信息: ${state.error}'),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () => ref.read(knowledgeListProvider.notifier).refresh(),
        child: const Text('重试'),
      ),
    ],
  ),
),
```

### 自定义空状态

```dart
emptyView: const Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.article_outlined, size: 64, color: Colors.grey),
      SizedBox(height: 16),
      Text('暂无知识内容', style: TextStyle(color: Colors.grey)),
    ],
  ),
),
```

## 🔄 与原有组件的兼容性

- **保持原有功能**: 原有的 `knowledge_screen.dart` 保持不变
- **并行使用**: 新旧组件可以并行使用
- **逐步迁移**: 可以逐步将功能迁移到新组件

## 🎯 总结

这个新的知识列表组件提供了：

- **强大的扩展性**: 支持多种刷新条件
- **类型安全**: 完整的泛型支持
- **状态管理**: 基于Riverpod的响应式状态管理
- **用户体验**: 完善的加载、错误、空状态处理
- **界面一致性**: 保持与原有界面的视觉一致性
- **开发效率**: 简化的API和可复用的组件

通过使用这个组件，你可以快速构建功能丰富的知识列表页面，同时保持代码的可维护性和扩展性。 