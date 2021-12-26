import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_taking/src/model/user_model.dart';

class AuthRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addUser(UserModel model)async  {
    
    final documentRef = _firestore.collection('user').doc(model.uid);
    final docSnapshot =await  documentRef.get();
    if(docSnapshot.exists) {
      return;
    }
    documentRef.set(model.toMap());
  }
}
