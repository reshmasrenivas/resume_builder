
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    var doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) return UserModel.fromJson(doc.data()!);
    return null;
  }
}
