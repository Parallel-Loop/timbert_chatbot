// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:chat_bubbles/bubbles/bubble_normal.dart';
// import 'package:chatgptbot/bloc/chat_bloc/chat_bloc.dart';
// import 'package:chatgptbot/models/message.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//
// class ChatGPTGeneralResponseScreen extends StatefulWidget {
//   const ChatGPTGeneralResponseScreen({super.key});
//
//   @override
//   _ChatGPTGeneralResponseScreenState createState() => _ChatGPTGeneralResponseScreenState();
// }
//
// class _ChatGPTGeneralResponseScreenState extends State<ChatGPTGeneralResponseScreen> {
//   late ChatBloc _chatBloc;
//
//   @override
//   void initState() {
//     super.initState();
//     _chatBloc = BlocProvider.of<ChatBloc>(context);
//   }
//
//   @override
//   void dispose() {
//     _chatBloc.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppLocalizations.of(context)!.title),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.language),
//             tooltip: AppLocalizations.of(context)!.languageToolTip,
//             onPressed: () {
//               _chatBloc.add(ChangeLanguageEvent(
//                   AppLocalizations.of(context)!.localeName == 'en'
//                     ? const Locale('he')
//                     : const Locale('en')
//               ));
//               // AppLocalizations.of(context)!.localeName == 'en'
//               //     ? localeService.locale = const Locale('heb')
//               //     : localeService.locale = const Locale('en');
//               // sharedPreferences.setString('locale', localeService.locale!.languageCode);
//             },
//           ),
//         ],
//       ),
//       body: BlocBuilder<ChatBloc, ChatState>(
//         bloc: _chatBloc,
//         builder: (context, state) {
//           if (state is ChatLoadingState) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           else if (state is ChatLoadedState) {
//             return _buildMessagesList(state.messages);
//           }
//           else if (state is ChatErrorState) {
//             return Center(
//               child: Text(AppLocalizations.of(context)!.errorOccurred),
//             );
//           }
//           else {
//             return _buildMessagesList([]);
//           }
//         },
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16),
//         child: BottomAppBar(
//           child: Row(
//             children: [
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Container(
//                     width: double.infinity,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: TextField(
//                         controller: _chatBloc.controller,
//                         textCapitalization: TextCapitalization.sentences,
//                         onSubmitted: (value) {
//                           _chatBloc.add(SendMessageEvent(value));
//                         },
//                         textInputAction: TextInputAction.send,
//                         showCursor: true,
//                         decoration: InputDecoration(
//                           border: InputBorder.none,
//                           hintText: AppLocalizations.of(context)!.textFieldHint
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () {
//                   _chatBloc.add(SendMessageEvent(_chatBloc.controller.text));
//                 },
//                 child: Container(
//                   height: 40,
//                   width: 40,
//                   decoration: BoxDecoration(
//                       color: Colors.blue,
//                       borderRadius: BorderRadius.circular(30)
//                   ),
//                   child: const Icon(
//                     Icons.send,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 width: 8,
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMessagesList(List<Message> messages) {
//     return ListView.builder(
//       controller: _chatBloc.scrollController,
//       itemCount: messages.length,
//       reverse: true,
//       itemBuilder: (context, index) {
//         final message = messages[index];
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4),
//           child: BubbleNormal(
//             text: message.msg,
//             isSender: message.isSender,
//             color: message.isSender ? Colors.blue.shade100 : Colors.grey.shade200,
//           ),
//         );
//       },
//     );
//   }
// }
//
//
//
//
//
//
//
// //<base href="$FLUTTER_BASE_HREF">