import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/model/audio.dart';
import 'package:learn_english/model/exercise.dart';
import 'package:learn_english/model/speaking_detail.dart';
import 'package:learn_english/ui/component/action_button.dart';
import 'package:learn_english/ui/component/custom_icon.dart';
import 'package:learn_english/ui/screen/discussion/discussion.dart';
import 'package:learn_english/ui/screen/discussion/discussion_argument.dart';
import 'package:learn_english/ui/screen/speaking/audio_script.dart';
import 'package:learn_english/ui/screen/speaking/script_item.dart';
import 'package:learn_english/util/constant.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SpeakingDetailScreen extends StatefulWidget {
  static const String id = 'speaking_detail';

  @override
  _SpeakingDetailScreenState createState() => _SpeakingDetailScreenState();
}

class _SpeakingDetailScreenState extends State<SpeakingDetailScreen> {
  AudioPlayer audioPlayer = AudioPlayer();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  initState() {
    super.initState();
    fetchData(context);
    audioPlayer.onPlayerCompletion.listen((event) {
      print("Completed");
      context.read<SpeakingDetail>().playNext();
      playAudio(context.read<SpeakingDetail>().getCurrentAudioUrl());
    });

    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
      print('state $s ');
      if (s == AudioPlayerState.PLAYING) {
        context.read<SpeakingDetail>().setAudioState(AudioState.Playing);
      } else {
        context.read<SpeakingDetail>().setAudioState(AudioState.Paused);
      }
    });

    context.read<SpeakingDetail>().addListener(() {
      if (!itemScrollController.isAttached) return;
      if (context.read<SpeakingDetail>().isCurrentIndexValid()) {
        int currentIndex = context.read<SpeakingDetail>().currentSpeechIndex;
        final itemPosition = itemPositionsListener.itemPositions.value
            .singleWhere((element) => element.index == currentIndex,
                orElse: () => null);
        bool isCurrentItemVisible;
        if (itemPosition == null || itemPosition.itemTrailingEdge > 1) {
          isCurrentItemVisible = false;
        } else {
          isCurrentItemVisible = true;
        }
        print(
            'current visible items: ${itemPositionsListener.itemPositions.value.toString()}');

        print('current item position: $itemPosition');
        print('item at index $currentIndex is visible: $isCurrentItemVisible');

        if (!isCurrentItemVisible) {
          final isLastIndex =
              context.read<SpeakingDetail>().isLastIndex(currentIndex);
          double alignment;
          if (isLastIndex) {
            final lastItem = itemPositionsListener.itemPositions.value.last;
            print('last item: $lastItem');
            final viewHeight =
                lastItem.itemTrailingEdge - lastItem.itemLeadingEdge;
            print('item view\'s height in proportion: $viewHeight');
            alignment = 1.0 - (viewHeight);
          } else {
            alignment = 1.0;
          }
          if (isLastIndex) {
            itemScrollController.scrollTo(
              index: currentIndex + 1,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          } else {
            itemScrollController.scrollTo(
              index: currentIndex + 1,
              alignment: 1.0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('PART 1: Weekend', style: kTextStyleDefault),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(25.0, 50.0),
                  ),
                  child: Container(
                    color: Color(0xFFF4F4F4),
                    child: Column(
                      children: [
                        buildController(audioPlayer),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          'Tap any sentence to replay',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Flexible(
                          child: Column(
                            children: [
                              Expanded(
                                child: ScrollablePositionedList.builder(
                                  itemScrollController: itemScrollController,
                                  itemPositionsListener: itemPositionsListener,
                                  itemCount: context
                                          .select<SpeakingDetail, List<Audio>>(
                                              (data) => data.exercise.audios)
                                          .length *
                                      2,
                                  itemBuilder: (context, index) {
                                    return Builder(builder: (context) {
                                      final audio = context
                                          .select<SpeakingDetail, List<Audio>>(
                                              (data) => data
                                                  .exercise.audios)[index ~/ 2];

                                      final isQuestion = index % 2 == 0;

                                      // return MyScriptItem(
                                      //   index: index,
                                      //   name: isQuestion ? 'A' : 'B',
                                      //   sentence: isQuestion
                                      //       ? audio.question
                                      //       : audio.answer,
                                      //   onTap: (index) {
                                      //     print(index);
                                      //     context
                                      //         .read<SpeakingDetail>()
                                      //         .setSpeech(index);
                                      //     playAudio(context
                                      //         .read<SpeakingDetail>()
                                      //         .getCurrentAudioUrl());
                                      //   },
                                      // );
                                      return AudioScript(
                                          index: index,
                                          name: isQuestion ? 'A' : 'B',
                                          script: isQuestion
                                              ? audio.question
                                              : audio.answer,
                                            onTap: (index) {
                                          print(index);
                                          context
                                              .read<SpeakingDetail>()
                                              .setSpeech(index);
                                          playAudio(context
                                              .read<SpeakingDetail>()
                                              .getCurrentAudioUrl());
                                        },
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  fetchData(BuildContext context) async {
    final data = await Future.delayed(
      Duration(milliseconds: 200),
      () => result,
    );
    final exercise = Exercise.fromJson(jsonDecode(data));
    for (int i = 0; i < 8; i++) {
      exercise.audios.add(exercise.audios[exercise.audios.length - 1]);
    }
    print(exercise.id);
    print(exercise.audios.length);
    context.read<SpeakingDetail>().setExercise(exercise);
  }

  playAudio(String url) async {
    if (url.isEmpty) {
      return;
    }
    print('https://storage.googleapis.com/' + url);
    int result =
        await audioPlayer.play('https://storage.googleapis.com/' + url);
    // if (result == 1) {
    //   print('success');
    // }
  }
}

Widget buildController(AudioPlayer audioPlayer) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Consumer<SpeakingDetail>(builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
          decoration: BoxDecoration(
            color: value.isTalking(0)
                ? Colors.orange.shade100
                : Colors.transparent,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0)),
          ),
          child: Row(
            children: [
              Text(
                'A',
                style: const TextStyle(fontSize: 40),
              ),
              SizedBox(
                width: 10.0,
              ),
              CustomIcon(
                icon: value.isTalking(0) ? Icons.volume_down : Icons.hearing,
                iconRadius: 30,
                isLoading: value.audioState == AudioState.Processing,
              ),
            ],
          ),
        );
      }),
      Consumer<SpeakingDetail>(builder: (context, value, child) {
        return GestureDetector(
            onTap: () async {
              print("current Index ${value.currentSpeechIndex}");
              if (value.currentSpeechIndex < 0 ||
                  value.currentSpeechIndex >=
                      value.exercise.audios.length * 2) {
                value.setSpeech(0);
                audioPlayer.play('https://storage.googleapis.com/' +
                    context.read<SpeakingDetail>().getCurrentAudioUrl());
              } else if (value.audioState == AudioState.Paused) {
                // resume the audio
                final result = await audioPlayer.resume();
                if (result == 1) {
                  value.setAudioState(AudioState.Playing);
                }
              } else if (value.audioState == AudioState.Playing) {
                // pause the audio
                final result = await audioPlayer.pause();
                if (result == 1) {
                  value.setAudioState(AudioState.Paused);
                }
              }
            },
            child: CustomIcon(
                isLoading: value.audioState == AudioState.Processing,
                icon: value.audioState == AudioState.Paused
                    ? Icons.play_arrow
                    : Icons.pause));
      }),
      Consumer<SpeakingDetail>(builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
          decoration: BoxDecoration(
            color: value.isTalking(1)
                ? Colors.orange.shade100
                : Colors.transparent,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0)),
          ),
          child: Row(
            children: [
              Text(
                'B',
                style: const TextStyle(fontSize: 40),
              ),
              SizedBox(
                width: 10.0,
              ),
              CustomIcon(
                icon: value.isTalking(1) ? Icons.volume_down : Icons.hearing,
                iconRadius: 30,
                isLoading: value.audioState == AudioState.Processing,
              ),
            ],
          ),
        );
      }),
    ],
  );
}

Widget buildActionButtons(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 6.0, bottom: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Spacer(
          flex: 1,
        ),
        Flexible(
          flex: 5,
          child: InkWell(
            child: ActionButton(
              icon: Icons.chat_bubble,
              label: 'Discussion',
            ),
            onTap: () {
              if (context.read<SpeakingDetail>().exercise.id.isNotEmpty) {
                Navigator.pushNamed(
                  context,
                  DiscussionScreen.id,
                  arguments: DiscussionScreenArgument(
                      topicId: context.read<SpeakingDetail>().exercise.id),
                );
              }
            },
          ),
        ),
        Spacer(
          flex: 2,
        ),
        Flexible(
          flex: 5,
          child: ActionButton(
            icon: Icons.note_add,
            label: 'Note',
          ),
        ),
        Spacer(
          flex: 1,
        ),
      ],
    ),
  );
}

const result = '{'
    '\"id\": \"6288396b-da2e-41a2-b229-119617884567\",'
    '\"audios\": [    '
    '{'
    '\"question\": \"Do you like travelling?\",'
    '\"questionSound\": \"kslearning\/sound\/8573226-1601948895232-p1_q(27.1).mp3\",'
    '\"answer\": \"You bet! I am a big fan of traveling around. I spend months all together each year to go somewhere else. I feel that it\'s not only an indispensable part of my life but also can culture my mental development.\",'
    '\"answerSound\": \"kslearning\/sound\/948280156-1602496553255-p1-27.1.mp3\"'
    '},'
    '{ '
    '\"question\": \"In which seasons do you prefer to travel?\",'
    '\"questionSound\": \"kslearning\/sound\/737277933-1601948899805-p1_q(27.2).mp3\",'
    '\"answer\": \"I guess the autumn is the best time to travel. As it is neither too hot nor too cold, people will feel comfortable to go out. Besides, as the foliage of trees will turn yellow or red, you will find the picturesque views all around you. Wherever you go, you will experience a memorable trip.\",'
    '\"answerSound\": \"kslearning\/sound\/291829947-1602496561200-p1-27.2.mp3\"'
    '},'
    '{'
    '\"question\": \"Would you say your country is a good place for travellers to visit?\",'
    '\"questionSound\": \"kslearning\/sound\/890415867-1601948905511-p1_q(27.3).mp3\",'
    '\"answer\": \"Yes, Chinese people are renowned for their hospitality to visitors. And there are also numerous tourist attractions around the country. For instance, you can visit the natural landscape to see the picturesque views, or you can go to the historical relics to know the events through the long Chinese history, or you can just stay at the metropolises to experience the local people\'s lifestyle.\",'
    '\"answerSound\": \"kslearning\/sound\/842547676-1602496569280-p1-27.3.mp3\"'
    '}'
    ']'
    '}';
