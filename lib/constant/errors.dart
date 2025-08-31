const SUCCESS = 200;
const FAILED = 500;

enum Errors {
  /// 令牌过期
  TOKEN_EXPIRED(10003),

  /// 令牌创建失败
  TOKEN_CREATE_ERROR(10004),

  /// 参数错误
  PARAMS_ERROR(10005),

  /// 未授权
  UNAUTHORIZED(10006),

  /// 禁止访问
  FORBIDDEN(10007),

  /// 内部错误
  INTERNAL_ERROR(10008),

  /// 未找到
  NOT_FOUND(10009),

  /// 新用户
  NEW_USER(20000),

  /// 手机号已注册
  PHONE_REGISTERED(20001),

  /// 用户名已存在
  USERNAME_ALREADY_EXISTS(20002),

  /// 用户不存在
  USER_NOT_FOUND(20003),

  /// 密码错误
  PASSWORD_ERROR(20004),

  /// 手机号未注册
  PHONE_NOT_REGISTERED(20005);

  final int code;
  const Errors(this.code);

}
