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
                return Stack(
                  children: [
                    NewsTile(
                      title: item['title'],
                      onTap: () {
                        context.go("/culture/article", extra: item);
                      },
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          context.go("/admin/editArticle/${item['id']}");
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          );
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