import 'package:chatgptbot/screens/Dashboard/dashboard.dart';
import 'package:chatgptbot/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:universal_html/html.dart' as html;
import 'firebase_options.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  String? initialRoute = html.window.location.pathname;
  setPathUrlStrategy();
  runApp(MyApp(initialRoute: initialRoute!));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat GPT Bot',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const ChatScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
      // Handle unknown routes
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('404 - Page not found')
            ),
          ),
        );
      },
      initialRoute: initialRoute,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue
      ),
    );
  }
}
