import 'package:flutter/material.dart';
import 'package:imath/pages/common/bottom_navigation_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BookListView extends StatefulWidget {
  @override
  _BookListViewState createState() => _BookListViewState();
}

class _BookListViewState extends State<BookListView> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final List<Book> _books = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  // 模拟网络请求延迟
  Future<void> _loadBooks() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 800));

    // 模拟分页数据
    final newBooks = _getMockBooks(_currentPage);
    
    setState(() {
      if (_currentPage == 1) {
        _books.clear();
      }
      _books.addAll(newBooks);
      _hasMore = newBooks.length == 10; // 假设每页10本书
      _isLoading = false;
    });
  }

  // 下拉刷新
  void _onRefresh() async {
    _currentPage = 1;
    _hasMore = true;
    await _loadBooks();
    _refreshController.refreshCompleted();
  }

  // 上拉加载更多
  void _onLoading() async {
    if (!_hasMore) {
      _refreshController.loadNoData();
      return;
    }
    
    _currentPage++;
    await _loadBooks();
    _refreshController.loadComplete();
  }

  // 生成模拟数据
  List<Book> _getMockBooks(int page) {
    final List<Book> mockBooks = [
      Book(
        id: '${page}_1',
        title: '高等数学（第七版）',
        subtitle: '同济大学数学系编著的经典教材，涵盖微积分、线性代数等核心内容，适合理工科学生学习。',
        coverImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=400&fit=crop',
        author: '同济大学数学系',
        publishYear: '2014',
      ),
      Book(
        id: '${page}_2',
        title: '线性代数及其应用',
        subtitle: 'David C. Lay教授的经典教材，深入浅出地讲解线性代数的基本概念和应用。',
        coverImage: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=300&h=400&fit=crop',
        author: 'David C. Lay',
        publishYear: '2012',
      ),
      Book(
        id: '${page}_3',
        title: '概率论与数理统计',
        subtitle: '浙江大学盛骤教授主编，系统介绍概率论与数理统计的基本理论和方法。',
        coverImage: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=300&h=400&fit=crop',
        author: '盛骤',
        publishYear: '2008',
      ),
      Book(
        id: '${page}_4',
        title: '数学分析',
        subtitle: '华东师范大学数学系编著的数学分析教材，严谨的数学推导和丰富的例题。',
        coverImage: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300&h=400&fit=crop',
        author: '华东师范大学数学系',
        publishYear: '2010',
      ),
      Book(
        id: '${page}_5',
        title: '离散数学',
        subtitle: 'Kenneth H. Rosen的经典教材，涵盖集合论、图论、组合数学等离散数学核心内容。',
        coverImage: 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=300&h=400&fit=crop',
        author: 'Kenneth H. Rosen',
        publishYear: '2012',
      ),
      Book(
        id: '${page}_6',
        title: '复变函数论',
        subtitle: '钟玉泉教授编著的复变函数教材，深入讲解复分析的理论和应用。',
        coverImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=400&fit=crop',
        author: '钟玉泉',
        publishYear: '2004',
      ),
      Book(
        id: '${page}_7',
        title: '微分几何',
        subtitle: '陈维桓教授编著的微分几何教材，系统介绍微分几何的基本概念和方法。',
        coverImage: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=300&h=400&fit=crop',
        author: '陈维桓',
        publishYear: '2006',
      ),
      Book(
        id: '${page}_8',
        title: '抽象代数',
        subtitle: 'Joseph A. Gallian的抽象代数教材，涵盖群论、环论、域论等抽象代数核心内容。',
        coverImage: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=300&h=400&fit=crop',
        author: 'Joseph A. Gallian',
        publishYear: '2017',
      ),
      Book(
        id: '${page}_9',
        title: '拓扑学',
        subtitle: 'James R. Munkres的拓扑学教材，深入讲解点集拓扑和代数拓扑。',
        coverImage: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300&h=400&fit=crop',
        author: 'James R. Munkres',
        publishYear: '2000',
      ),
      Book(
        id: '${page}_10',
        title: '实变函数论',
        subtitle: '周民强教授编著的实变函数教材，严谨的数学推导和丰富的应用实例。',
        coverImage: 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=300&h=400&fit=crop',
        author: '周民强',
        publishYear: '2003',
      ),
    ];

    // 根据页码返回不同的数据
    if (page == 1) {
      return mockBooks.take(10).toList();
    } else if (page == 2) {
      return mockBooks.take(8).toList(); // 第二页只有8本书
    } else {
      return []; // 第三页开始没有更多数据
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('数学书籍'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<void>(
        future: Future.value(), // 空Future，用于触发初始加载
        builder: (context, snapshot) {
          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: _hasMore,
            header: WaterDropHeader(),
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
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: _books.isEmpty && !_isLoading
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      return _buildBookItem(_books[index]);
                    },
                  ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  // 空状态组件
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            '暂无书籍数据',
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

  // 书籍项组件
  Widget _buildBookItem(Book book) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // 处理书籍点击事件
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('点击了《${book.title}》')),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 书籍封面
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      book.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.book,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // 书籍信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '作者：${book.author}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '出版年份：${book.publishYear}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        book.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 书籍数据模型
class Book {
  final String id;
  final String title;
  final String subtitle;
  final String coverImage;
  final String author;
  final String publishYear;

  Book({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coverImage,
    required this.author,
    required this.publishYear,
  });
}
