import 'dart:developer';
import 'dart:io';

import 'package:chatgptbot/api_models/chat_response_request.dart';
import 'package:chatgptbot/api_models/create_thread_request.dart';
import 'package:chatgptbot/utils/app_global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

AppGlobal appGlobal = AppGlobal();

//------------------------------- Create Thread -------------------------------
Future<CreateThreadRequest?> requestCreateThread() async {

  CreateThreadRequest? result;
  try{
    final url = Uri.parse('${AppGlobal.baseUrl}createThread');
    final response = await http.post(
      url,
      body: jsonEncode({}),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);
      result = CreateThreadRequest.fromJson(responseData);
    }
    else {
      print('Creating Thread failed with status code: ${response.statusCode}');
      result = CreateThreadRequest(status: false, message: 'Internet Error', code: 0, data: ThreadData(message: '', threadId: ''));
    }
  }
  catch (e) {
    log(e.toString());
  }
  return result;
}

//----------------------------------- Login -----------------------------------
Future<ChatResponse?> requestChat(String threadId, String message) async {

  ChatResponse? result;
  try{
    final url = Uri.parse('${AppGlobal.baseUrl}sendMessageInThread');
    final response = await http.post(
      url,
      body: jsonEncode({'threadId': threadId, 'prompt': message}),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);
      result = ChatResponse.fromJson(responseData);
    }
    else {
      print('Getting response failed with status code: ${response.statusCode}');
      result = ChatResponse(status: false, message: 'Internet Error', code: 0, data: [ResponseData(type: '', text: ResponseValue(value: '', annotations: []))]);
    }
  }
  catch (e) {
    log(e.toString());
  }
  return result;
}
