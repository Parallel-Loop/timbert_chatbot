import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditResponseTab extends StatelessWidget {
  const EditResponseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collectionGroup('edit_responses')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator()
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}')
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data() as Map<String, dynamic>;
              Timestamp timestamp = data['timestamp'] as Timestamp;
              DateTime dateTime = timestamp.toDate();
              String formattedDateTime =
              DateFormat("MMMM d, yyyy 'at' h:mm:ss a 'UTC'Z")
                  .format(dateTime);
              return ListTile(
                title: Text(data['question']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Actual Answer: ${data['actual_answer']}"),
                    Text("Modified Answer: ${data['modified_answer']}"),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(formattedDateTime)
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
