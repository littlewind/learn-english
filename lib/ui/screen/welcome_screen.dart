import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/ui/component/rounded_button.dart';
import 'package:learn_english/ui/screen/registration_screen.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['Flash Chat'],
                  speed: Duration(seconds: 1),
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              title: 'Log In',
              color: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButton(
              title: 'Register',
              color: Colors.blueAccent,
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
            SizedBox(
              height: 30.0,
            ),
            // SelectableText('Selectable ne cac ban oi, The quick brown ...'),
            // SelectableText('2 - Selectable ne cac ban oi, The quick brown ...'),
            // ExtendedText('ExtendedText - Selectable ne cac ban oi, The quick brown ...', selectionEnabled: true,),
            // ExtendedText('2 - ExtendedText - Selectable ne cac ban oi, The quick brown ...', selectionEnabled: false,),
            // ExtendedText('3 - ExtendedText - Selectable ne cac ban oi, The quick brown ...', selectionEnabled: true,),
          ],
        ),
      ),
    );
  }
}
