import 'package:chatgptbot/popups/add_data_to_model.dart';
import 'package:chatgptbot/popups/modify_response.dart';
import 'package:chatgptbot/utils/api_services.dart';
import 'package:chatgptbot/widgets/add_response_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatgptbot/models/message.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Message> msgs = [];
  List<bool> isThumbsUpClickedList = [];
  bool isTyping = false;
  // bool isThumbsUpClicked = false;
  // bool isResponseRecorded = false;
  String text = '';
  FocusNode nodeOne = FocusNode();

  @override
  void initState() {
    super.initState();
    if (msgs.isNotEmpty) {
      isThumbsUpClickedList = List.generate(msgs.length, (index) => msgs[index].isThumbsUpClicked);
    }
  }

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
                    if (isThumbsUpClickedList.length <= index) {
                      isThumbsUpClickedList.add(false);
                    }
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
                          if (!message.isSender/* && index == 0*/)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 5),
                              child: /*isResponseRecorded
                                  ? const Text(
                                "התגובה שלך מוקלטת",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w200),
                              )
                                  : */Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "האם התגובה הזו עזרה?",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w200),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: "תגובה טובה",
                                        iconSize: 16,
                                        icon: message.isThumbsUpClicked/*isThumbsUpClicked*/ ? const Icon(Icons.thumb_up) : const Icon(Icons.thumb_up_alt_outlined),
                                        color: Colors.black,
                                        onPressed: () async {
                                          setState(() {
                                            message.isThumbsUpClicked = !message.isThumbsUpClicked;
                                            // isThumbsUpClicked = true;
                                          });
                                          // Determine the question and answer based on whether the message is from the sender or not
                                          String question = msgs[index+1].msg;
                                          String answer = message.isSender ? text : message.msg;

                                          if (message.isThumbsUpClicked) {
                                            await saveResponseToFirestore(question, answer);
                                          }
                                          else {
                                            // Remove the thumbs-up reaction from Firestore
                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                            String? threadId = prefs.getString('thread_id');
                                            await FirebaseFirestore.instance.collection('responses')
                                                .doc(threadId)
                                                .collection('thumbs_up_responses')
                                                .where('question', isEqualTo: question)
                                                .where('answer', isEqualTo: answer)
                                                .get().then((querySnapshot) {
                                                for (var doc in querySnapshot.docs) {
                                                  doc.reference.delete(); // Delete the document
                                                }
                                              });
                                            }
                                          // saveResponseToFirestore(text, msgs[index].msg);
                                        },
                                      ),
                                      IconButton(
                                        tooltip: "שנה תגובה",
                                        iconSize: 16,
                                        icon: const Icon(Icons.tune),
                                        color: Colors.black,
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ModifyResponsePopup(
                                                question: msgs[index+1].msg,
                                                response: msgs[index].msg,
                                                onSave: (modifiedAnswer) {
                                                  setState(() {
                                                    msgs[index].msg = modifiedAnswer;
                                                  });
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
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
                    setState(() {
                      // isThumbsUpClicked = false;
                      // isResponseRecorded = false;
                    });
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
                          enabled: !isTyping,
                          autofocus: true,
                          focusNode: nodeOne,
                          cursorColor: Colors.lightBlue,
                          textCapitalization: TextCapitalization.sentences,
                          textAlign: TextAlign.right,
                          onSubmitted: (value) {
                            !isTyping ? sendMsg() : null;
                          },
                          textInputAction: isTyping? TextInputAction.none : TextInputAction.send,
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
    text = controller.text;

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
          await requestCreateThread().then((value) async {
            if(value != null && value.status == true && value.code == 1){
              threadId = value.data.threadId;
              await prefs.setString('thread_id', threadId!);
              print("Thread Id: $threadId");
            }
          });
        }

        if (threadId != null) {
          requestChat(threadId!, text).then((value) {
            if (value != null && value.status == true && value.code == 1) {
              // var message = value.data[0].text.value;
              for(var message in value.data) {
                setState(() {
                  isTyping = false;
                  msgs.insert(
                    0,
                    Message(
                      false,
                      message.text.value
                    ),
                  );
                });
                scrollController.animateTo(0.0, duration: const Duration(seconds: 1), curve: Curves.easeOut);
                saveMessagesToFirestore(text, message.text.value);
              }
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("aקרתה תקלה נסה שוב"),
                )
              );
              setState(() {
                isTyping = false;
              });
            }
          });
        }
        FocusScope.of(context).requestFocus(nodeOne);
      }
    } on Exception catch (e) {
      setState(() {
        isTyping = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: ${e.toString()}"),
      ));
    }
  }

  Future<void> saveMessagesToFirestore(String question, String answer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? threadId = prefs.getString('thread_id');

    if (threadId != null) {
      // Reference to the document with the thread ID
      DocumentReference docRef = FirebaseFirestore.instance.collection('responses').doc(threadId);

      // Check if the document exists
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document with the thread ID exists, append new data to the existing collection
        await docRef.collection('all_messages').add({
          'question': question,
          'answer': answer,
          'timestamp': FieldValue.serverTimestamp(),
        }).then((_) {
          print('Data appended to Firestore');
        }).catchError((error) {
          print('Error appending data: $error');
        });
      }
      else {
        // Document with the thread ID doesn't exist, create a new one
        await docRef.set({
          ' ': "",
        }).then((_) async {
          // Add the first response to the newly created document
          await docRef.collection('all_messages').add({
            'question': question,
            'answer': answer,
            'timestamp': FieldValue.serverTimestamp(),
          });
          print('Document created in Firestore with initial response');
        }).catchError((error) {
          print('Error creating document: $error');
        });
      }
    }
    else {
      print('Thread ID is null');
    }
    FocusScope.of(context).requestFocus(nodeOne);
  }

  Future<void> saveResponseToFirestore(String question, String answer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? threadId = prefs.getString('thread_id');

    if (threadId != null) {
      // Reference to the document with the thread ID
      DocumentReference docRef = FirebaseFirestore.instance.collection('responses').doc(threadId);

      // Check if the document exists
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document with the thread ID exists, append new data to the existing collection
        await docRef.collection('thumbs_up_responses').add({
          'question': question,
          'answer': answer,
          'reactionType': 'THUMBS UP',
          'timestamp': FieldValue.serverTimestamp(),
        }).then((_) {
          print('Data appended to Firestore');
          // setState(() {
          //   isResponseRecorded = true;
          // });
        }).catchError((error) {
          print('Error appending data: $error');
        });
      }
      else {
        // Document with the thread ID doesn't exist, create a new one
        await docRef.set({
          ' ': "",
        }).then((_) async {
          // Add the first response to the newly created document
          await docRef.collection('thumbs_up_responses').add({
            'question': question,
            'answer': answer,
            'reactionType': 'THUMBS UP',
            'timestamp': FieldValue.serverTimestamp(),
          });
          print('Document created in Firestore with initial response');
          // setState(() {
          //   isResponseRecorded = true;
          // });
        }).catchError((error) {
          print('Error creating document: $error');
        });
      }
    }
    else {
      print('Thread ID is null');
    }
    FocusScope.of(context).requestFocus(nodeOne);
  }

}
