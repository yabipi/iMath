import 'package:flutter/cupertino.dart';

import '../services/auth_service.dart';
// extends GetMiddleware
class AuthMiddleware  {
  late AuthService _authenticationService;

  @override
  RouteSettings? redirect(String? route) {
    if (_authenticationService.sessionIsEmpty()) {
      // return RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}
