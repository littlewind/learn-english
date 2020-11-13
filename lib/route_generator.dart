import 'package:flutter/material.dart';
import 'package:learn_english/ui/screen/discussion/discussion.dart';
import 'package:learn_english/ui/screen/discussion/discussion_argument.dart';
import 'package:learn_english/ui/screen/login_screen.dart';
import 'package:learn_english/ui/screen/registration_screen.dart';
import 'package:learn_english/ui/screen/speaking/speaking_detail_screen.dart';
import 'package:learn_english/ui/screen/welcome_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case WelcomeScreen.id:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());
      case LoginScreen.id:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case RegistrationScreen.id:
        return MaterialPageRoute(builder: (_) => RegistrationScreen());
      case SpeakingDetailScreen.id:
        return MaterialPageRoute(builder: (_) => SpeakingDetailScreen());
      case DiscussionScreen.id:
        final DiscussionScreenArgument args = settings.arguments;
        return MaterialPageRoute(
            builder: (_) => DiscussionScreen(topicId: args.topicId));
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
