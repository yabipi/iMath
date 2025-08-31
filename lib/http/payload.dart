class ResponseData {
  int code;
  String msg;
  Map<String, dynamic>? payload;

  ResponseData({required this.code, required this.msg, this.payload});

  ResponseData.fromJson(Map<String, dynamic> json):
    code = json['code'] ?? 0,
    msg = json['msg'] ?? '',
    payload = json['payload'];

}