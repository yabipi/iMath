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
}

const String CATEGORIES_KEY = 'categories';

const QuestionTypes = ['单选题', '多选题', '填空题', '解答题'];

enum PaperViewMode {
  // 默认
  DefaultMode,
  // 预览
  PreviewMode,
  // 考试
  ExamMode,
}
