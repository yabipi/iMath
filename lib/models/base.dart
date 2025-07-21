// 定义一个接口，要求所有可序列化的类型都实现 fromJson 方法
abstract class JsonSerializable<T> {

  factory JsonSerializable.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('子类必须实现 fromJson 方法');
  }
}