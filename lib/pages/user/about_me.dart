import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../../http/init.dart';

class AboutMePage extends StatefulWidget {
  @override
  _AboutMePageState createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  Map<String, dynamic> _aboutInfo = {};

  @override
  void initState() {
    super.initState();
    _fetchAboutInfo();
  }

  Future<void> _fetchAboutInfo() async {
    try {
      final response = await Request().get('${ApiConfig.SERVER_BASE_URL}/api/sys/about');
      if (response.statusCode == 200) {
        setState(() {
          _aboutInfo = response.data;
        });
      }
    } catch (e) {
      print('Error fetching about info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('关于我们'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('公司信息'),
            _buildInfoItem('公司名称', _aboutInfo['companyName'] ?? '加载中...'),
            _buildInfoItem('成立时间', _aboutInfo['establishedDate'] ?? '加载中...'),
            _buildInfoItem('总部地点', _aboutInfo['headquarters'] ?? '加载中...'),
            SizedBox(height: 20),
            _buildSectionTitle('软件信息'),
            _buildInfoItem('应用名称', _aboutInfo['appName'] ?? '加载中...'),
            _buildInfoItem('当前环境', ApiConfig.environment ?? '开发环境'),
            _buildInfoItem('版本号', _aboutInfo['version'] ?? '加载中...'),
            _buildInfoItem('开发团队', _aboutInfo['developmentTeam'] ?? '加载中...'),
            _buildInfoItem('技术支持', _aboutInfo['supportEmail'] ?? '加载中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}