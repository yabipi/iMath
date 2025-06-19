import 'package:flutter/material.dart';

const pageSize = 10;

class SimpleListView extends StatefulWidget {
  const SimpleListView({Key? key}) : super(key: key);

  @override
  _SimpleListViewState createState() => _SimpleListViewState();
}

class _SimpleListViewState extends State<SimpleListView> {
  int pageNo = 0;
  List<String> _items = [];
  // 模拟从后台获取数据的 Future
  late Future _future;

  fetchData(int offset) async {
    await Future.delayed(Duration(seconds: 2)); // 模拟网络延迟
    final data = List.generate(pageSize, (index) => "Item ${index + offset}");
    _items.addAll(data);
    return _items;
  }

  void initState() {
    super.initState();
    _future = fetchData(pageNo*pageSize);
  }

  // 按钮点击事件
  void _onButtonPressed() {
    setState(() {
      // 更新状态逻辑
      pageNo ++;
      _future = fetchData(pageNo*pageSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('简单列表界面'),
      ),
      body: Column(
        children: [
          // 使用 FutureBuilder 加载数据
          Expanded(
            child: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('数据加载失败'));
                } else if (snapshot.hasData) {
                  final items = snapshot.data!;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(items[index]),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('没有数据'));
                }
              },
            ),
          ),

          // 按钮部分保持不变
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onButtonPressed(),
                  child: Text("加载"),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}