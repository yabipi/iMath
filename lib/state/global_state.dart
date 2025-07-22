
class GlobalState{
  static final _state = Map<String, dynamic>();

  // 设置键值对
  static void set(String key, dynamic value) {
    _state[key] = value;
  }

  // 获取键值对
  static dynamic get(String key) {
    return _state[key];
  }

  // 删除键值对
  static void remove(String key) {
    _state.remove(key);
  }
}