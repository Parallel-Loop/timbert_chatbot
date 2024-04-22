import 'dart:convert';
import 'package:chatgptbot/popups/add_data_to_model.dart';
import 'package:chatgptbot/widgets/add_response_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatgptbot/models/message.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';

class ChatScreen2 extends StatefulWidget {
  const ChatScreen2({Key? key}) : super(key: key);

  @override
  State<ChatScreen2> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen2> {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Message> msgs = [];
  bool isTyping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ברט בוט"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: AddResponseButton(
              icon: Icons.add,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AddDataPopup();
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.33,
          right: MediaQuery.of(context).size.width * 0.33,
          bottom: MediaQuery.of(context).size.height * 0.05,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: msgs.length,
                  shrinkWrap: true,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final message = msgs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: isTyping && index == 0
                          ? Column(
                        children: [
                          BubbleNormal(
                            text: msgs[0].msg,
                            isSender: true,
                            color: Colors.blue.shade100,
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.3,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.28),
                            child: JumpingDots(
                              color: Colors.lightBlue,
                            ),
                          ),
                        ],
                      )
                          : Column(
                        children: [
                          BubbleNormal(
                            text: msgs[index].msg,
                            isSender: msgs[index].isSender,
                            color: msgs[index].isSender
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.3,
                            ),
                          ),
                          if (!message.isSender)
                            Padding(
                              padding: const EdgeInsets.only(left: 16 ),
                              child: Row(
                                children: [
                                  IconButton(
                                    tooltip: "תגובה טובה",
                                    iconSize: 16,
                                    icon: const Icon(Icons.thumb_up_alt_outlined),
                                    color: Colors.black,
                                    onPressed: () {

                                    },
                                  ),
                                  IconButton(
                                    tooltip: "שנה תגובה",
                                    iconSize: 16,
                                    icon: const Icon(Icons.tune),
                                    color: Colors.black,
                                    onPressed: () {
                                      // showDialog(
                                      //   context: context,
                                      //   builder: (BuildContext context) {
                                      //     return ModifyResponsePopup(
                                      //       response: msgs[index].msg,
                                      //       onSave: () {
                                      //         setState(() {
                                      //           isResponseRecorded = true;
                                      //         });
                                      //       },
                                      //     );
                                      //   },
                                      // );
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                    );
                  },
                ),
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (isTyping == false) {
                      sendMsg();
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: !isTyping ? Colors.lightBlue : Colors.grey,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(180),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: controller,
                          enabled: true,
                          autofocus: true,
                          cursorColor: Colors.lightBlue,
                          textCapitalization: TextCapitalization.sentences,
                          textAlign: TextAlign.right,
                          onSubmitted: (value) {
                            sendMsg();
                          },
                          textInputAction: TextInputAction.send,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "הזן טקסט",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendMsg() async {
    String text = controller.text;
    String? apiKey = dotenv.env['apiKey'];
    String? modelId = dotenv.env['modelId'];

    controller.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? threadId = prefs.getString('thread_id');
    try {
      if (text.isNotEmpty) {
        setState(() {
          msgs.insert(0, Message(true, text));
          isTyping = true;
        });
        scrollController.animateTo(0.0,
            duration: const Duration(seconds: 1), curve: Curves.easeOut
        );
        if (threadId == null) {
          threadId = await createThread(apiKey!);
          await prefs.setString('thread_id', threadId);
          print("Thread Id: $threadId");
        }

        print("API Key: $apiKey");
        print("Thread ID: $threadId");
        print("Text: $text");
        String messageId = await sendMessage(apiKey!, threadId, text);

        if (messageId.isNotEmpty) {
          await Future.delayed(const Duration(seconds: 2));
          print("API Key: $apiKey");
          print("Assistant ID: $modelId");
          print("Thread ID: $threadId");
          String runId = await runAssistant(apiKey, modelId!, threadId);

          if (runId.isNotEmpty) {
            await Future.delayed(const Duration(seconds: 2));
            print("API Key: $apiKey");
            print("Thread ID: $threadId");
            print("Run ID: $runId");
            bool isMessageReceived = await checkAssistantMessage(apiKey, threadId, runId);

            if (isMessageReceived) {
              await Future.delayed(const Duration(seconds: 2));
              print("API Key: $apiKey");
              print("Thread ID: $threadId");
              await showMessage(apiKey, threadId);
            }
            else {
              print("Failed to receive assistant message.");
            }
          }
          else {
            print("Failed to run assistant.");
          }
        }
        else {
          print("Failed to send message.");
        }
      }
    } on Exception catch (e) {
      setState(() {
        isTyping = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        // content: Text(" :!אירעה שגיאה"),
        content: Text("Error: ${e.toString()}"),
      ));
    }
  }

  Future<String> createThread(String apiKey) async {
    var threadResponse = await http.post(
      Uri.parse("https://api.openai.com/v1/threads"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
        "OpenAI-Beta": "assistants=v1"
      },
      body: jsonEncode({}),
    );
    if (threadResponse.statusCode == 200) {
      var decodedResponse = json.decode(threadResponse.body);
      return decodedResponse['id'];
    }
    else {
      throw Exception("Failed to create thread.");
    }
  }

  Future<String> sendMessage(String apiKey, String? threadId, String text) async {
    var messagesResponse = await http.post(
      Uri.parse("https://api.openai.com/v1/threads/$threadId/messages"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
        "OpenAI-Beta": "assistants=v1"
      },
      body: jsonEncode({
        "role": "user",
        "content": text
      }),
    );

    if (messagesResponse.statusCode == 200) {
      var decodedResponse = json.decode(messagesResponse.body);
      return decodedResponse['id'];
    }
    else {
      throw Exception("Failed to send message.");
    }
  }

  Future<String> runAssistant(String apiKey, String modelId, String? threadId) async {
    var runsResponse = await http.post(
      Uri.parse("https://api.openai.com/v1/threads/$threadId/runs"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
        "OpenAI-Beta": "assistants=v1"
      },
      body: jsonEncode({
        "assistant_id": modelId,
        "instructions": ''
      }),
    );

    if (runsResponse.statusCode == 200) {
      var decodedResponse = json.decode(runsResponse.body);
      return decodedResponse['id'];
    }
    else {
      throw Exception("Failed to run assistant.");
    }
  }

  Future<bool> checkAssistantMessage(String apiKey, String? threadId, String runId) async {
    var checkRun = await http.get(
      Uri.parse("https://api.openai.com/v1/threads/$threadId/runs/$runId"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "OpenAI-Beta": "assistants=v1"
      },
    );

    if (checkRun.statusCode == 200) {
      return true;
    }
    else {
      return false;
    }
  }

  Future<void> showMessage(String apiKey, String? threadId) async {
    var showMessageResponse = await http.get(
      Uri.parse("https://api.openai.com/v1/threads/$threadId/messages"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
        "OpenAI-Beta": "assistants=v1"
      },
    );

    if (showMessageResponse.statusCode == 200) {
      var decodedResponse = utf8.decode(showMessageResponse.bodyBytes);
      var json = jsonDecode(decodedResponse);

      // print("Message: ${json['data'][0]['content'][0]['text']['value'].toString()}");
      var role = json['data'][0]['role'];
      var content = json['data'][0]['content'];

      // print("Content length $content");

      if (json != null && role == 'assistant' && content != null) {
        setState(() {
          isTyping = false;
          msgs.insert(
            0,
            Message(
              false,
              json['data'][0]['content'][0]['text']['value'].toString(),
            ),
          );
        });
        scrollController.animateTo(0.0,
            duration: const Duration(seconds: 1), curve: Curves.easeOut);
      }
      else {
        print("Failed to fetch message: ${showMessageResponse.body}");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("aקרתה תקלה נסה שוב"),
            )
        );
        setState(() {
          isTyping = false;
        });
      }
    }
    else {
      print("Failed to make additional API call: ${showMessageResponse.body}");
    }
  }
}
