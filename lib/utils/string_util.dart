class StringUtil {
  /// 返回第一个不为空且长度大于0的字符串参数
  ///
  /// [args] 不定长的String参数列表
  /// 返回第一个非空且长度大于0的字符串，如果没有则返回空字符串
  static String _firstNonEmptyString(List<String?> args) {
    for (var arg in args) {
      if (arg != null && arg.isNotEmpty) {
        return arg;
      }
    }
    return '';
  }

  /// 另一种实现方式：使用可变参数
  ///
  /// [args] 不定长的String参数
  /// 返回第一个非空且长度大于0的字符串，如果没有则返回空字符串
  static String firstNonEmptyString(String? first,
      [List<String?> args = const []]) {
    if (first != null && first.isNotEmpty) {
      return first;
    }

    for (var arg in args) {
      if (arg != null && arg.isNotEmpty) {
        return arg;
      }
    }
    return '';
  }

  
  /**
   * 检查手机号格式是否正确
   *
   * 合法的手机号需要满足以下条件：
   * 1. 长度为11位
   * 2. 以1开头
   * 3. 第二位为3、4、5、6、7、8、9中的一个
   * 4. 全部由数字组成
   */
  static bool checkPhoneNumberValid(String phone) {
    // 检查是否为空
    if (phone.isEmpty) {
      return false;
    }

    // 检查长度是否为11位
    if (phone.length != 11) {
      return false;
    }

    // 检查是否全部为数字
    final RegExp digitRegExp = RegExp(r'^\d+$');
    if (!digitRegExp.hasMatch(phone)) {
      return false;
    }

    // 检查是否以1开头
    if (phone[0] != '1') {
      return false;
    }

    // 检查第二位数字是否为合法的运营商号段
    final String secondDigit = phone[1];
    const Set<String> validSecondDigits = {'3', '4', '5', '6', '7', '8', '9'};
    if (!validSecondDigits.contains(secondDigit)) {
      return false;
    }

    return true;

  }

}