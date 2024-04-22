class CreateThreadRequest {
  CreateThreadRequest({
    required this.code,
    required this.message,
    required this.data,
    required this.status,
  });
  late final int code;
  late final String message;
  late final ThreadData data;
  late final bool status;

  CreateThreadRequest.fromJson(Map<String, dynamic> json){
    code = json['code'];
    message = json['message'];
    data = ThreadData.fromJson(json['data']);
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['code'] = code;
    _data['message'] = message;
    _data['data'] = data.toJson();
    _data['status'] = status;
    return _data;
  }
}

class ThreadData {
  ThreadData({
    required this.message,
    required this.threadId,
  });
  late final String message;
  late final String threadId;

  ThreadData.fromJson(Map<String, dynamic> json){
    message = json['message'];
    threadId = json['threadId'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['message'] = message;
    _data['threadId'] = threadId;
    return _data;
  }
}