import 'package:chatgptbot/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:chatgptbot/bloc/chat_bloc/chat_bloc.dart';
// import 'package:chatgptbot/screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    return const MaterialApp(
      title: 'Chat GPT Bot',
      debugShowCheckedModeBanner: false,

      // localizationsDelegates: const [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: AppLocalizations.supportedLocales,
      // locale: state is ChatLanguageLoadedState ? state.locale : const Locale("en"),
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: ChatScreen(),
    );
    //     },
    //   ),
    // );
  }
}
