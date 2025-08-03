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
  static String firstNonEmptyString(String? first, [List<String?> args = const []]) {
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
}