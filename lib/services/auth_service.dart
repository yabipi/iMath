import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:imath/config/constants.dart';

import 'package:imath/core/context.dart';
import 'package:imath/http/auth.dart';
import 'package:imath/state/global_state.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../config/api_config.dart';
import '../db/Storage.dart';
import '../http/init.dart';
import 'api_service.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:oauth2/oauth2.dart';
import 'package:path_provider/path_provider.dart';

import '../mixins/helper_mixin.dart';

import 'package:imath/models/user.dart';

/**
 * 集中了认证登录相关的服务
 */
class AuthService extends ApiService {
  static String signUpUrl = '/api/user/register';
  static String signInUrl = '/api/oauth/token';

  // These URLs are endpoints that are provided by the authorization
// server. They're usually included in the server's documentation of its
// OAuth2 API.
  static String authorizationUrl = '/api/oauth/authorize';
  static String refreshTokenUrl = '/api/oauth/token';
// This is a URL on your application's server. The authorization server
// will redirect the resource owner here once they've authorized the
// client. The redirection will include the authorization code in the
// query parameters.
  static String redirectUrl = ApiConfig.SERVER_BASE_URL + '/';

  final authorizationEndpoint = Uri.parse(ApiConfig.SERVER_BASE_URL + authorizationUrl);
  final tokenEndpoint = Uri.parse(ApiConfig.SERVER_BASE_URL + refreshTokenUrl);

// The authorization server will issue each client a separate client
// identifier and secret, which allows the server to tell which client
// is accessing it. Some servers may also have an anonymous
// identifier/secret pair that any client may use.
//
// Note that clients whose source code or binary executable is readily
// available may not be able to make sure the client secret is kept a
// secret. This is fine; OAuth2 servers generally won't rely on knowing
// with certainty that a client is who it claims to be.
  static const String clientId = 'CLIENT_ID';
  static const String clientSecret = 'CLIENT_SECRET';
  static const List<String> scopes = [];

  /// A file in which the users credentials are stored persistently. If the server
  /// issues a refresh token allowing the client to refresh outdated credentials,
  /// these may be valid indefinitely, meaning the user never has to
  /// re-authenticate.
  late File _credentialsFile;
  var _directory;
  Credentials? credentials;
  late AuthorizationCodeGrant _grant;
  oauth2.Client? client;

  initCredentials() async {
    _directory = await getApplicationDocumentsDirectory();
    _credentialsFile = File('${_directory.path}/credentials.json');
    credentials = await loadCredentails();
  }

  getAuthorizationUrl() {
    // If we don't have OAuth2 credentials yet, we need to get the resource owner
    // to authorize us. We're assuming here that we're a command-line application.
    _grant = oauth2.AuthorizationCodeGrant(
        clientId, authorizationEndpoint, tokenEndpoint,
        secret: clientSecret);
    // A URL on the authorization server (authorizationEndpoint with some additional
    // query parameters). Scopes and state can optionally be passed into this method.
    return _grant.getAuthorizationUrl(
      Uri.parse(redirectUrl),
      scopes: scopes,
    );
  }

  /// Either load an OAuth2 client from saved credentials or authenticate a new one
  Future<oauth2.Client?> handleAuthorizationResponse(Uri responseUrl) async {
    // Once the user is redirected to `redirectUrl`, pass the query parameters to
    // the AuthorizationCodeGrant. It will validate them and extract the
    // authorization code to create a new Client.

    return await _grant
        .handleAuthorizationResponse(responseUrl.queryParameters);
  }

  Future<Credentials?> authGrantPassword(username, password) async {
    // Make a request to the authorization endpoint that will produce the fully
    // authenticated Client.
    var client = await oauth2.resourceOwnerPasswordGrant(
        authorizationEndpoint, username, password,
        identifier: clientId, secret: clientSecret);
    saveCredentails(client.credentials);
    return client.credentials;
  }

