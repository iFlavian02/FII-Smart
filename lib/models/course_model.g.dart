// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseModel _$CourseModelFromJson(Map<String, dynamic> json) => CourseModel(
  year: json['year'] as String,
  semester: json['semester'] as String,
  courseName: json['courseName'] as String,
  subject: json['subject'] as String,
);

Map<String, dynamic> _$CourseModelToJson(CourseModel instance) =>
    <String, dynamic>{
      'year': instance.year,
      'semester': instance.semester,
      'courseName': instance.courseName,
      'subject': instance.subject,
    };
