import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthManage {
  Future<String> signUp(String useEmail, String userPass) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: useEmail,
        password: userPass,
      );
      return userCredential.user!.uid;
    } catch (e) {
      debugPrint('Error occurred while signing up: $e');
      rethrow;
    }
  }

  Future<UserCredential> login(String useEmail, String userPass) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: useEmail,
        password: userPass,
      );
    } catch (e) {
      debugPrint('Error occurred while logging in: $e');
      rethrow;
    }
  }
}