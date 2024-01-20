import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rarecrew/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _appUser;

  AppUser? get appUser => _appUser;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String defaultName = email.split('@').first;
      _appUser = AppUser(
        uid: result.user!.uid,
        email: result.user!.email!,
        name: defaultName, // Replace with actual user name
      );

      notifyListeners();
    } catch (e) {
      print('Error signing in: $e');
      throw e;
    }
  }

  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String defaultName = email.split('@').first;
      _appUser = AppUser(
        uid: result.user!.uid,
        email: result.user!.email!,
        name: defaultName, // Replace with actual user name
      );
      // Create a user document in the 'live/users' collection
      DocumentReference userDocRef = _firestore.collection('live').doc('users').collection("users").doc(_appUser!.uid);
      await userDocRef.set({
        'email': _appUser!.email,
        'name': _appUser!.name,
        "uid": _appUser!.uid,
      });


      notifyListeners();
    } catch (e) {
      print('Error registering: $e');
      throw e;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _appUser = null;
    notifyListeners();
  }
}
