import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddDataPopup extends StatefulWidget {
  const AddDataPopup({super.key});

  @override
  State<AddDataPopup> createState() => _AddDataPopupState();
}

class _AddDataPopupState extends State<AddDataPopup> {

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  bool consecutiveNewlines = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text(
          'הוסף נתונים',
          style: TextStyle(color: Colors.white),
        )
      ),
      backgroundColor: Colors.black,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
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
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: _questionController,
                    onChanged: (value) {
                      _questionController.text = value;

                      // Handle newline behavior:
                      if (value.startsWith('\n')) {
                        // Prevent new line at the start
                        value = value.substring(1);
                        _questionController.text = value;
                        _questionController.selection = TextSelection.fromPosition(
                          TextPosition(offset: value.length),
                        );
                      }
                      else if (value.endsWith('\n\n\n')) {
                        consecutiveNewlines = true;
                        if (consecutiveNewlines) {
                          // Prevent moving to the next line for the third and subsequent newlines
                          value = value.substring(0, value.length - 1);
                          _questionController.text = value;
                          _questionController.selection = TextSelection.fromPosition(
                            TextPosition(offset: value.length),
                          );
                        }
                        else {
                          consecutiveNewlines = false;
                        }
                      }
                      else {
                        consecutiveNewlines = false;
                      }
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "כתבו כאן שאלה",
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
          Padding(
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
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
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
                          consecutiveNewlines = false;
                        }
                      }
                      else {
                        consecutiveNewlines = false;
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
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            saveDataToFirestore(_questionController.text, _answerController.text);
            // Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.lightBlue,
          ),
          child: const Text('הוסף נתונים'),
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

  void saveDataToFirestore(String question, String answer) {
    FirebaseFirestore.instance.collection('add_new_pair').add({
      'question': question,
      'answer': answer,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((value) {
      print('Response saved to Firestore');
      Navigator.of(context).pop();
    }).catchError((error) {
      print('Error saving response: $error');
    });
  }
}
