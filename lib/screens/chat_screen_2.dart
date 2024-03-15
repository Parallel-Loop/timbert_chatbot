import 'dart:convert';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
// import 'package:chatgptbot/bloc/chat_bloc/chat_bloc.dart';
import 'package:chatgptbot/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:jumping_dot/jumping_dot.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatScreen2 extends StatefulWidget {
  const ChatScreen2({super.key});

  @override
  State<ChatScreen2> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen2> {
  // late ChatBloc _chatBloc;

  // @override
  // void initState() {
  //   super.initState();
  //   _chatBloc = BlocProvider.of<ChatBloc>(context);
  // }

  // @override
  // void dispose() {
  //   _chatBloc.close();
  //   super.dispose();
  // }

  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode textFieldFocus = FocusNode();
  List<Message> msgs = [];
  bool isTyping = false;

  void sendMsg() async {
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
            duration: const Duration(seconds: 1), curve: Curves.easeOut);
        if(threadId == null) {
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
            threadId = decodedResponse['id'];
            await prefs.setString('thread_id', threadId!);
          }
          print("Thread Id: $threadId");
        }

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
          print("Message sent successfully!");

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
            print("Assistant run successfully!");

            var decodedResponse = json.decode(runsResponse.body);
            String runId = decodedResponse['id'];

            var checkRun = await http.get(
              Uri.parse("https://api.openai.com/v1/threads/$threadId/runs/$runId"),
              headers: {
                "Authorization": "Bearer $apiKey",
                "OpenAI-Beta": "assistants=v1"
              },
            );
            if(checkRun.statusCode == 200) {
              print("Check run successfully!");

              var showMessageResponse = await http.get(
                Uri.parse("https://api.openai.com/v1/threads/$threadId/messages"),
                headers: {
                  "Authorization": "Bearer $apiKey",
                  "Content-Type": "application/json",
                  "OpenAI-Beta": "assistants=v1"
                },
              );

              if (showMessageResponse.statusCode == 200) {
                print("Show Message API call success!");

                var decodedResponse = utf8.decode(showMessageResponse.bodyBytes);
                var json = jsonDecode(decodedResponse);

                var role = json['data'][0]['role'];

                if(json != null && role == 'assistant') {
                  print("coming data ${ json['data'][0]['content'][0]['text']['value'].toString()}");
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
                  print("Failed to fetch message: ${messagesResponse.body}");
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
            else {
              print("Run is not working: ${runsResponse.body}");
            }
          }
          else {
            print("Failed to run assistant: ${runsResponse.body}");
          }
        }
        else {
          print("Failed to send message: ${messagesResponse.body}");
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("שליחת ההודעה נכשלה"),
              )
          );
        }
      }
    } on Exception {
      setState(() {
        isTyping = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("!אירעה שגיאה"),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ברט בוט"),/*AppLocalizations.of(context)!.title*/
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.language),
        //     tooltip: AppLocalizations.of(context)!.languageToolTip,
        //     onPressed: () {
        //       _chatBloc.add(ChangeLanguageEvent(
        //         AppLocalizations.of(context)!.localeName == 'en'
        //             ? const Locale('he')
        //             : const Locale('en'),
        //       ));
        //     },
        //   ),
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.33, right: MediaQuery.of(context).size.width * 0.33,
            bottom: MediaQuery.of(context).size.height * 0.05
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
                  // image: const DecorationImage(
                  //   image: AssetImage('assets/images.jpeg'),
                  //   fit: BoxFit.cover,
                  // ),
                  color: Colors.black12,
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: msgs.length,
                  shrinkWrap: true,
                  reverse: true,
                  itemBuilder: (context, index) {
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
                                maxWidth: MediaQuery.of(context).size.width * 0.3
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
                          : BubbleNormal(
                        text: msgs[index].msg,
                        isSender: msgs[index].isSender,
                        color: msgs[index].isSender
                            ? Colors.blue.shade100
                            : Colors.grey.shade200,
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.3
                        ),
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
                    if(isTyping == false){
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
                    padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
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
                          focusNode: textFieldFocus,
                          cursorColor: Colors.lightBlue,
                          textCapitalization: TextCapitalization.sentences,
                          textAlign: TextAlign.right,
                          onSubmitted: (value) {
                            sendMsg();
                            setState(() {
                              textFieldFocus.requestFocus();
                            });
                          },
                          textInputAction: TextInputAction.send,
                          showCursor: !isTyping,
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
}
