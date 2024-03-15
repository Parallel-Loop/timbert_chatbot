import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModifyResponsePopup extends StatefulWidget {

  final String question, response;
  final VoidCallback onSave;
  const ModifyResponsePopup({super.key, required this.question, required this.response, required this.onSave});

  @override
  State<ModifyResponsePopup> createState() => _ModifyResponsePopupState();
}

class _ModifyResponsePopupState extends State<ModifyResponsePopup> {

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  late String actualResponse;
  bool consecutiveNewlines = false;

  @override
  void initState() {
    super.initState();
    _questionController.text = widget.question;
    actualResponse = widget.response;
    _answerController.text = widget.response;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text(
          'שנה תגובה',
          style: TextStyle(color: Colors.white),
        )
      ),
      backgroundColor: Colors.black,
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10)
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.29,
              maxWidth: MediaQuery.of(context).size.width * 0.29,
              minHeight: MediaQuery.of(context).size.height * 0.1,
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _answerController,
                onChanged: (value) {
                  _answerController.text = value;

                  // Handle newline behavior:
                  if (value.startsWith('\n')) {
                    // Prevent new line at the start
                    value = value.substring(1);
                    _answerController.text = value;
                    _answerController.selection = TextSelection.fromPosition(
                      TextPosition(offset: value.length),
                    );
                  }
                  else if (value.endsWith('\n\n\n')) {
                    consecutiveNewlines = true;
                    if (consecutiveNewlines) {
                      // Prevent moving to the next line for the third and subsequent newlines
                      value = value.substring(0, value.length - 1);
                      _answerController.text = value;
                      _answerController.selection = TextSelection.fromPosition(
                        TextPosition(offset: value.length),
                      );
                    }
                    else {
                      consecutiveNewlines = false; // Reset counter after two newlines
                    }
                  }
                  else {
                    consecutiveNewlines = false; // Reset counter if not a newline
                  }
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "כתוב תשובה כאן",
                  counterText: '',
                ),
                enabled: true,
                autofocus: true,
                cursorColor: Colors.lightBlue,
                textCapitalization: TextCapitalization.sentences,
                textAlign: TextAlign.right,
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            saveResponseToFirestore(_questionController.text , _answerController.text);
            // widget.onSave();
            // Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.lightBlue,
          ),
          child: const Text('שמור תגובה'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.lightBlue,
          ),
          child: const Text('חזור'),
        ),
      ],
    );
  }

  Future<void> saveResponseToFirestore(String question, String modifiedAnswer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? threadId = prefs.getString('thread_id');

    if (threadId != null) {
      // Reference to the document with the thread ID
      DocumentReference docRef = FirebaseFirestore.instance.collection('responses').doc(threadId);

      // Check if the document exists
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document with the thread ID exists, append new data to the existing collection
        await docRef.collection('edit_responses').add({
          'question': question,
          'actual_answer': actualResponse,
          'modified_answer': modifiedAnswer,
          'reactionType': 'EDIT REQUEST',
          'timestamp': FieldValue.serverTimestamp(),
        }).then((_) {
          print('Data appended to Firestore');
          widget.onSave();
          Navigator.of(context).pop();
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
          await docRef.collection('edit_responses').add({
            'question': question,
            'actual_answer': actualResponse,
            'modified_answer': modifiedAnswer,
            'reactionType': 'EDIT REQUEST',
            'timestamp': FieldValue.serverTimestamp(),
          });
          print('Document created in Firestore with initial response');
          widget.onSave();
          Navigator.of(context).pop();
        }).catchError((error) {
          print('Error creating document: $error');
        });
      }
    }
    else {
      print('Thread ID is null');
    }
  }

}
