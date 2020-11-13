import 'package:json_annotation/json_annotation.dart';

part 'audio.g.dart';

@JsonSerializable()
class Audio {
  final String question;
  final String questionSound;
  final String answer;
  final String answerSound;

  Audio({this.question, this.questionSound, this.answer, this.answerSound});

  factory Audio.fromJson(Map<String, dynamic> json) => _$AudioFromJson(json);

  Map<String, dynamic> toJson() => _$AudioToJson(this);
}

enum AudioState {
  Playing,
  Paused,
  Processing
}