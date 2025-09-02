// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  weaknesses:
      (json['weaknesses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  pdfs:
      (json['pdfs'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  studiedLectures:
      (json['studiedLectures'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  quizHistory:
      (json['quizHistory'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'weaknesses': instance.weaknesses,
  'pdfs': instance.pdfs,
  'studiedLectures': instance.studiedLectures,
  'quizHistory': instance.quizHistory,
};
