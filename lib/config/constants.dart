import 'package:flutter/material.dart';

class HttpString {
  static const String baseUrl = 'https://www.icodelib.cn';
  static const String apiBaseUrl = 'https://api.icodelib.cn';


  static const List<int> validateStatusCodes = [
    302,
    304,
    307,
    400,
    401,
    403,
    404,
    405,
    409,
    412,
    500,
    503,
    504,
    509,
    616,
    617,
    625,
    626,
    628,
    629,
    632,
    643,
    650,
    652,
    658,
    662,
    688,
    689,
    701,
    799,
    8888
  ];
}

class StyleString {
  static const double cardSpace = 8;
  static const double safeSpace = 12;
  static BorderRadius mdRadius = BorderRadius.circular(10);
  static const Radius imgRadius = Radius.circular(10);
  static const double aspectRatio = 16 / 10;
}

class Constants {
  // 27eb53fc9058f8c3  移动端 Android
  // 4409e2ce8ffd12b8  TV端
  static const String appKey = '4409e2ce8ffd12b8';
  // 59b43e04ad6965f34319062b478f83dd TV端
  static const String appSec = '59b43e04ad6965f34319062b478f83dd';
  static const String thirdSign = '04224646d1fea004e79606d3b038c84a';
  static const String thirdApi =
      'https://www.mcbbs.net/template/mcbbs/image/special_photo_bg.png';

  static const String USER_KEY = "user";
  static const String USER_TOKEN = "token";
}

const int ALL_CATEGORY = 0;
const String CATEGORIES_KEY = 'categories';
const String CATEGORY_PRIMARY = 'primary';
const String CATEGORY_ADVANCED = 'advanced';

const QuestionTypes = ['单选题', '多选题', '填空题', '解答题'];

enum MATH_LEVEL {
  Primary,
  Advanced,
}

extension MATH_LEVEL_Extension on MATH_LEVEL {
  String get value {
    switch (this) {
      case MATH_LEVEL.Primary:
        return '初等数学';
      case MATH_LEVEL.Advanced:
        return '高等数学';
      default:
        return '';
    }
  }
}
enum PaperViewMode {
  // 默认
  DefaultMode,
  // 预览
  PreviewMode,
  // 考试
  ExamMode,
}

// 文章类型
enum ArticleType {
  normal(0, '知识点'), // 知识点
  hot(1, '热门文章'), // 热门文章
  experience(2, '治学经验'), // 治学经验
  story(3, '人物故事'), // 人物故事
  problem(4, '难题欣赏'),// 难题欣赏
  trends(5, '前沿动态');

  final int value;
  final String label;
  const ArticleType(this.value, this.label);
}

// 内容格式
enum ContentFormat {
  plain,
  html,
  markdown,
  lake;
}

class ApiCode {
  // 成功
  static const int SUCCESS = 200;

  // 重定向
  static const int REDIRECT = 302;
  static const int NOT_MODIFIED = 304;

  // 客户端错误
  static const int BAD_REQUEST = 400;
  static const int UNAUTHORIZED = 401;
  static const int FORBIDDEN = 403;
  static const int NOT_FOUND = 404;
  static const int METHOD_NOT_ALLOWED = 405;
  static const int CONFLICT = 409;
  static const int PRECONDITION_FAILED = 412;

  // 服务器错误
  static const int INTERNAL_SERVER_ERROR = 500;
  static const int SERVICE_UNAVAILABLE = 503;
  static const int GATEWAY_TIMEOUT = 504;

  // 用户模块
  static const int NEW_USER = 101;
  // 自定义业务错误码（可根据实际后端定义调整）
  static const int CUSTOM_ERROR_START = 600;

  static const int USER_NOT_FOUND = 616;
  static const int INVALID_CREDENTIALS = 617;
  static const int TOKEN_EXPIRED = 625;
  static const int TOKEN_INVALID = 626;
  static const int PERMISSION_DENIED = 628;
  static const int RESOURCE_NOT_FOUND = 629;
  static const int VALIDATION_FAILED = 632;
  static const int RATE_LIMIT_EXCEEDED = 643;
  static const int ACTION_FAILED = 650;
  static const int DATA_ALREADY_EXISTS = 652;
  static const int OPERATION_TIMEOUT = 658;
  static const int NETWORK_ERROR = 662;
  static const int FILE_TOO_LARGE = 688;
  static const int UNSUPPORTED_FILE_TYPE = 689;
  static const int PAYMENT_REQUIRED = 701;
  static const int CUSTOM_ERROR_END = 799;

  // 网络相关错误
  static const int NETWORK_CONNECT_TIMEOUT_ERROR = 8888;
}
