import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/state/settings_provider.dart';

import '../../config/api_config.dart';
import '../../http/init.dart';

const companyInfo = {
  'companyName': '北京易普西隆科技有限公司',
  'description': '我们是一家专注于提供在线教育解决方案的科技公司。',
  'headquarters': '北京',
  'appName': 'iMath',
  'developmentTeam': '易普西隆工作室',
  'supportEmail': 'support@example.com',
  'version': '1.0.0',
};

class AboutMePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于我们'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 顶部装饰区域
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    companyInfo['appName']!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // 主要内容区域
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // 公司信息卡片
                  _buildInfoCard(
                    context,
                    title: '公司信息',
                    icon: Icons.business,
                    children: [
                      _buildInfoItem('公司名称', companyInfo['companyName']!),
                      _buildInfoItem('总部地点', companyInfo['headquarters']!),
                      _buildInfoItem('开发团队', companyInfo['developmentTeam']!),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 应用信息卡片
                  _buildInfoCard(
                    context,
                    title: '应用信息',
                    icon: Icons.apps,
                    children: [
                      _buildInfoItem('应用名称', companyInfo['appName']!),
                      _buildInfoItem('版本号', companyInfo['version']!),
                      _buildInfoItem('当前环境', kReleaseMode ? '生产环境' : '开发环境'),
                      _buildInfoItem(
                          '当前级别', ref.watch(mathLevelProvider).value),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 联系信息卡片
                  _buildInfoCard(
                    context,
                    title: '联系我们',
                    icon: Icons.contact_support,
                    children: [
                      _buildInfoItem('技术支持', companyInfo['supportEmail']!),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 公司描述卡片
                  _buildDescriptionCard(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  '公司简介',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              companyInfo['description']!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _AboutMePageState extends State<AboutMePage> {
//   Map<String, dynamic> _aboutInfo = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchAboutInfo();
//   }
//
//   Future<void> _fetchAboutInfo() async {
//     try {
//       final response = await Request().get('${ApiConfig.SERVER_BASE_URL}/api/sys/about');
//       if (response.statusCode == 200) {
//         setState(() {
//           _aboutInfo = response.data;
//         });
//       }
//     } catch (e) {
//       print('Error fetching about info: $e');
//     }
//   }
//
//
// }
