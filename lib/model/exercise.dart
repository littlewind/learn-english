import 'package:json_annotation/json_annotation.dart';
import 'package:learn_english/model/audio.dart';

part 'exercise.g.dart';

@JsonSerializable()
class Exercise {
  String id = "";
  List<Audio> audios = [];

  Exercise({this.id, this.audios});

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}