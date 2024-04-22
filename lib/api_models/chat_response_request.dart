class ChatResponse {
  ChatResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.status,
  });
  late final int code;
  late final String message;
  late final List<ResponseData> data;
  late final bool status;

  ChatResponse.fromJson(Map<String, dynamic> json){
    code = json['code'];
    message = json['message'];
    data = List.from(json['data']).map((e)=>ResponseData.fromJson(e)).toList();
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['code'] = code;
    _data['message'] = message;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    _data['status'] = status;
    return _data;
  }
}

class ResponseData {
  ResponseData({
    required this.type,
    required this.text,
    this.error
  });
  late final String type;
  late final ResponseValue text;
  late final String? error;

  ResponseData.fromJson(Map<String, dynamic> json){
    type = json['type'];
    text = ResponseValue.fromJson(json['text']);
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['type'] = type;
    _data['text'] = text.toJson();
    _data['error'] = error;
    return _data;
  }
}

class ResponseValue {
  ResponseValue({
    required this.value,
    required this.annotations,
  });
  late final String value;
  late final List<dynamic> annotations;

  ResponseValue.fromJson(Map<String, dynamic> json){
    value = json['value'];
    annotations = List.castFrom<dynamic, dynamic>(json['annotations']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['value'] = value;
    _data['annotations'] = annotations;
    return _data;
  }
}