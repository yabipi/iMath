
class FormatUtil {

  ///数字转成Int
  ///[number] 可以是String 可以是int 可以是double 出错了就返回0;
  static num2int(number) {
    try {
      if (number is String) {
        return int.parse(number);
      } else if (number is int) {
        return number;
      } else if (number is double) {
        return number.toInt();
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  ///数字转成double
  ///[number] 可以是String 可以是int 可以是double 出错了就返回0;
  static num2double(number) {
    try {
      if (number is String) {
        return double.parse(number);
      } else if (number is int) {
        return number.toDouble();
      } else if (number is double) {
        return number;
      } else {
        return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

}