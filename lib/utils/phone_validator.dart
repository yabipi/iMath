class PhoneValidator {
  /// 验证手机号是否有效
  static bool isValid(String phoneNumber, {bool strict = true}) {
    if (phoneNumber.isEmpty) return false;

    // 去除所有非数字字符
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // 严格模式：必须是中国大陆手机号
    if (strict) {
      return _isChinesePhoneNumber(cleanedNumber);
    }

    // 宽松模式：支持国际号码（简单验证）
    return _isInternationalPhoneNumber(cleanedNumber);
  }

  /// 验证中国大陆手机号
  static bool _isChinesePhoneNumber(String number) {
    // 中国手机号格式：1开头，11位数字
    // 目前支持的号段：
    // 13x, 14x, 15x, 16x, 17x, 18x, 19x
    final regExp = RegExp(r'^1(3[0-9]|4[5-9]|5[0-35-9]|6[2567]|7[0-8]|8[0-9]|9[0-35-9])\d{8}$');
    return regExp.hasMatch(number) && number.length == 11;
  }

  /// 简单验证国际手机号
  static bool _isInternationalPhoneNumber(String number) {
    // 国际手机号：至少8位，最多15位
    return number.length >= 8 && number.length <= 15;
  }

  /// 获取手机号运营商信息
  static String? getOperator(String phoneNumber) {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (!_isChinesePhoneNumber(cleanedNumber)) return null;

    final prefix = cleanedNumber.substring(0, 3);

    // 运营商号段映射
    const operators = {
      '133': '中国电信', '149': '中国电信', '153': '中国电信',
      '173': '中国电信', '177': '中国电信', '180': '中国电信',
      '181': '中国电信', '189': '中国电信', '199': '中国电信',
      '134': '中国移动', '135': '中国移动', '136': '中国移动',
      '137': '中国移动', '138': '中国移动', '139': '中国移动',
      '147': '中国移动', '148': '中国移动', '150': '中国移动',
      '151': '中国移动', '152': '中国移动', '157': '中国移动',
      '158': '中国移动', '159': '中国移动', '172': '中国移动',
      '178': '中国移动', '182': '中国移动', '183': '中国移动',
      '184': '中国移动', '187': '中国移动', '188': '中国移动',
      '198': '中国移动',
      '130': '中国联通', '131': '中国联通', '132': '中国联通',
      '145': '中国联通', '146': '中国联通', '155': '中国联通',
      '156': '中国联通', '166': '中国联通', '171': '中国联通',
      '175': '中国联通', '176': '中国联通', '185': '中国联通',
      '186': '中国联通',
    };

    return operators[prefix];
  }

  /// 格式化手机号（3-4-4格式）
  static String format(String phoneNumber) {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedNumber.length != 11) return phoneNumber;

    return '${cleanedNumber.substring(0, 3)} '
        '${cleanedNumber.substring(3, 7)} '
        '${cleanedNumber.substring(7)}';
  }
}