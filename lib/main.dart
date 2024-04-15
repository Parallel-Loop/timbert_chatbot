import 'package:chatgptbot/screens/Dashboard/dashboard.dart';
import 'package:chatgptbot/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:universal_html/html.dart';
import 'firebase_options.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:chatgptbot/bloc/chat_bloc/chat_bloc.dart';
// import 'package:chatgptbot/screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  String? initialRoute = window.location.pathname;

  runApp(MyApp(initialRoute: initialRoute!));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    // return MultiBlocProvider(
    // providers: [
    //   BlocProvider<ChatBloc>(
    //     create: (context) => ChatBloc(),
    //   ),
    // ],
    // child: BlocBuilder<ChatBloc, ChatState>(
    //   builder: (context, state) {
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

      // localizationsDelegates: const [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: AppLocalizations.supportedLocales,
      // locale: state is ChatLanguageLoadedState ? state.locale : const Locale("en"),
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // home: ChatScreen(),
      theme: ThemeData(
        colorSchemeSeed: Colors.blue
      ),
    );
    //     },
    //   ),
    // );
  }
}
