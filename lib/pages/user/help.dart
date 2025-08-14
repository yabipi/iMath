import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '帮助中心',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: FutureBuilder<String>(
          future: _loadHelpContent(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '正在加载帮助内容...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '加载失败',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[300],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '无法加载帮助内容',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // 刷新页面
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HelpPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('重试'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final helpContent = snapshot.data ?? _getDefaultHelpContent();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部装饰
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.8),
                          Theme.of(context).primaryColor.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '数学宝典帮助中心',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '在这里找到您需要的所有帮助信息',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Markdown内容
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: GptMarkdown(
                      helpContent,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 底部联系信息
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.contact_support,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '需要更多帮助？',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '如果您还有其他问题，请随时联系我们',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildContactItem(
                              context,
                              icon: Icons.email,
                              label: '邮箱',
                              onTap: () {
                                // TODO: 实现邮件联系功能
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('邮件功能开发中...'),
                                  ),
                                );
                              },
                            ),
                            _buildContactItem(
                              context,
                              icon: Icons.chat,
                              label: '在线客服',
                              onTap: () {
                                // TODO: 实现在线客服功能
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('在线客服功能开发中...'),
                                  ),
                                );
                              },
                            ),
                            _buildContactItem(
                              context,
                              icon: Icons.feedback,
                              label: '意见反馈',
                              onTap: () {
                                // TODO: 实现意见反馈功能
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('意见反馈功能开发中...'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 加载帮助内容
  Future<String> _loadHelpContent() async {
    try {
      return await rootBundle.loadString('assets/help.md');
    } catch (e) {
      // 如果加载失败，返回默认内容
      return _getDefaultHelpContent();
    }
  }

  // 默认帮助内容
  String _getDefaultHelpContent() {
    return '''# 数学宝典帮助中心

## 关于数学宝典

数学宝典是一款专为数学学习设计的智能应用，旨在帮助用户更好地理解和掌握数学知识。

### 主要特色

- **智能题目推荐**：根据学习进度智能推荐适合的题目
- **详细解析**：每道题目都配有详细的解题思路和步骤
- **个性化学习**：根据个人能力调整题目难度
- **进度跟踪**：实时记录学习进度和薄弱环节

## 功能介绍

### 1. 题目浏览
- 支持多种题型：选择题、填空题、解答题等
- 按难度分类：基础、进阶、高级
- 按知识点分类：代数、几何、微积分等

### 2. 智能练习
- 自适应难度调整
- 错题自动收集
- 薄弱环节重点练习

### 3. 学习统计
- 做题数量统计
- 正确率分析
- 学习时长记录
- 知识点掌握程度

### 4. 收藏与笔记
- 收藏重要题目
- 添加个人笔记
- 建立知识体系

## 使用指南

### 开始使用
1. 选择您感兴趣的数学领域
2. 从基础题目开始练习
3. 查看详细解析，理解解题思路
4. 记录学习笔记，巩固知识点

### 提高效率
- 定期复习错题集
- 关注薄弱知识点
- 合理分配学习时间
- 多角度思考问题

## 常见问题

**Q: 如何提高做题正确率？**
A: 建议仔细阅读题目，理解题意，多练习同类型题目，及时总结解题方法。

**Q: 遇到不会的题目怎么办？**
A: 可以查看详细解析，理解解题思路，或者标记为待复习，稍后再做。

**Q: 如何查看学习进度？**
A: 在个人中心可以查看详细的学习统计和进度分析。

## 技术支持

如果您在使用过程中遇到任何问题，请通过以下方式联系我们：

- **邮箱支持**：support@mathapp.com
- **在线客服**：工作日 9:00-18:00
- **意见反馈**：随时欢迎您的建议

---

*感谢您使用数学宝典，祝您学习愉快！*''';
  }

  // 构建联系项目
  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
