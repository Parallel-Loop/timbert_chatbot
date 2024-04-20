import 'package:chatgptbot/screens/Dashboard/add_new_pair_tab.dart';
import 'package:chatgptbot/screens/Dashboard/all_messages_tab.dart';
import 'package:chatgptbot/screens/Dashboard/edit_response_tab.dart';
import 'package:chatgptbot/screens/Dashboard/thumbs_up_tab.dart';
import 'package:chatgptbot/widgets/dashboard_drawer.dart';
import 'package:chatgptbot/widgets/export_data.dart';
import 'package:flutter/material.dart';

// Define enum for drawer options
enum DrawerOptions {
  allMessages,
  thumbsUp,
  editResponse,
  addNewPair,
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Variable to store selected option
  DrawerOptions _selectedOption = DrawerOptions.allMessages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffE9EFF7),
        surfaceTintColor: Colors.transparent,
        title: const Text('לוח המחוונים של ברט בוט'),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 20),
        //     child: ExportDataButton(
        //       icon: Icons.download,
        //       onPressed: () {
        //         showMenu<String>(
        //           context: context,
        //           position: const RelativeRect.fromLTRB(10, 50, 0, 0),
        //           items: <PopupMenuEntry<String>>[
        //             const PopupMenuItem<String>(
        //               value: 'Export as Documents',
        //               child: Text('ייצא כמסמך'),
        //             ),
        //             const PopupMenuItem<String>(
        //               value: 'Export as PDF',
        //               child: Text('ייצוא כ-pdf'),
        //             ),
        //           ],
        //         ).then((value) {
        //           if (value == 'Export as Documents') {
        //             // Handle export as documents
        //           }
        //           else if (value == 'Export as PDF') {
        //             // Handle export as PDF
        //           }
        //         });
        //       },
        //     ),
        //   ),
        // ],
      ),
      drawer: DashboardDrawer(
        // Pass selected option to DashboardDrawer
        selectedOption: _selectedOption,
        // Function to update selected option
        onOptionSelected: (option) {
          setState(() {
            _selectedOption = option;
          });
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 10),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            // Display data based on selected option
            child: _buildSelectedScreen(),
          ),
        ),
      ),
    );
  }

  // Function to return widget based on selected option
  Widget _buildSelectedScreen() {
    switch (_selectedOption) {
      case DrawerOptions.allMessages:
        return const AllMessagesTab();
      case DrawerOptions.thumbsUp:
        return const ThumbsUpTab();
      case DrawerOptions.editResponse:
        return const EditResponseTab();
      case DrawerOptions.addNewPair:
        return const AddNewPairTab();
      default:
        return Container();
    }
  }
}
