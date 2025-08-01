import 'dart:developer';

import 'package:oauth2/oauth2.dart';

import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {
  bool isLoginRequest(request) {
    return (ApiConfig.SERVER_BASE_URL + AuthService.signInUrl ==
        request.url.toString());
  }

  int retry = 0;
  @override
  void onInit() {
    // httpClient.baseUrl = ApiConfig.SERVER_BASE_URL;
    // httpClient.timeout = const Duration(seconds: 30);
    // httpClient.maxAuthRetries = retry = 3;
    // httpClient.followRedirects = true;

//addAuthenticator only is called after
//a request (get/post/put/delete) that returns HTTP status code 401
//     httpClient.addAuthenticator<dynamic>((request) async {
//       retry--;
//       log('addAuthenticator ${request.url.toString()}');
//
//       // AuthController authController = Get.find();
//       AuthApiService authService = Get.find();
//       Credentials? oauthCredentails = authService.credentials;
//       try {
//         if (oauthCredentails != null && oauthCredentails.canRefresh) {
//           oauthCredentails = await authController.refreshToken();
//
//           if (oauthCredentails!.accessToken.isNotEmpty) {
//             request.headers['Authorization'] =
//                 'Bearer ${oauthCredentails.accessToken}';
//           } else {
//             if (retry == 0) {
//               retry = httpClient.maxAuthRetries;
//
//               if (!isLoginRequest(request)) {
//                 // log('check is isLoginRequest(request): ${isLoginRequest(request)}');
//                 // Get.offAllNamed(Routes.LOGIN);
//               }
//             }
//           }
//         } else {
//           if (retry == 0) {
//             retry = httpClient.maxAuthRetries;
//             if (!isLoginRequest(request)) {
//               // Get.offAllNamed(Routes.LOGIN, arguments: {
//               //   'message': {
//               //     'status': 'warning',
//               //     'status_text': 'session_expired',
//               //     'body': 'Session expired please log in again.!'
//               //   }
//               // });
//             }
//           }
//         }
//       } catch (err, _) {
//         printError(info: err.toString());
//
//         // Get.offAllNamed(Routes.LOGIN, arguments: {
//         //   'message': {
//         //     'status': 'warning',
//         //     'status_text': 'session_expired',
//         //     'body':
//         //         'Session expired Or invalid refresh token, please log in again.!'
//         //   }
//         // });
//       }
//
//       return request;
//     });

    // httpClient.addResponseModifier((request, response) {
    //   //Some resources have been omitted because of insufficient authorization
    //   // var body = jsonDecode(response.body.toString());
    //   // if (body != null &&
    //   //     body.containsKey('meta') &&
    //   //     body['meta'].containsKey('omitted')) {
    //   //   return Response(request: request, statusCode: 401);
    //   // }
    //   return response;
    // });

    // httpClient.addRequestModifier<dynamic>((request) async {
    //   // log('call addRequestModifier , ${request.headers}');
    //   AuthController authController = Get.find();
    //
    //   var tc = authController.tokenCredentials();
    //
    //   if (tc != null && tc.accessToken.isNotEmpty) {
    //     // log('Add Request Modifier is authenticated ${authController.tokenCredentials()!.accessToken}');
    //     request.headers['Authorization'] =
    //         'Bearer ${authController.tokenCredentials()!.accessToken}';
    //   }
    //
    //   return request;
    // });
  }
}
