import 'dart:convert';
import 'dart:io';

import 'package:chatgptbot/widgets/export_data.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class AddNewPairTab extends StatelessWidget {
  const AddNewPairTab({super.key});

  void copyToClipboard(String message) {
    Clipboard.setData(ClipboardData(text: message));
    Fluttertoast.showToast(
      msg: "הנתונים הועתקו ללוח",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
      webPosition: "center"
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ExportDataButton(
              icon: Icons.download,
              onPressed: () {
                showMenu<String>(
                  context: context,
                  position: const RelativeRect.fromLTRB(0, 110, 0, 0),
                  items: <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Export as Documents',
                      child: Text('ייצא כמסמך'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Export as Excel',
                      child: Text('ייצא כאקסל'),
                    ),
                  ],
                ).then((value) async {
                  if (value == 'Export as Documents') {
                    var data = await fetchAllData();
                    exportToWordDocument(data);
                  }
                  else if (value == 'Export as Excel') {
                    var data = await fetchAllData();
                    exportToExcel(data);
                  }
                });
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('add_new_pair')
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
          List<Widget> messageWidgets = [];
          DateTime? lastDate;

          for (var document in snapshot.data!.docs) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            Timestamp timestamp = data['timestamp'] as Timestamp;
            DateTime dateTime = timestamp.toDate();
            DateTime messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

            if (lastDate == null || lastDate != messageDate) {
              messageWidgets.add(
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat.yMMMMd('en_US').format(dateTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
              lastDate = messageDate;
            }
            String formattedTime = DateFormat("h:mm").format(dateTime);
            String formattedTimeZone = DateFormat("a").format(dateTime);
            messageWidgets.add(
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'שְׁאֵלָה: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${data['question']}',
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'תשובה: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${data['answer']}',
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          tooltip: "עותק",
                          icon: const Icon(Icons.content_copy),
                          onPressed: () {
                            String messagePair = '${data['question']}\n\n${data['answer']}';
                            copyToClipboard(messagePair);
                          },
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "$formattedTimeZone ",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    formattedTime,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    )
                  ],
                ),
              ),
            );
          }
          return ListView(
            children: messageWidgets,
          );
        },
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> fetchAllData() async {
  // Fetch data from Fire Store
  List<Map<String, dynamic>> allData = [];

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('add_new_pair')
      .orderBy('timestamp', descending: true)
      .get();

  for (var doc in querySnapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    allData.add(data);
  }
  return allData;
}

Future<void> exportToPdf(List<Map<String, dynamic>> data) async {
  final pdf = pw.Document();

  // Load Hebrew font
  final ttf = await rootBundle.load("assets/arial-hebrew.ttf");
  final pw.Font customFont = pw.Font.ttf(ttf.buffer.asByteData());

  for (var message in data) {
    final timestamp = message['timestamp'].toDate();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Date: ${DateFormat.yMMMMd('en_US').format(timestamp)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            '${message['question']}\n',
                            style: pw.TextStyle(
                              font: customFont,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.justify,
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            '${message['answer']}\n',
                            style: pw.TextStyle(
                              font: customFont,
                            ),
                            textAlign: pw.TextAlign.justify,
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Time: ${DateFormat("h:mm a").format(timestamp)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Save PDF to downloads directory
  if (!kIsWeb) {
    final String dir = (await getDownloadsDirectory())!.path;
    const String path = 'New_Pair.pdf';
    final File file = File('$dir/$path');
    await file.writeAsBytes(await pdf.save());

    // Open PDF
    OpenFile.open(file.path);
  } else {
    // Generate PDF data
    final Uint8List pdfBytes = await pdf.save();

    // Create a blob
    final blob = html.Blob([pdfBytes]);

    // Create object url
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create anchor element
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'New_Pair.pdf')
      ..click();

    // Revoke the object url
    html.Url.revokeObjectUrl(url);
  }
}

Future<void> exportToExcel(List<Map<String, dynamic>> data) async {
  // Create an Excel workbook
  var excel = Excel.createExcel();

  // Create a sheet in the workbook
  var sheet = excel['Sheet1'];

  // declaring a cellStyle object
  CellStyle headingCellStyle = CellStyle(
      bold: true,
      italic: false,
      textWrapping: TextWrapping.WrapText,
      fontFamily: getFontFamily(FontFamily.Comic_Sans_MS),
      rotation: 0,
      verticalAlign: VerticalAlign.Center,
      horizontalAlign: HorizontalAlign.Center
  );

  var cell1 = sheet.cell(CellIndex.indexByString("A1"));
  cell1.value = const TextCellValue("Date");
  cell1.cellStyle = headingCellStyle;

  var cell2 = sheet.cell(CellIndex.indexByString("B1"));
  cell2.value = const TextCellValue("Question");
  cell2.cellStyle = headingCellStyle;

  var cell3 = sheet.cell(CellIndex.indexByString("C1"));
  cell3.value = const TextCellValue("Answer");
  cell3.cellStyle = headingCellStyle;

  var cell4 = sheet.cell(CellIndex.indexByString("D1"));
  cell4.value = const TextCellValue("Time");
  cell4.cellStyle = headingCellStyle;

  // Add data to the sheet
  for (var message in data) {
    final timestamp = message['timestamp'].toDate();
    sheet.appendRow([
      TextCellValue(DateFormat.yMMMMd('en_US').format(timestamp)),
      TextCellValue(message['question']),
      TextCellValue(message['answer']),
      TextCellValue(DateFormat("h:mm a").format(timestamp)),
    ]);
  }

  // Save Excel file
  if (!kIsWeb) {
    final String dir = (await getDownloadsDirectory())!.path;
    const String path = 'New_Pair.xlsx';
    final File file = File('$dir/$path');
    await file.writeAsBytes(excel.encode()!);

    // Open Excel file
    OpenFile.open(file.path);
  } else {
    // Convert Excel data to bytes
    final List<int> excelBytes = excel.encode()!;

    // Create a blob
    final blob = html.Blob([Uint8List.fromList(excelBytes)], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

    // Create object URL
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create anchor element
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'New_Pair.xlsx')
      ..click();

    // Revoke the object URL
    html.Url.revokeObjectUrl(url);
  }
}

Future<void> exportToWordDocument(List<Map<String, dynamic>> data) async {
  // Prepare data as HTML
  String documentContent = '<html><head><meta charset="utf-8"><style>'
      'p { text-align: left; }'
      '.date { text-align: center; font-weight: bold; }'
      '.question { text-align: right; }'
      '.answer { text-align: right; }'
      '.time { text-align: left; font-weight: bold; }'
      '</style></head><body>';

  for (var message in data) {
    final timestamp = message['timestamp'].toDate();
    documentContent += '<p class="date">${DateFormat.yMMMMd('en_US').format(timestamp)}</p>'
        '<p class="question">${message['question']}</p>'
        '<p class="answer">${message['answer']}</p>'
        '<p class="time">${DateFormat("h:mm a").format(timestamp)}</p><br>';
  }

  documentContent += '</body></html>';

  // Convert document content to bytes
  List<int> documentBytes = utf8.encode(documentContent);

  // Create data URI for the Word document
  final dataUri = 'data:application/vnd.openxmlformats-officedocument.wordprocessingml.document;base64,${base64Encode(documentBytes)}';

  // Create a temporary anchor element
  final anchor = html.AnchorElement(href: dataUri)
    ..setAttribute('download', 'New_Pair.doc');

  // Append the anchor element to the document body
  html.document.body?.append(anchor);

  // Simulate a click on the anchor to trigger the download
  anchor.click();

  // Remove the anchor from the document body
  anchor.remove();
}
