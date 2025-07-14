class User {
  String? login;
  int? id;
  final String username;
  String? avatar;
  final String? phone;
  final String? wechatId;
  final DateTime? createdAt;

  User({
    required this.username,
    this.id,
    this.login,
    this.avatar,
    this.phone,
    this.wechatId,
    this.createdAt,
  });

  // 从JSON创建用户对象
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      avatar: json['avatar'],
      phone: json['phone'],
      // wechatId: json['wechatId'],
      // createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': username,
      'avatar': avatar,
      'phone': phone,
      'wechatId': wechatId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
} 