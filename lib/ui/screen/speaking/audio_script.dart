import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:learn_english/model/speaking_detail.dart';
import 'package:learn_english/ui/component/custom_web_view.dart';
import 'package:learn_english/util/constant.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AudioScript extends StatelessWidget {
  final int index;
  final String name;
  final String script;
  List<String> wordList;
  final Function(int index) onTap;

  AudioScript(
      {this.index, @required this.name, @required this.script, this.onTap}) {
    this.wordList = script.split(' ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // onTap(index);
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        padding: EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: context.watch<SpeakingDetail>().currentSpeechIndex == index
              ? Colors.white
              : Color(0xFFF4F4F4),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "$name: ",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Wrap(
              direction: Axis.horizontal,
              children: wordList
                  .map((word) => MyWord(
                        word: word,
                        sentenceIndex: index,
                      ))
                  .toList(),
            ),
          ),
        ]),
      ),
    );
  }
}

class MyWord extends StatelessWidget {
  final Function(String word) handleSelect;
  final String word;
  final int sentenceIndex;

  MyWord(
      {@required this.word, @required this.sentenceIndex, this.handleSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        final newStr = word.replaceAll(new RegExp(r'[^\w]+'), '');
        print('selected word: \_$word\_ : \_$newStr\_');
        // final response = await translate(newStr);
        // print('$response - response code: ${response.statusCode}');
        // final language = await getLanguage();
        final language = '';
        print('language : \_$language\_');

        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            elevation: 0.0,
            backgroundColor: Colors.white,
            child: TranslateDialog(language, newStr),
          ),
        );
      },
      child: Text(
        '$word ',
        style:
            context.watch<SpeakingDetail>().currentSpeechIndex == sentenceIndex
                ? Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Theme.of(context).primaryColor)
                : Theme.of(context).textTheme.bodyText2,
      ),
    );
  }
}

Future<http.Response> translate(String word) {
  return http.get('https://www.hola.edu.vn/utils?type=translate&word=$word');
}

Future<String> getLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('language') ?? '';
}

setLanguage(String language) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', language);
}

class TranslateDialog extends StatefulWidget {
  final String initialLanguage;
  final String word;

  TranslateDialog(this.initialLanguage, this.word);

  @override
  _TranslateDialogState createState() => _TranslateDialogState();
}

class _TranslateDialogState extends State<TranslateDialog> {
  String currentLanguage;

  @override
  void initState() {
    super.initState();
    currentLanguage = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return currentLanguage.isEmpty
        ? getDialogContentSelectLanguage()
        : getDialogContentTranslate();
  }

  getDialogContentSelectLanguage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'SELECT LANGUAGE',
            style: kTextStyleBlackDefault.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text(
            'English',
            style: kTextStyleBlackDefault,
          ),
          onTap: () {
            setLanguage('en');
            setState(() {
              currentLanguage = 'en';
            });
          },
        ),
        ListTile(
          title: Text(
            'Tiếng Việt',
            style: kTextStyleBlackDefault,
          ),
          onTap: () {
            setLanguage('vi');
            setState(() {
              currentLanguage = 'vi';
            });
          },
        ),
      ],
    );
  }

  getDialogContentTranslate() {
    if (currentLanguage == 'en') {
      return FutureBuilder<http.Response>(
          future: translate(widget.word),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var contentBase64 =
                  base64Encode(const Utf8Encoder().convert("""<!DOCTYPE html>
    <html>
      <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
      <body style='"margin: 0; padding: 0;'>
        <div>
          ${snapshot.data.body}
        </div>
      </body>
    </html>"""));
              return MyWebView(
                url: 'data:text/html;base64,$contentBase64',
              );
            } else if (snapshot.hasError) {
              return Text('Error');
            } else {
              return Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(child: CircularProgressIndicator()));
            }
          });
    } else {
      return MyWebView(
          url:
              'https://translate.google.com/?sl=en&tl=vi&text=${widget.word}&op=translate');
    }
  }
}
