import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Config {
  static bool? DEBUG = true;

  static const PAGE_SIZE = 20;

  /// //////////////////////////////////////常量////////////////////////////////////// ///
  static const API_TOKEN = "4d65e2a5626103f92a71867d7b49fea0";
  static const TOKEN_KEY = "token";
  static const USER_NAME_KEY = "user-name";
  static const PW_KEY = "user-pw";
  static const USER_BASIC_CODE = "user-basic-code";
  static const USER_INFO = "user-info";
  static const LANGUAGE_SELECT = "language-select";
  static const LANGUAGE_SELECT_NAME = "language-select-name";
  static const REFRESH_LANGUAGE = "refreshLanguageApp";
  static const THEME_COLOR = "theme-color";
  static const LOCALE = "locale";
}

enum HOME_COLUMN {
  PEOPLE("大师风采", Icons.person, Colors.blue),
  BOOKS("数学书籍", Icons.book, Colors.orange),
  PROBLEMS("难题欣赏", Icons.person, Colors.blue),
  EXPERIENCE("治学经验", Icons.star, Colors.purple);
  /// 默认
  final String value;
  final IconData icon;
  final Color color;
  const HOME_COLUMN(this.value, this.icon, this.color);
}
