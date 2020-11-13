import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/model/speaking_detail.dart';
import 'package:learn_english/route_generator.dart';
import 'package:learn_english/ui/screen/welcome_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
  // If you're running an application and need to access the binary messenger before `runApp()` has been called
  // (for example, during plugin initialization),
  // then you need to explicitly call the `WidgetsFlutterBinding.ensureInitialized()` first.
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SpeakingDetail>(create: (_) => SpeakingDetail()),
      ],
      child: MaterialApp(
        theme: ThemeData.light().copyWith(
          primaryColor: Colors.cyan,
          textTheme: TextTheme(
            bodyText2: TextStyle(color: Colors.black54),
          ),
        ),
        initialRoute: WelcomeScreen.id,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}


