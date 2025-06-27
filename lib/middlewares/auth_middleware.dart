import 'package:flutter/cupertino.dart';

import '../services/auth_api_service.dart';
// extends GetMiddleware
class AuthMiddleware  {
  late AuthApiService _authenticationService;

  @override
  RouteSettings? redirect(String? route) {
    if (_authenticationService.sessionIsEmpty()) {
      // return RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}
