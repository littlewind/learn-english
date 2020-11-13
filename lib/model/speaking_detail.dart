import 'package:flutter/foundation.dart';
import 'package:learn_english/model/audio.dart';
import 'package:learn_english/model/exercise.dart';

class SpeakingDetail extends ChangeNotifier {
  Exercise exercise = Exercise(id: "", audios: []);
  int currentSpeechIndex = -1;
  AudioState audioState = AudioState.Paused;

  setExercise(Exercise ex) {
    this.exercise = ex;
    notifyListeners();
  }

  setSpeech(int index) {
    this.currentSpeechIndex = index;
    notifyListeners();
  }

  playNext() {
    // int newIndex = this.currentSpeechIndex + 1;
    // this.currentSpeechIndex = newIndex;
    this.currentSpeechIndex++;
    notifyListeners();
  }

  setAudioState(AudioState state) {
    this.audioState = state;
    notifyListeners();
  }

  bool isTalking(int person) {
    final numberOfPeople = 2;
    if (currentSpeechIndex < 0 || currentSpeechIndex >= exercise.audios.length * 2) {
      return false;
    }
    return currentSpeechIndex % numberOfPeople == person;
  }

  String getCurrentAudioUrl() {
    if (currentSpeechIndex < 0 || currentSpeechIndex >= exercise.audios.length * 2) {
      return "";
    }
    final index = currentSpeechIndex ~/ 2;
    final isQuestion = currentSpeechIndex % 2 == 0;

    if (isQuestion) {
      return exercise.audios[index].questionSound;
    } else {
      return exercise.audios[index].answerSound;
    }
  }

  bool isCurrentIndexValid() {
    return (currentSpeechIndex >= 0 && currentSpeechIndex < exercise.audios.length * 2);
  }

  bool isLastIndex(int index) {
    return index == (exercise.audios.length * 2 - 1) ;
  }
}