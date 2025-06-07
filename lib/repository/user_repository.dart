import 'dart:convert';

import '../config/config.dart';
import '../db/local_storage.dart';
import '../models/user.dart';
import 'data_result.dart';


class UserRepository {
  static oauth(code, store) async {

    //   var token = result.queryParameters["access_token"]!;
    //   var token0 = 'token $token';
    //   await LocalStorage.save(Config.TOKEN_KEY, token0);
    //
    //
    //
    // return DataResult(resultData, res!.result);
  }

  static login(String userName, String password, store) async {
    String type = "$userName:$password";
    var bytes = utf8.encode(type);
    var base64Str = base64.encode(bytes);
    // if (Config.DEBUG!) {
    //   printLog("base64Str login $base64Str");
    // }

    // await LocalStorage.save(Config.USER_NAME_KEY, userName);
    // await LocalStorage.save(Config.USER_BASIC_CODE, base64Str);

    // Map requestParams = {
    //   "scopes": ['user', 'repo', 'gist', 'notifications'],
    //   "note": "admin_script",
    //   "client_id": NetConfig.CLIENT_ID,
    //   "client_secret": NetConfig.CLIENT_SECRET
    // };

    // return DataResult(resultData, res!.result);
  }

  ///初始化用户信息
  // static initUserInfo(Store<GSYState> store, WidgetRef ref) async {
  //   var token = await LocalStorage.get(Config.TOKEN_KEY);
  //   var res = await getUserInfoLocal();
  //   if (res != null && res.result && token != null) {
  //     store.dispatch(UpdateUserAction(res.data));
  //   }
  //
  //   ///读取主题
  //   String? themeIndex = await LocalStorage.get(Config.THEME_COLOR);
  //   ref.read(appThemeStateProvider.notifier).pushTheme(themeIndex);
  //
  //   ///切换语言
  //   String? localeIndex = await LocalStorage.get(Config.LOCALE);
  //   ref.read(appLocalStateProvider.notifier).changeLocale(localeIndex);
  //
  //   return DataResult(res.data, (res.result && (token != null)));
  // }

  ///获取本地登录用户信息
  static getUserInfoLocal() async {
    var userText = await LocalStorage.get(Config.USER_INFO);
    if (userText != null) {
      var userMap = json.decode(userText);
      User user = User.fromJson(userMap);
      return DataResult(user, true);
    } else {
      return DataResult(null, false);
    }
  }

  ///获取用户详细信息
  // static getUserInfo(String? userName, {needDb = false}) async {
  //   UserInfoDbProvider provider = UserInfoDbProvider();
  //   next() async {
  //     dynamic res;
  //     if (userName == null) {
  //       res = await httpManager.netFetch(
  //           Address.getMyUserInfo(), null, null, null);
  //     } else {
  //       res = await httpManager.netFetch(
  //           Address.getUserInfo(userName), null, null, null);
  //     }
  //     if (res != null && res.result) {
  //       String? starred = "---";
  //       if (res.data["type"] != "Organization") {
  //         var countRes = await getUserStaredCountNet(res.data["login"]);
  //         if (countRes.result) {
  //           starred = countRes.data;
  //         }
  //       }
  //       User user = User.fromJson(res.data);
  //       user.starred = starred;
  //       if (userName == null) {
  //         LocalStorage.save(Config.USER_INFO, json.encode(user.toJson()));
  //       } else {
  //         if (needDb) {
  //           provider.insert(userName, json.encode(user.toJson()));
  //         }
  //       }
  //       return DataResult(user, true);
  //     } else {
  //       return DataResult(res.data, false);
  //     }
  //   }
  //
  //   if (needDb) {
  //     User? user = await provider.getUserInfo(userName);
  //     if (user == null) {
  //       return await next();
  //     }
  //     DataResult dataResult = DataResult(user, true, next: next);
  //     return dataResult;
  //   }
  //   return await next();
  // }

  // static clearAll(Store store) async {
  //   httpManager.clearAuthorization();
  //   LocalStorage.remove(Config.USER_INFO);
  //   store.dispatch(UpdateUserAction(User.empty()));
  // }

  /// 在header中提起stared count
  // static getUserStaredCountNet(String userName) async {
  //   String url = Address.userStar(userName, null) + "&per_page=1";
  //   var res = await httpManager.netFetch(url, null, null, null);
  //   if (res != null && res.result && res.headers != null) {
  //     try {
  //       StringList? link = res.headers['link'];
  //       if (link != null) {
  //         var [linkFirst] = link;
  //         int indexStart = linkFirst.lastIndexOf("page=") + 5;
  //         int indexEnd = linkFirst.lastIndexOf(">");
  //         if (indexStart >= 0 && indexEnd >= 0) {
  //           String count = linkFirst.substring(indexStart, indexEnd);
  //           return DataResult(count, true);
  //         }
  //       }
  //     } catch (e) {
  //       printLog(e);
  //     }
  //   }
  //   return DataResult(null, false);
  // }


}
