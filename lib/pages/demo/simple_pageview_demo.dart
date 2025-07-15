import 'package:flutter/material.dart';

// 简化的数据模型
class SimpleItem {
  final int id;
  final String title;
  final String content;

  SimpleItem({
    required this.id,
    required this.title,
    required this.content,
  });
}

// 简化的API服务
class SimpleApiService {
  static Future<List<SimpleItem>> fetchData(int page, int pageSize) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 模拟数据
    List<SimpleItem> items = [];
    int startId = (page - 1) * pageSize + 1;
    
    for (int i = 0; i < pageSize; i++) {
      items.add(SimpleItem(
        id: startId + i,
        title: '第 ${startId + i} 条数据',
        content: '这是第 ${startId + i} 条内容的详细描述。'
            '包含一些较长的文本内容来测试滚动效果。'
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
            'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
            'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
            'nisi ut aliquip ex ea commodo consequat. '
            'Duis aute irure dolor in reprehenderit in voluptate velit esse '
            'cillum dolore eu fugiat nulla pariatur.',
      ));
    }
    
    return items;
  }
}

class SimplePageViewDemo extends StatefulWidget {
  const SimplePageViewDemo({super.key});

  @override
  State<SimplePageViewDemo> createState() => _SimplePageViewDemoState();
}

class _SimplePageViewDemoState extends State<SimplePageViewDemo> {
  final List<SimpleItem> _items = [];
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
    print('开始加载初始数据，页码: $_currentPage');
    
    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await SimpleApiService.fetchData(_currentPage, _pageSize);
      print('获取到 ${newItems.length} 条数据');
      
      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      print('加载数据失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 加载更多数据
  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) {
      print('跳过加载: isLoading=$_isLoading, hasMore=$_hasMore');
      return;
    }

    print('开始加载更多数据，页码: $_currentPage');
    
    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await SimpleApiService.fetchData(_currentPage, _pageSize);
      print('获取到 ${newItems.length} 条新数据');
      
      if (newItems.isEmpty) {
        print('没有更多数据了');
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      print('加载更多数据失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 构建单个页面
  Widget _buildPage(SimpleItem item, int index) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 内容
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Text(
                  item.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 底部信息
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '第 ${index + 1} 页',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'ID: ${item.id}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
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
      itemCount: _items.length,
      onPageChanged: (int page) {
        print('页面切换到: $page, 总页数: ${_items.length}');
        
        // 当滑动到倒数第二个页面时，开始加载更多数据
        if (page >= _items.length - 2 && _hasMore && !_isLoading) {
          print('触发加载更多数据');
          _loadMoreData();
        }
      },
      itemBuilder: (context, index) {
        return _buildPage(_items[index], index);
      },
    );
  }

  // 刷新数据
  Future<void> _refreshData() async {
    print('刷新数据');
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
        title: const Text('PageView 无限滚动'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: '刷新数据',
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
                    Text('正在加载初始数据...'),
                  ],
                ),
              )
            : _buildPageView(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 显示当前状态信息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '当前页数: $_currentPage\n'
                '数据条数: ${_items.length}\n'
                '是否加载中: $_isLoading\n'
                '是否有更多: $_hasMore',
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.blue,
            ),
          );
        },
        icon: const Icon(Icons.info),
        label: const Text('状态'),
      ),
    );
  }
} 