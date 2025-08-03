import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:imath/http/article.dart';
import 'package:imath/http/knowledge.dart';
import 'package:imath/models/article.dart';
import 'package:imath/models/knowledges.dart';
import 'package:imath/utils/string_util.dart';

class KnowledgeDetailScreen extends StatefulWidget {
  final int knowledgeId;

  const KnowledgeDetailScreen({super.key, required this.knowledgeId});


  @override
  State<StatefulWidget> createState() => _KnowledgeDetailScreenState();
}

class _KnowledgeDetailScreenState extends State<KnowledgeDetailScreen> {
  late Article knowledge;
  late Future _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchKnowledge();
  }

  Future<void> _fetchKnowledge() async {
    final response = await ArticleHttp.loadArticle(widget.knowledgeId);
    knowledge = Article.fromJson(response);
    // knowledge = StringUtil.firstNonEmptyString(article['markdown'],
    //     [article['html'], article['lake'], article['markdown']]);
    //knowledge = Knowledge.fromJson(response['know_item']);

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text(knowledge.title),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: GptMarkdown(
                      knowledge.markdown,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text('数据加载失败'));
          }
        }
    );

  }
}

