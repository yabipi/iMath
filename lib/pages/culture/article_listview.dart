import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/http/article.dart';
import 'package:imath/pages/culture/news_tile.dart';

class ArticleListView extends StatefulWidget {
  @override
  _ArticleListViewState createState() => _ArticleListViewState();
}

class _ArticleListViewState extends State<ArticleListView> {
  // 模拟从网络或本地获取文章列表数据
  Future _fetchArticles() async {
    // 假设延迟2秒模拟网络请求
    // await Future.delayed(Duration(seconds: 2));
    final articles = await ArticleHttp.loadArticles();
    return articles;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchArticles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('错误: ${snapshot.error}'));
        } else if (snapshot.connectionState == ConnectionState.done) {
          return SingleChildScrollView(
            child: Container(
              child: Container(
                margin: EdgeInsets.only(top: 16),
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      return Stack(
                        children: [
                          NewsTile(
                            title: item['title'],
                            onTap: () {
                              // context.go("/article/${item['id']}");
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
                    }),
              ),
            ),
          );
        } else {
          return Center(child: Text('没有数据'));
        }
      }
    );
  }
}