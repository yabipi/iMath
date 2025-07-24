import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:imath/models/question.dart';
import 'package:imath/pages/common/category_panel.dart';

import 'package:imath/components/math_cell.dart';

import 'package:imath/state/questions_provider.dart';

import '../../models/quiz.dart';


class QuestionListview extends ConsumerStatefulWidget {
  // int? categoryId = ALL_CATEGORY;
  QuestionListview({super.key});

  @override
  ConsumerState<QuestionListview> createState() => _QuestionListviewState();
}

class _QuestionListviewState extends ConsumerState<QuestionListview> {
  // List<Question> _questions = <Question>[];
  final Map<int, bool> _expandedStates = {};

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
          _pageController.position.pixels == _pageController.position.maxScrollExtent) {
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

    bool isExpanded = _expandedStates[index] ?? false;
    List<String> imageUrls = _parseImageUrls(question.images);

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 标题
                Text(
                  '第${index + 1}题',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.push('/admin/editQuestion?questionId=${question.id}');
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 主要内容区域 - 使用Expanded确保不会超出屏幕
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 根据屏幕宽度决定布局方式
                  if (constraints.maxWidth < 600) {
                    // 小屏幕：垂直布局
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 题目内容
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MathCell(
                                content: question.content ?? '',
                              ),
                              // Expanded(
                              //   child: ClipRect(
                              //     child: MathCell(
                              //       content: question.content ?? '',
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(height: 4),
                              MathCell(
                                content: question.content ?? '',
                              ),
                              // Expanded(
                              //   child: ClipRect(
                              //     child: MathCell(
                              //       content: question.options ?? '',
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        // 图片区域
                        if (imageUrls.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Expanded(
                            flex: 1,
                            child: _buildQuestionImages(imageUrls),
                          ),
                        ],
                      ],
                    );
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
                              // Expanded(
                              //   child: ClipRect(
                              //     child: MathCell(
                              //       content: question.content ?? '',
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(height: 4),
                              MathCell(
                                content: question.options ?? '',
                              ),
                              // Expanded(
                              //   child: ClipRect(
                              //     child: MathCell(
                              //       content: question.options ?? '',
                              //     ),
                              //   ),
                              // ),
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
            // 底部操作区域
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _expandedStates[index] = !isExpanded;
                    });
                  },
                  child: Text(isExpanded ? '收起解答' : '查看解答'),
                ),

              ],
            ),
            
            // 解答区域
            if (isExpanded) ...[
              const Divider(),
              const Text(
                '解析和答案:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ClipRect(
                  child: MathCell(title: '', content: question.answer ?? ''),
                ),
              ),
            ],
          ],
        ),
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
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.go('/admin/addQuestion');
          },
          child: const Icon(Icons.add),
        ),
        body: Stack(
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
      )
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
          // 多张图片时使用网格布局
          Expanded(
            child: GridView.builder(
              // shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1.0,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return _buildImageItem(imageUrls[index]);
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
              Image.network(
                imageUrl,
                // width: double.infinity,
                // height: double.infinity,
                fit: BoxFit.contain,
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