  Future<Credentials?> loadCredentails() async {
    var exists = await _credentialsFile.exists();
    // return null;
    // log('${exists.isBlank}');

    return exists && oauth2.Credentials != null
        ? oauth2.Credentials.fromJson(await _credentialsFile.readAsString())
        : null;
  }

  Future<Credentials> refreshToken() async {
    log('refresh-token');
    var credentials = await loadCredentails();
    try {
      if (credentials!.canRefresh) {
        var cre = await credentials.refresh(
            identifier: clientId, secret: clientSecret);

        await saveCredentails(cre);

        return cre;
      } else {
        throw 'Couuld not refresh the Token!';
      }
    } catch (e) {
      // printError(
      //     info:
      //         'Oauth client service exception refreshToken:  ${e.toString()}');
      throw 'Oauth client service exception refreshToken:  ${e.toString()}';
    }
  }

  Future<bool> saveCredentails(Credentials? credentials) async {
    await _credentialsFile.writeAsString(credentials!.toJson());
    this.credentials = credentials;
    return true;
  }

  Future<bool> removeCredentails() async {
    await _credentialsFile.writeAsString('');
    _credentialsFile.delete();
    credentials = null;
    return true;
  }

  Future<void> signin(String username, String password) async {
    try {
      final result = await AuthHttp.signIn(username, password);
      _saveUser(result);
    } catch (err, _) {
      rethrow;
    }
  }

  /**
   * 手机验证码登录
   */
  static Future<bool> signinWithPhone(String phone, String pincode) async {
    try {
      final result = await AuthHttp.verifyCaptcha(phone, pincode);
      if (result['code'] == ApiCode.SUCCESS) {
        // SmartDialog.showToast('验证码正确');
        _saveUser(result);
        return true;
      } else {
        return false;
      }
    } catch (err, _) {
      return false;
    }
  }

  static void _saveUser(result) {
    final user = User.fromJson(result[Constants.USER_KEY]);
    String token = result[Constants.USER_TOKEN];

    if (token.isNotEmpty) {
      GStorage.userInfo.put(Constants.USER_TOKEN, token);
    }
    GStorage.userInfo.put(Constants.USER_KEY, result[Constants.USER_KEY]);
    // 刷新当前用户
    GlobalState.currentUser = user;
  }

  Future<void> signout() async {
    try {
      await AuthHttp.signOut(GlobalState.currentUser?.username);
      GStorage.userInfo.delete(Constants.USER_KEY);
      GlobalState.currentUser = null;
      await Request.setCookie();
    } catch (err, _) {
      rethrow;
    }
  }

  bool sessionIsEmpty() {
    if (credentials == null) return true;
    return false;
  }

  bool sessionIsExpired() {
    int currentTimestamp = HelperMixin.getTimestamp();
    // printInfo(
    //     info:
    //         'Expired in: ${credentials != null ? (credentials!.expiration!.millisecondsSinceEpoch / 1000 - ApiConfig.sessionTimeoutThreshold - currentTimestamp) / 60 : 0} mins -- isExceeded: ${credentials!.isExpired} and Can Refresh : ${credentials!.canRefresh}');
    if (sessionIsEmpty()) return true;

    return credentials!.isExpired;
  }

  // Future<Response?> signUp(Map<String, dynamic> data) async {
  //   try {
  //     var body = {
  //       'name': data['username'],
  //       'mail': data['email'],
  //     };
  //     if (ApiConfig.signupWithPassword) {
  //       body['pass'] = {
  //         'pass1': data['password'],
  //         'pass2': data['confirmPassword']
  //       };
  //     }
  //     return post(signUpUrl, body);
  //   } catch (e) {
  //     // printLog(e);
  //     printError(info: e.toString());
  //     rethrow;
  //   }
  // }

//   void signOut() async {
//     await _authenticationService.signOut();
//     _authenticationStateStream.value = UnAuthenticated();
//   }
}
