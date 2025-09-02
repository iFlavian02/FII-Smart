import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  List<String> weaknesses;
  List<Map<String, dynamic>> pdfs;  // User's uploaded notes
  List<Map<String, dynamic>> studiedLectures;  // Lectures the user has studied
  List<Map<String, dynamic>> quizHistory;

  UserModel({
    this.weaknesses = const [], 
    this.pdfs = const [], 
    this.studiedLectures = const [], 
    this.quizHistory = const []
  });
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
