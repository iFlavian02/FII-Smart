import 'package:json_annotation/json_annotation.dart';

part 'course_model.g.dart';

@JsonSerializable()
class CourseModel {
  final String year;
  final String semester;
  final String courseName;
  final String subject;

  CourseModel({required this.year, required this.semester, required this.courseName, required this.subject});

  factory CourseModel.fromJson(Map<String, dynamic> json) => _$CourseModelFromJson(json);
  Map<String, dynamic> toJson() => _$CourseModelToJson(this);
}
