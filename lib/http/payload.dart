class ResponseData {
  int code;
  String msg;
  Map<String, dynamic> _data;

  ResponseData(
      {required this.code, required this.msg, Map<String, dynamic>? data})
      : _data = data ?? {};

  ResponseData.fromJson(Map<String, dynamic> json)
      : code = json['code'] ?? 0,
        msg = json['msg'] ?? '',
        _data = Map<String, dynamic>.from(json)
          ..remove('code')
          ..remove('msg');

  // 获取所有动态字段
  Map<String, dynamic> get data => Map.unmodifiable(_data);

  // 获取特定字段的值
  T? getValue<T>(String key) {
    return _data[key] as T?;
  }

  // 获取特定字段的值，带默认值
  T getValueOrDefault<T>(String key, T defaultValue) {
    return _data[key] as T? ?? defaultValue;
  }

  // 检查是否成功
  bool get isSuccess => code == 200 || code == 0;

  // 获取所有字段名
  List<String> get fieldNames => _data.keys.toList();

  // 检查是否包含特定字段
  bool hasField(String key) => _data.containsKey(key);

  // 安全地访问嵌套字段
  dynamic getNestedValue(List<String> keys) {
    dynamic current = _data;
    for (String key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  // 转换为JSON（用于调试或序列化）
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      ..._data,
    };
  }

  // 重写toString方法，方便调试
  @override
  String toString() {
    return 'ResponseData(code: $code, msg: $msg, data: $_data)';
  }
}
