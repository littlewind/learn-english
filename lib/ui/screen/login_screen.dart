import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/util/constant.dart';
import 'package:learn_english/ui/component/rounded_button.dart';
import 'package:learn_english/ui/screen/speaking/speaking_detail_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String _email = 'phung@gmail.com';
  String _password = '123456';

  // manage state of modal progress HUD widget
  bool _isInAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                  SizedBox(
                    height: 48.0,
                  ),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    controller: TextEditingController()..text = 'phung@gmail.com',
                    onChanged: (value) {
                      _email = value;
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: kTextFieldDecoration,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    obscureText: true,
                    textAlign: TextAlign.center,
                    controller: TextEditingController()..text = '123456',
                    onChanged: (value) {
                      _password = value;
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your password'),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  RoundedButton(
                    title: 'Log In',
                    color: Colors.lightBlueAccent,
                    onPressed: () async {
                      setState(() {
                        _isInAsyncCall = true;
                      });
                      try {
                        final userCredential = await _auth.signInWithEmailAndPassword(
                            email: _email, password: _password);
                        if (userCredential != null) {
                          print('${userCredential.user.email} - ${userCredential.user.uid}');
                          Navigator.pushNamedAndRemoveUntil(context, SpeakingDetailScreen.id, (route) => false);
                        }
                      } catch (e) {
                        print(e);
                      } finally {
                        setState(() {
                          _isInAsyncCall = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }
}
