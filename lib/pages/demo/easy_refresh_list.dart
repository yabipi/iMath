import 'dart:async';

import 'package:flutter/material.dart';
import 'package:imath/widgets/refresh/constructor.dart';
import 'package:imath/widgets/refresh/paging_mixin.dart';

class EasyRefreshListScreen extends StatefulWidget {
  const EasyRefreshListScreen({super.key});

  @override
  State<EasyRefreshListScreen> createState() => _EasyRefreshListScreenState();
}

class _EasyRefreshListScreenState extends State<EasyRefreshListScreen> {
  final ScrollController _scrollController = ScrollController();
  late PagingMixin<User> _controller;

  void initState() {
    super.initState();
    _controller = UserListController();
    _controller.initPaging();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('无限下拉列表'),
      ),
      body: SpeedyPagedList<User>.separated(
        controller: _controller,
        itemBuilder: (context, index, item) {
          return ListTile(
            title: Text(item.name),
            subtitle: Text(item.desc ?? ''),
          );
        },
        scrollController: _scrollController,
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      )
    );
  }
}

class User {
  final String name;
  final String avatar;
  final String? desc;

  User({
    required this.name,
    required this.avatar,
    this.desc,
  });
}

class UserListController with PagingMixin<User> {
  @override
  FutureOr fecthData(int page) {
    final users = List.generate(10, (index) => User(
      name: 'name $page-$index',
      avatar: 'https://picsum.photos/200/300?random=$page-$index',
      desc: 'desc $page-$index',
    ));
    endLoad(users, maxCount:100);
  }
}