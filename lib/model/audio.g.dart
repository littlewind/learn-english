// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Audio _$AudioFromJson(Map<String, dynamic> json) {
  return Audio(
    question: json['question'] as String,
    questionSound: json['questionSound'] as String,
    answer: json['answer'] as String,
    answerSound: json['answerSound'] as String,
  );
}

Map<String, dynamic> _$AudioToJson(Audio instance) => <String, dynamic>{
      'question': instance.question,
      'questionSound': instance.questionSound,
      'answer': instance.answer,
      'answerSound': instance.answerSound,
    };
