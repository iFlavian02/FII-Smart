import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return UserModel.fromJson(doc.data() ?? {});
  }

  Future<void> updateUser(String uid, UserModel user) async {
    await _db.collection('users').doc(uid).set(user.toJson());
  }

  Future<void> updateWeaknesses(String uid, List<String> newWeaknesses) async {
    await _db.collection('users').doc(uid).update({'weaknesses': newWeaknesses});
  }

  Future<List<Map<String, dynamic>>> getYears() async {
    // This is a placeholder. In a real app, you'd fetch this from Firestore.
    return [
      {'id': '1', 'name': 'Year 1'},
      {'id': '2', 'name': 'Year 2'},
      {'id': '3', 'name': 'Year 3'},
    ];
  }

  Future<void> updateQuizHistory(String uid, Map<String, dynamic> quizResult) async {
    await _db.collection('users').doc(uid).update({
      'quizHistory': FieldValue.arrayUnion([quizResult])
    });
  }
}
