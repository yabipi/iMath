import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/mathematician.dart';
import 'mathematician_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('数学文化'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '人物'),
              Tab(text: '数学故事'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 数学人物标签页
            ListView.builder(
              itemCount: mathematicians.length,
              itemBuilder: (context, index) {
                final mathematician = mathematicians[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        mathematician.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SvgPicture.asset(
                            'assets/images/placeholder.svg',
                            width: 50,
                            height: 50,
                          );
                        },
                      ),
                    ),
                    title: Text(mathematician.name),
                    subtitle: Text(
                      '${mathematician.nationality} · ${mathematician.period}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MathematicianDetailScreen(
                            mathematician: mathematician,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // 数学故事标签页
            ListView.builder(
              itemCount: 10, // 示例数据
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.auto_stories),
                    title: Text('数学故事 ${index + 1}'),
                    subtitle: const Text('故事简介...'),
                    onTap: () {
                      // 导航到故事详情页
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 