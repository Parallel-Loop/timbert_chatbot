import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chatgptbot/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen3 extends StatefulWidget {
  const ChatScreen3({super.key});

  @override
  State<ChatScreen3> createState() => _ChatScreen3State();
}

class _ChatScreen3State extends State<ChatScreen3> {

  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode textFieldFocus = FocusNode();
  List<Message> msgs = [];
  bool isTyping = false;

  void sendMsg() async {
    String text = controller.text;
    String? apiKey = dotenv.env['apiKey'];
    String? modelId = dotenv.env['modelId'];

    String? threadId = "";
    String runId = "";
    String messageId = "";
    controller.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    threadId = prefs.getString('thread_id');
    try {
      if (text.isNotEmpty) {
        setState(() {
          msgs.insert(0, Message(true, text));
          isTyping = true;
        });
        scrollController.animateTo(0.0,
            duration: const Duration(seconds: 1), curve: Curves.easeOut);

        final openAI = OpenAI.instance.build(
            token: apiKey,
            baseOption: HttpSetup(
              receiveTimeout: const Duration(seconds: 20),
            ),
            enableLog: true
        );

        await Future.delayed(const Duration(seconds: 2));
        ///Create Thread
        await openAI.threads.createThread(request: ThreadRequest()).then((value) async {
          print(value.id);
          threadId = value.id;
          await prefs.setString('thread_id', threadId!);
        });

        await Future.delayed(const Duration(seconds: 2));
        ///Add Message to thread
        final messageRequest = CreateMessage(
          role: 'user',
          content: text,
        );
        await openAI.threads.messages.createMessage(
          threadId: threadId!,
          request: messageRequest,
        ).then((value) {
          messageId = value.id;
        });

        await Future.delayed(const Duration(seconds: 2));
        ///Run the Assistant
        final runAssistantRequest = CreateRun(assistantId: modelId!);
        await openAI.threads.runs.createRun(
            threadId: threadId!,
            request: runAssistantRequest
        ).then((value) {
          runId = value.id;
        });

        await Future.delayed(const Duration(seconds: 2));
        ///Check Run Assistant
        await openAI.threads.runs.retrieveRun(
            threadId: threadId!,
            runId: runId
        );

        await Future.delayed(const Duration(seconds: 2));
        ///Display the Assistant Response
        final assistantMessage = await openAI.threads.messages.retrieveMessage(
          threadId: threadId!,
          messageId: messageId,
        );

        await Future.delayed(const Duration(seconds: 2));
        print("Message: ${assistantMessage.content[0].text!.value}");
        setState(() {
          isTyping = false;
          msgs.insert(
            0,
            Message(
              false,
              assistantMessage.content[0].text!.value,
            ),
          );
        });
        scrollController.animateTo(0.0,
            duration: const Duration(seconds: 1), curve: Curves.easeOut);
      }
    } on Exception catch (e) {
      setState(() {
        isTyping = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // content: Text("!אירעה שגיאה"),
            content: Text("Error: ${e.toString()}"),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ברט בוט"),
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
