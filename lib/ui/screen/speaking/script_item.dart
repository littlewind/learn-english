import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/model/speaking_detail.dart';
import 'package:learn_english/ui/component/text_select_control.dart';
import 'package:provider/provider.dart';

class MyScriptItem extends StatelessWidget {
  final int index;
  final String name;
  final String sentence;
  final Function(int index) onTap;
  final TextEditingController textEditingController = TextEditingController();

  MyScriptItem({this.index, this.name, this.sentence, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(index);
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$name: ",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            Flexible(
              // child: Text(
              //   sentence,
              //   style: context.watch<SpeakingDetail>().currentSpeechIndex == index
              //       ? Theme.of(context).textTheme.bodyText2
              //           .copyWith(color: Theme.of(context).primaryColor)
              //       : Theme.of(context).textTheme.bodyText2,
              child: ExtendedText(
                sentence,
                onTap: () {
                  print('On Tap');
                },
                onSpecialTextTap: (_) {
                  print('on special tap');
                },
                textSelectionControls: MyTextSelectionControls((word) {
                  showDialog(
                      context: context,
                      builder: (_) => new AlertDialog(
                            title: new Text(
                              "Dictionary",
                              style: TextStyle(color: Colors.black),
                            ),
                            content: new Text(word.toUpperCase(),
                                style: TextStyle(color: Colors.black)),
                          ));
                }, clearSelection: () {}),
                style: context.watch<SpeakingDetail>().currentSpeechIndex ==
                        index
                    ? Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: Theme.of(context).primaryColor)
                    : Theme.of(context).textTheme.bodyText2,
                selectionEnabled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
