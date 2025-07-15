import 'package:flutter/material.dart';

// 模拟数据模型
class DemoItem {
  final int id;
  final String title;
  final String content;
  final String imageUrl;

  DemoItem({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  factory DemoItem.fromJson(Map<String, dynamic> json) {
    return DemoItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

// 模拟API服务
class DemoApiService {
  static Future<List<DemoItem>> fetchData(int page, int pageSize) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 模拟数据
    List<DemoItem> items = [];
    int startId = (page - 1) * pageSize + 1;
    
    for (int i = 0; i < pageSize; i++) {
      items.add(DemoItem(
        id: startId + i,
        title: '标题 ${startId + i}',
        content: '这是第 ${startId + i} 条内容。包含一些较长的文本内容来测试滚动效果。'
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
            'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
            'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
            'nisi ut aliquip ex ea commodo consequat.',
        imageUrl: 'https://picsum.photos/300/200?random=${startId + i}',
      ));
    }
    
    return items;
  }
}

class PageViewDemo extends StatefulWidget {
  const PageViewDemo({super.key});

  @override
  State<PageViewDemo> createState() => _PageViewDemoState();
}

class _PageViewDemoState extends State<PageViewDemo> {
  final List<DemoItem> _items = [];
  final PageController _pageController = PageController();
  
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 加载初始数据
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await DemoApiService.fetchData(_currentPage, _pageSize);
      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('加载数据失败: $e');
    }
  }

  // 加载更多数据
  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await DemoApiService.fetchData(_currentPage, _pageSize);
      
      if (newItems.isEmpty) {
        // 没有更多数据了
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        _showInfoSnackBar('已加载全部数据');
        return;
      }

      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('加载更多数据失败: $e');
    }
  }

  // 构建单个页面
  Widget _buildPage(DemoItem item, int index) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 图片
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
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
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 内容
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Text(
                item.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 底部信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '第 ${index + 1} 页',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                'ID: ${item.id}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建PageView
  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _items.length + (_hasMore ? 1 : 0), // 如果有更多数据，添加一个加载页面
      onPageChanged: (int page) {
        // 当滑动到倒数第二个页面时，开始加载更多数据
        if (page >= _items.length - 2 && _hasMore && !_isLoading) {
          _loadMoreData();
        }
      },
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          // 加载更多页面
          return Container(
            height: MediaQuery.of(context).size.height,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('加载更多数据...'),
                ],
              ),
            ),
          );
        }
        
        return _buildPage(_items[index], index);
      },
    );
  }

  // 显示错误信息
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 显示信息
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 刷新数据
  Future<void> _refreshData() async {
    setState(() {
      _items.clear();
      _currentPage = 1;
      _hasMore = true;
      _isLoading = false;
    });
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PageView 无限滚动示例'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _items.isEmpty && _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在加载数据...'),
                  ],
                ),
              )
            : _buildPageView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 显示当前状态信息
          _showInfoSnackBar(
            '当前页数: $_currentPage, 数据条数: ${_items.length}, 是否加载中: $_isLoading, 是否有更多: $_hasMore',
          );
        },
        child: const Icon(Icons.info),
      ),
    );
  }
}
