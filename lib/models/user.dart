class User {
  final String id;
  final String name;
  final String? avatar;
  final String? phone;
  final String? wechatId;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    this.avatar,
    this.phone,
    this.wechatId,
    this.createdAt,
  });

  // 从JSON创建用户对象
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      phone: json['phone'],
      wechatId: json['wechatId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'phone': phone,
      'wechatId': wechatId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
} 