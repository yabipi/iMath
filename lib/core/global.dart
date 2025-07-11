class Global {
  // 私有构造函数，防止外部实例化
  // Context._internal();

  // 静态变量保存唯一的实例
  // static final Context _instance = Context._internal();

  // 工厂方法返回唯一的实例
  // factory Context() => _instance;

  static final Map<String, dynamic> _data = {};

  // 设置键值对
  static void set(String key, dynamic value) {
    _data[key] = value;
  }

  // 获取键值对
  static dynamic get(String key) {
    return _data[key];
  }

  // 删除键值对
  static void remove(String key) {
    _data.remove(key);
  }

}