import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

abstract class Storage {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);

  Future<int> count({String? prefix});

  Future<void> clear({String? prefix});
}

class GStorage {
  static late final Box<dynamic> userInfo;
  static late final Box<dynamic> historyword;
  static late final Box<dynamic> localCache;
  static late final Box<dynamic> setting;
  static late final Box<dynamic> video;

  static Future<void> init() async {
    final Directory dir = await getApplicationSupportDirectory();
    final String path = dir.path;
    await Hive.initFlutter('$path/hive');
    regAdapter();
    // 登录用户信息
    userInfo = await Hive.openBox(
      'userInfo',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 2;
      },
    );
    // userInfo.put('username', 'kuku');
    // 本地缓存
    localCache = await Hive.openBox(
      'localCache',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 4;
      },
    );
    // 设置
    setting = await Hive.openBox('setting');
    // 搜索历史
    historyword = await Hive.openBox(
      'historyWord',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 10;
      },
    );
    // 视频设置
    video = await Hive.openBox('video');
  }

  static void regAdapter() {
    // Hive.registerAdapter(UserInfoDataAdapter());
    // Hive.registerAdapter(LevelInfoAdapter());
  }

  static Future<void> close() async {
    // user.compact();
    // user.close();
    userInfo.compact();
    userInfo.close();
    historyword.compact();
    historyword.close();
    localCache.compact();
    localCache.close();
    setting.compact();
    setting.close();
    video.compact();
    video.close();
  }
}