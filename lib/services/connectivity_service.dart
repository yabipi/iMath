import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// class ConnectivityService extends GetxService {
class ConnectivityService {
  // @override
  void onInit() async {
    // super.onInit();
    // var hasConnection = await InternetConnectionChecker().hasConnection;
    // bool hasConnection = await InternetConnection().hasInternetAccess;
    // if (!hasConnection) {
    //   showDialog();
    // }
    //
    // var listener = InternetConnectionChecker().onStatusChange.listen((status) {
    //   switch (status) {
    //     case InternetConnectionStatus.connected:
    //       hideDialogIfOpen();
    //       print('Data connection is available.');
    //       break;
    //     case InternetConnectionStatus.disconnected:
    //       if (Get.isDialogOpen != true) {
    //         showDialog();
    //       }
    //       print('You are disconnected from the internet.');
    //       break;
    //   }
    // });
    //
    // // close listener after 30 seconds, so the program doesn't run forever
    // Future.delayed(Duration(seconds: 30), () {
    //   listener.cancel();
    // });
  }

  static Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('www.baidu.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<bool> isConnected() async {
    final List<ConnectivityResult> connectivityResult =
    await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (await hasNetwork()) {
        return true;
      }
      return false;
    } else {
      return true;
    }
  }

  static Future<String> checkConnect() async {
    final List<ConnectivityResult> connectivityResult =
    await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return '正在使用移动流量';
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return '正在使用wifi';
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      return '正在使用局域网';
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      return '正在使用代理网络';
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      return '正在使用蓝牙网络';
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      return '正在使用其他网络';
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      return '未连接到任何网络';
    } else {
      return '';
    }
  }

  void hideDialogIfOpen() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  void showDialog() {
    Get.dialog(
      CupertinoAlertDialog(
        title: Row(children: [
          const Icon(Icons.signal_wifi_off_outlined),
          Container(
              margin: const EdgeInsets.only(left: 5),
              child: const Text('You are currently offline')),
        ]),
        content: const Text(
            'Please turn on network connection to continue using this app'),
      ),
      barrierDismissible: true,
    );
  }
}
