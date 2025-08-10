import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:imath/models/question.dart';
import 'package:imath/pages/common/category_panel.dart';

import 'package:imath/components/math_cell.dart';

import 'package:imath/state/questions_provider.dart';
import 'package:imath/utils/device_util.dart';

import '../../models/quiz.dart';

class QuestionListview extends ConsumerStatefulWidget {
  // int? categoryId = ALL_CATEGORY;
  QuestionListview({super.key});

  @override
  ConsumerState<QuestionListview> createState() => _QuestionListviewState();
}

class _QuestionListviewState extends ConsumerState<QuestionListview> {
  // List<Question> _questions = <Question>[];

  late PageController _pageController; // 新增：用于监听 PageView 滑动事件

  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    // 监听 PageView 滑动事件
    _pageController.addListener(() async {
      // 只有当滑动到最后一个页面时才加载更多
      if (_pageController.page != null &&
          _pageController.position.pixels ==
              _pageController.position.maxScrollExtent) {
        // 滑动到最底部，加载更多题目
        int newPageNo = ref.read(pageNoProvider) + 1;
        ref.read(questionsProvider.notifier).onChangePageNo(newPageNo);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(QuestionListview oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget _buildQuestionCard(Question question, int index) {
    if (question.title == null) {
      return const Card(
        child: ListTile(
          title: Text('无效的题目数据'),
        ),
      );
    }

    List<String> imageUrls = _parseImageUrls(question.images);

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          // 主要内容
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 题目标题区域
                // Text(
                //   '第${index + 1}题 ${question.title}',
                //   style: const TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.bold,
                //       ),
                // ),
                const SizedBox(height: 8),
                // 主要内容区域 - 使用Expanded确保不会超出屏幕
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 根据屏幕宽度决定布局方式
                      if (DeviceUtil.isMobile) {
                        // 小屏幕：使用Tab布局
                        return _buildMobileTabLayout(question, imageUrls);
                      } else {
                        // 大屏幕：水平布局
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 左侧：题目内容
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MathCell(
                                    content: question.content ?? '',
                                  ),
                                  const SizedBox(height: 4),
                                  MathCell(
                                    content: question.options ?? '',
                                  ),
                                ],
                              ),
                            ),
                            // 右侧：图片显示
                            if (imageUrls.isNotEmpty) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: _buildQuestionImages(imageUrls),
                              ),
                            ],
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // 操作面板 - 放置在右下方
          Positioned(
            right: 16,
            bottom: 100, // 距离屏幕底部100像素
            child: _buildPanel(question),
          ),
        ],
      ),
    );
  }

  // 新增：小屏幕Tab布局方法
  Widget _buildMobileTabLayout(Question question, List<String> imageUrls) {
    return DefaultTabController(
      length: imageUrls.isNotEmpty ? 2 : 1,
      child: Column(
        children: [
          // Tab栏
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                const Tab(text: '题目'),
                if (imageUrls.isNotEmpty) const Tab(text: '图片'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tab内容
          Expanded(
            child: TabBarView(
              children: [
                // 第一个Tab：题目内容
                _buildQuestionContent(question),
                // 第二个Tab：图片内容（仅在有图片时显示）
                if (imageUrls.isNotEmpty) _buildQuestionImages(imageUrls),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 新增：题目内容组件
  Widget _buildQuestionContent(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MathCell(
          content: question.content ?? '',
        ),
        const SizedBox(height: 4),
        MathCell(
          content: question.options ?? '',
        ),
      ],
    );
  }

  // 新增：右侧操作面板
  Widget _buildPanel(Question question) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 点赞
          _buildActionItem(
            icon: Icons.thumb_up_outlined,
            count: 0, // TODO: 从数据库获取点赞数
            onTap: () {
              // TODO: 实现点赞功能
            },
          ),
          const SizedBox(height: 8),
          // 收藏
          _buildActionItem(
            icon: Icons.bookmark_outline,
            count: 0, // TODO: 从数据库获取收藏数
            onTap: () {
              // TODO: 实现收藏功能
            },
          ),
          const SizedBox(height: 8),
          // 评论
          _buildActionItem(
            icon: Icons.comment_outlined,
            count: 0, // TODO: 从数据库获取评论数
            onTap: () {
              // TODO: 实现评论功能
            },
          ),
          const SizedBox(height: 8),
          // 答案
          _buildActionItem(
            icon: Icons.lightbulb_outline,
            count: 0, // 答案不显示数量
            onTap: () {
              context.push('/admin/viewAnswer', extra: question);
            },
            isAnswer: true,
          ),
        ],
      ),
    );
  }

  // 构建操作项
  Widget _buildActionItem({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    bool isAnswer = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isAnswer ? Colors.orange : Colors.grey[600],
          ),
          if (!isAnswer) ...[
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionsPageView(List<Question> questions) {
    return PageView.builder(
      controller: _pageController, // 使用自定义的 PageController
      physics: const ClampingScrollPhysics(), // 使用标准滚动物理特性
      scrollDirection: Axis.vertical,
      itemCount: questions?.length,
      onPageChanged: (int page) {
        // 当滑动到倒数第二个页面时，开始加载更多数据
      },
      itemBuilder: (context, index) {
        return _buildQuestionCard(questions[index], index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(questionsProvider).value ?? [];
    // 监听分类变化和加载状态
    ref.watch(categoryChangeProvider);
    ref.watch(pageChangeProvider);
    ref.watch(autoQuestionsFutureProvider); // 自动触发初始加载
    final isLoading = ref.watch(isLoadingProvider);
    final hasMore = ref.watch(hasMoreProvider);
    // final questions = ref.watch(questionsProvider);
    // 更新本地状态
    _isLoading = isLoading;
    _hasMore = hasMore;

    return RefreshIndicator(
      // onRefresh: ref.refresh(questionsProvider.future),
      onRefresh: _onRefresh,
      child: Stack(
        children: [
          _buildQuestionsPageView(questions),
          // 显示加载指示器
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          // 显示无数据提示
          if (questions.isEmpty)
            const Center(
              child: Text('暂无数据'),
            ),
        ],
      ),
    );
  }

  /**
   * 下拉刷新方法,为list重新赋值
   */
  Future<Null> _onRefresh() async {
    // 重置页码为1
    ref.read(pageNoProvider.notifier).state = 1;
    // 重置是否有更多数据
    ref.read(hasMoreProvider.notifier).state = true;
    // 触发重新加载

    // 等待加载完成
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // 解析图片URL字符串，返回URL列表
  List<String> _parseImageUrls(String? imagesString) {
    if (imagesString == null || imagesString.trim().isEmpty) {
      return [];
    }

    // 按逗号分割，并去除空白字符
    return imagesString
        .split(',')
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
  }

  // 构建题目图片显示组件
  Widget _buildQuestionImages(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        if (imageUrls.length == 1)
          SizedBox(
            height: 140,
            child: _buildImageItem(imageUrls.first),
          )
        else
          // 多张图片时使用垂直列表布局，确保每张图片都能完整显示
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: imageUrls.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 120, // 固定高度确保图片不会被裁剪
                  child: _buildImageItem(imageUrls[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  // 构建单个图片项
  Widget _buildImageItem(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () => _showImageDialog(imageUrl),
          child: Stack(
            children: [
              // 使用 Center 包装确保图片居中显示
              Center(
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain, // 保持宽高比，确保图片完整显示
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 添加点击提示
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示图片放大对话框
  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // 背景遮罩
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              // 图片内容
              Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 300,
                          height: 300,
                          color: Colors.white,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 300,
                          height: 300,
                          color: Colors.white,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 60,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '图片加载失败',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // 关闭按钮
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
