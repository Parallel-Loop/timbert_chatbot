import 'package:chatgptbot/screens/Dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class DashboardDrawer extends StatelessWidget {
  final DrawerOptions selectedOption;
  final Function(DrawerOptions) onOptionSelected;

  const DashboardDrawer({super.key, required this.selectedOption, required this.onOptionSelected,});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  'תפריט לוח המחוונים',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            _buildOption(DrawerOptions.allMessages, 'כל ההודעות', context),
            _buildOption(DrawerOptions.thumbsUp, 'אגודלים למעלה', context),
            _buildOption(DrawerOptions.editResponse, 'ערוך תגובה', context),
            _buildOption(DrawerOptions.addNewPair, 'הוסף זוג חדש', context),
          ],
        ),
      ),
    );
  }

  // Function to build each drawer option
  Widget _buildOption(DrawerOptions option, String label, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Call onOptionSelected when option is tapped
        onOptionSelected(option);
        // Close the drawer
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        color: selectedOption == option ? Colors.blue.withOpacity(0.3) : null,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}