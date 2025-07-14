import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/pages/common/bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentCarouselIndex = 0;
  
  // 轮播图数据
  final List<Map<String, dynamic>> carouselData = [
    {
      'image': 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800&h=400&fit=crop',
      'title': '数学之美',
      'subtitle': '探索数学的无限魅力',
    },
    {
      'image': 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=800&h=400&fit=crop',
      'title': '几何世界',
      'subtitle': '从欧几里得到现代几何学',
    },
    {
      'image': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=400&fit=crop',
      'title': '代数基础',
      'subtitle': '代数学的发展历程',
    },
    {
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=400&fit=crop',
      'title': '数学思维',
      'subtitle': '培养逻辑思维能力',
    },
    {
      'image': 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800&h=400&fit=crop',
      'title': '数学大师',
      'subtitle': '高斯、黎曼、伽罗瓦、欧拉、牛顿、阿基米德、笛卡尔、费马、拉格朗日、柯西、庞加莱、希尔伯特、哥德尔、图灵、陈省身、华罗庚等二十位数学巨匠',
    },
  ];

  // 功能区数据
  final List<Map<String, dynamic>> functionItems = [
    {
      'icon': Icons.person,
      'title': '大师风采',
      'color': Colors.blue,
    },
    {
      'icon': Icons.school,
      'title': '治学经验',
      'color': Colors.green,
    },
    {
      'icon': Icons.book,
      'title': '数学书籍',
      'color': Colors.orange,
    },
    {
      'icon': Icons.star,
      'title': '名题欣赏',
      'color': Colors.purple,
    },
  ];

  // 文章列表数据
  final List<Map<String, dynamic>> articles = [
    {
      'icon': Icons.article,
      'title': '数学史上的重要发现',
      'subtitle': '探索数学发展历程中的重要里程碑',
    },
    {
      'icon': Icons.calculate,
      'title': '微积分的发展与应用',
      'subtitle': '从牛顿到现代：微积分的演变历程',
    },
    {
      'icon': Icons.functions,
      'title': '函数论基础',
      'subtitle': '深入理解函数的基本概念和性质',
    },
    {
      'icon': Icons.timeline,
      'title': '数学建模实践',
      'subtitle': '如何将实际问题转化为数学模型',
    },
    {
      'icon': Icons.psychology,
      'title': '数学思维培养',
      'subtitle': '提升数学思维能力的有效方法',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iMath'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 轮播图部分
            _buildCarouselSection(),
            
            // 功能区部分
            _buildFunctionSection(),
            
            // 文章列表部分
            _buildArticleSection(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  // 轮播图组件
  Widget _buildCarouselSection() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
            ),
            items: carouselData.map((item) {
              return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.network(
                        item['image'],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                      // 渐变遮罩
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // 文字覆盖层
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              item['subtitle'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          // 轮播图指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: carouselData.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentCarouselIndex == entry.key
                      ? Colors.blue
                      : Colors.grey[300],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 功能区组件
  Widget _buildFunctionSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '功能导航',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.2,
            ),
            itemCount: functionItems.length,
            itemBuilder: (context, index) {
              return _buildFunctionItem(functionItems[index]);
            },
          ),
        ],
      ),
    );
  }

  // 功能项组件
  Widget _buildFunctionItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        if(item['title'] == '数学书籍') {
          context.go('/booklist');
        }
        // 处理功能点击事件
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('点击了${item['title']}')),
        );
      },
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: item['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'],
                size: 16,
                color: item['color'],
              ),
            ),
            SizedBox(height: 6),
            Text(
              item['title'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 文章列表组件
  Widget _buildArticleSection() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推荐文章',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return _buildArticleItem(articles[index]);
            },
          ),
        ],
      ),
    );
  }

  // 文章项组件
  Widget _buildArticleItem(Map<String, dynamic> article) {
    return GestureDetector(
      onTap: () {
        // 处理文章点击事件
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('点击了${article['title']}')),
        // );
        context.go('/newsdetail');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                article['icon'],
                size: 24,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    article['subtitle'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
