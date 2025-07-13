import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/pages/common/bottom_navigation_bar.dart';

class NewsDetailPage extends StatefulWidget {
  final String? newsId; // 新闻ID，用于获取具体新闻内容

  const NewsDetailPage({Key? key, this.newsId}) : super(key: key);

  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  bool _isLoading = true;
  NewsDetail? _newsDetail;

  @override
  void initState() {
    super.initState();
    _loadNewsDetail();
  }

  // 模拟加载新闻详情
  Future<void> _loadNewsDetail() async {
    setState(() {
      _isLoading = true;
    });

    // 模拟网络请求延迟
    await Future.delayed(Duration(milliseconds: 1000));

    // 模拟新闻详情数据
    final mockNewsDetail = NewsDetail(
      id: widget.newsId ?? '1',
      title: '数学史上的重大突破：费马大定理的证明',
      author: '数学研究编辑部',
      publishTime: '2024-01-15 14:30:00',
      readCount: 12580,
      content: '''
        <h2>引言</h2>
        <p>费马大定理（Fermat's Last Theorem）是数学史上最著名的未解之谜之一，由法国数学家皮埃尔·德·费马在17世纪提出。这个定理声称：对于任何大于2的整数n，方程 x<sup>n</sup> + y<sup>n</sup> = z<sup>n</sup> 没有正整数解。</p>
        
        <h3>历史背景</h3>
        <p>1637年，费马在阅读古希腊数学家丢番图的《算术》时，在页边空白处写下了这个著名的猜想，并声称他有一个"绝妙的证明"，但页边空白太小，无法写下。这个看似简单的陈述，却困扰了数学家们长达358年。</p>
        
        <h3>证明历程</h3>
        <p>在接下来的几个世纪里，无数数学家试图证明这个定理：</p>
        <ul>
          <li><strong>欧拉（1770年）</strong>：证明了n=3的情况</li>
          <li><strong>索菲·热尔曼（19世纪）</strong>：为证明做出了重要贡献</li>
          <li><strong>库默尔（1847年）</strong>：引入了理想数理论</li>
          <li><strong>谷山丰（1955年）</strong>：提出了谷山-志村猜想</li>
        </ul>
        
        <h3>安德鲁·怀尔斯的突破</h3>
        <p>1994年，英国数学家安德鲁·怀尔斯（Andrew Wiles）在经过7年的秘密研究后，终于完成了费马大定理的证明。他的证明长达129页，使用了现代数学中最先进的技术，包括：</p>
        <ul>
          <li>椭圆曲线理论</li>
          <li>模形式理论</li>
          <li>伽罗瓦表示</li>
          <li>德利涅-韦伊猜想</li>
        </ul>
        
        <h3>数学意义</h3>
        <p>费马大定理的证明不仅是数学史上的重大成就，更重要的是，在证明过程中发展出的数学工具和方法，推动了整个数学领域的发展。特别是：</p>
        <ol>
          <li><em>椭圆曲线理论</em>得到了空前的发展</li>
          <li><em>模形式理论</em>在数论中的应用更加广泛</li>
          <li><em>代数几何</em>与数论的联系更加紧密</li>
        </ol>
        
        <h3>影响与启示</h3>
        <p>费马大定理的证明告诉我们：</p>
        <blockquote>
          "数学问题往往比表面看起来要复杂得多，解决它们需要坚持不懈的努力和创新思维。"
        </blockquote>
        
        <p>这个定理的证明过程也体现了数学研究的特点：</p>
        <ul>
          <li>需要深厚的理论基础</li>
          <li>需要创新的思维方式</li>
          <li>需要长期坚持不懈的努力</li>
          <li>需要跨学科的知识融合</li>
        </ul>
        
        <h3>结论</h3>
        <p>费马大定理的证明是20世纪数学最重要的成就之一，它不仅解决了一个困扰数学家358年的难题，更重要的是推动了整个数学领域的发展。这个证明过程展示了数学研究的魅力和挑战，激励着新一代的数学家继续探索数学的奥秘。</p>
        
        <p>正如怀尔斯所说：<q>"数学研究就像攀登一座高山，虽然过程艰难，但当你到达山顶时，看到的风景是无比美丽的。"</q></p>
        
        <hr>
        <p><small>本文由数学研究编辑部整理，转载请注明出处。</small></p>
      ''',
      tags: ['数学史', '费马大定理', '数论', '安德鲁·怀尔斯'],
      relatedNews: [
        RelatedNews(
          id: '2',
          title: '黎曼猜想：数学王冠上的明珠',
          summary: '探索黎曼猜想的历史和现代研究进展...',
          imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=200&h=120&fit=crop',
        ),
        RelatedNews(
          id: '3',
          title: '哥德巴赫猜想研究新进展',
          summary: '中国数学家陈景润在哥德巴赫猜想方面的贡献...',
          imageUrl: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=200&h=120&fit=crop',
        ),
      ],
    );

    setState(() {
      _newsDetail = mockNewsDetail;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新闻详情'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('分享功能开发中...')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _newsDetail == null
              ? _buildErrorState()
              : _buildNewsContent(),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  // 加载状态
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '正在加载新闻内容...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600]!,
            ),
          ),
        ],
      ),
    );
  }

  // 错误状态
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600]!,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '请检查网络连接后重试',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500]!,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNewsDetail,
            child: Text('重新加载'),
          ),
        ],
      ),
    );
  }

  // 新闻内容
  Widget _buildNewsContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 新闻标题
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Text(
              _newsDetail!.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 新闻元信息
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]!),
                SizedBox(width: 4),
                Text(
                  _newsDetail!.author,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600]!,
                  ),
                ),
                SizedBox(width: 20),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]!),
                SizedBox(width: 4),
                Text(
                  _newsDetail!.publishTime,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600]!,
                  ),
                ),
                Spacer(),
                Icon(Icons.visibility, size: 16, color: Colors.grey[600]!),
                SizedBox(width: 4),
                Text(
                  '${_newsDetail!.readCount}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600]!,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // 标签
          if (_newsDetail!.tags.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _newsDetail!.tags.map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700]!,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          
          SizedBox(height: 20),
          
          // 分割线
          Divider(height: 1, thickness: 1, color: Colors.grey[300]!),
          
          // 新闻内容
          Container(
            padding: EdgeInsets.all(20),
            child: Html(
              data: _newsDetail!.content,
              style: {
                "body": Style(
                  fontSize: FontSize(16),
                  lineHeight: LineHeight(1.8),
                  color: Colors.black87,
                ),
                "h2": Style(
                  fontSize: FontSize(20),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  margin: Margins.only(top: 24, bottom: 12),
                ),
                "h3": Style(
                  fontSize: FontSize(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  margin: Margins.only(top: 20, bottom: 10),
                ),
                "p": Style(
                  fontSize: FontSize(16),
                  lineHeight: LineHeight(1.8),
                  color: Colors.black87,
                  margin: Margins.only(bottom: 12),
                ),
                "ul": Style(
                  margin: Margins.only(bottom: 12, left: 20),
                ),
                "ol": Style(
                  margin: Margins.only(bottom: 12, left: 20),
                ),
                "li": Style(
                  fontSize: FontSize(16),
                  lineHeight: LineHeight(1.8),
                  color: Colors.black87,
                  margin: Margins.only(bottom: 4),
                ),
                "blockquote": Style(
                  fontSize: FontSize(16),
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700]!,
                  backgroundColor: Colors.grey[100]!,
                  padding: HtmlPaddings.all(16),
                  margin: Margins.only(top: 12, bottom: 12),
                  border: Border(
                    left: BorderSide(color: Colors.blue, width: 4),
                  ),
                ),
                "q": Style(
                  fontSize: FontSize(16),
                  fontStyle: FontStyle.italic,
                  color: Colors.blue[700]!,
                ),
                "strong": Style(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                "em": Style(
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                "small": Style(
                  fontSize: FontSize(14),
                  color: Colors.grey[600]!,
                ),
                "hr": Style(
                  margin: Margins.only(top: 20, bottom: 20),
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
              },
            ),
          ),
          
          // 相关新闻
          if (_newsDetail!.relatedNews.isNotEmpty) ...[
            Divider(height: 1, thickness: 1, color: Colors.grey[300]!),
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '相关新闻',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  ..._newsDetail!.relatedNews.map((news) => _buildRelatedNewsItem(news)),
                ],
              ),
            ),
          ],
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // 相关新闻项
  Widget _buildRelatedNewsItem(RelatedNews news) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // 导航到相关新闻详情页
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('跳转到：${news.title}')),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                // 新闻图片
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      news.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300]!,
                          child: Icon(
                            Icons.article,
                            size: 30,
                            color: Colors.grey[600]!,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // 新闻信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        news.summary,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600]!,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400]!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 新闻详情数据模型
class NewsDetail {
  final String id;
  final String title;
  final String author;
  final String publishTime;
  final int readCount;
  final String content;
  final List<String> tags;
  final List<RelatedNews> relatedNews;

  NewsDetail({
    required this.id,
    required this.title,
    required this.author,
    required this.publishTime,
    required this.readCount,
    required this.content,
    required this.tags,
    required this.relatedNews,
  });
}

// 相关新闻数据模型
class RelatedNews {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;

  RelatedNews({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
  });
}
