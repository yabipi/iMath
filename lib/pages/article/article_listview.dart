import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart'; // 新增导入
import 'package:go_router/go_router.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/http/article.dart';
import 'package:imath/pages/culture/news_tile.dart';

class ArticleListView extends StatefulWidget {
  ArticleListView({Key? key, ArticleType articleType = ArticleType.normal}) : super(key: key);

  ArticleType? articleType;

  @override
  _ArticleListViewState createState() => _ArticleListViewState();
}

class _ArticleListViewState extends State<ArticleListView> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false); // 新增：刷新控制器
  final List _articles = []; // 新增：存储文章列表
  int _pageNo = 1; // 新增：当前页码
  bool _hasMore = true; // 新增：是否还有更多数据
  bool _isLoading = false; // 新增：是否正在加载

  // 定义20个数学相关的图标和对应的渐变色
  final List<Map<String, dynamic>> _mathIconSet = [
    {
      'icon': Icons.calculate,
      'colors': [Colors.blue.shade300, Colors.blue.shade500],
    },
    {
      'icon': Icons.functions,
      'colors': [Colors.purple.shade300, Colors.purple.shade500],
    },
    {
      'icon': Icons.timeline,
      'colors': [Colors.green.shade300, Colors.green.shade500],
    },
    {
      'icon': Icons.analytics,
      'colors': [Colors.orange.shade300, Colors.orange.shade500],
    },
    {
      'icon': Icons.pie_chart,
      'colors': [Colors.red.shade300, Colors.red.shade500],
    },
    {
      'icon': Icons.trending_up,
      'colors': [Colors.teal.shade300, Colors.teal.shade500],
    },
    {
      'icon': Icons.data_usage,
      'colors': [Colors.indigo.shade300, Colors.indigo.shade500],
    },
    {
      'icon': Icons.science,
      'colors': [Colors.cyan.shade300, Colors.cyan.shade500],
    },
    {
      'icon': Icons.school,
      'colors': [Colors.pink.shade300, Colors.pink.shade500],
    },
    {
      'icon': Icons.psychology,
      'colors': [Colors.amber.shade300, Colors.amber.shade500],
    },
    {
      'icon': Icons.account_balance,
      'colors': [Colors.lime.shade300, Colors.lime.shade500],
    },
    {
      'icon': Icons.architecture,
      'colors': [Colors.brown.shade300, Colors.brown.shade500],
    },
    {
      'icon': Icons.auto_graph,
      'colors': [Colors.deepPurple.shade300, Colors.deepPurple.shade500],
    },
    {
      'icon': Icons.bar_chart,
      'colors': [Colors.deepOrange.shade300, Colors.deepOrange.shade500],
    },
    {
      'icon': Icons.candlestick_chart,
      'colors': [Colors.lightBlue.shade300, Colors.lightBlue.shade500],
    },
    {
      'icon': Icons.currency_exchange,
      'colors': [Colors.lightGreen.shade300, Colors.lightGreen.shade500],
    },
    {
      'icon': Icons.engineering,
      'colors': [Colors.teal.shade400, Colors.teal.shade600],
    },
    {
      'icon': Icons.fact_check,
      'colors': [Colors.blueGrey.shade300, Colors.blueGrey.shade500],
    },
    {
      'icon': Icons.graphic_eq,
      'colors': [Colors.yellow.shade300, Colors.yellow.shade500],
    },
    {
      'icon': Icons.insights,
      'colors': [Colors.grey.shade300, Colors.grey.shade500],
    },
  ];

  // 新增：模拟从网络获取数据
  Future<void> _fetchArticles(int pageNo) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ArticleHttp.loadArticles(articleType: widget.articleType??ArticleType.normal, pageNo: pageNo); // 假设接口支持 pageNo 参数
      final newArticles = response['data'];

      setState(() {
        if (pageNo == 1) {
          _articles.clear();
        }
        _articles.addAll(newArticles);
        _hasMore = newArticles.length == 10; // 假设每页返回10条数据表示还有更多
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    }
  }

  // 新增：下拉刷新
  void _onRefresh() async {
    _pageNo = 1;
    _hasMore = true;
    await _fetchArticles(_pageNo);
    _refreshController.refreshCompleted();
  }

  // 新增：上拉加载更多
  void _onLoading() async {
    if (!_hasMore) {
      _refreshController.loadNoData();
      return;
    }

    _pageNo++;
    await _fetchArticles(_pageNo);
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    _fetchArticles(_pageNo); // 初始化加载第一页数据
  }

  @override
  void dispose() {
    _refreshController.dispose(); // 新增：释放控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _articles.isEmpty && !_isLoading
        ? _buildEmptyState() // 新增：空状态组件
        : SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: _hasMore,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            footer: CustomFooter(
              builder: (context, mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = Text("上拉加载更多");
                } else if (mode == LoadStatus.loading) {
                  body = CircularProgressIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = Text("加载失败，点击重试");
                } else if (mode == LoadStatus.canLoading) {
                  body = Text("松手加载更多");
                } else {
                  body = Text("没有更多数据了");
                }
                return Container(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final item = _articles[index];
                return GestureDetector(
                  onTap: () {
                    context.go("/culture/article", extra: item);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                      children: [
                        // 数学相关图标
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _getIconForArticle(item['id'])['colors'],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _getIconForArticle(item['id'])['colors'][0].withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getIconForArticle(item['id'])['icon'],
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 文章内容
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? '无标题',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item['desc'] != null && item['desc'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  item['desc'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // 编辑按钮
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            context.go("/admin/editArticle/${item['id']}");
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                );
              },
            ),
          );
  }

  // 根据文章ID获取对应的图标和颜色
  Map<String, dynamic> _getIconForArticle(int? articleId) {
    if (articleId == null) {
      return _mathIconSet[0]; // 默认返回第一个图标
    }
    
    // 使用文章ID的哈希值来选择图标，确保同一篇文章总是显示相同的图标
    final index = articleId.abs() % _mathIconSet.length;
    return _mathIconSet[index];
  }

  // 新增：空状态组件
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            '暂无文章数据',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '下拉刷新试试',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}