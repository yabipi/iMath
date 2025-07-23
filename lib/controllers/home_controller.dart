import 'dart:developer';

import 'package:oauth2/oauth2.dart';

import '../config/api_config.dart';

import '../mixins/helper_mixin.dart';
import '../services/auth_service.dart';

class HomeController {
  HomeController();
  late Credentials? credentails;
  String sessionTime = String.fromEnvironment('session_timeout_threshold', defaultValue:'');

  @override
  void onInit() {
    sessionTime = getSessionTime();

    credentails = getcredentials();

    // super.onInit();
  }

  getSessionTime() {
    try {
      int currentTimestamp = HelperMixin.getTimestamp();

      // AuthApiService authenticationService = Get.find();
      // var credentials = authenticationService.credentials;
      // return '${credentials != null ? (credentials.expiration!.millisecondsSinceEpoch / 1000 - ApiConfig.sessionTimeoutThreshold - currentTimestamp) / 60 : 0} mins';
    } catch (err) {
      throw Exception('An error occurred when computing Session time');
    }
    return '${sessionTime} mins';
  }

  Credentials? getcredentials() {
    // AuthApiService authenticationService = Get.find();
    // return authenticationService.credentials!;
    return null;
  }
}
