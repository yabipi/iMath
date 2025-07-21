
class DataUtils {
  // 方案1：使用泛型约束
  static List<T> dataAsList<T>(dynamic data, T Function(Map<String, dynamic> json) fromJson) {
    final content = data ?? [];
    final items = content.map((json) {
      try {
        T obj = fromJson.call(json as Map<String, dynamic>);
        return obj;
      } catch (e) {
        return null;
      }
    }).whereType<T>().toList();
    return items;
  }
}

