import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rarecrew/services/auth_service.dart';

import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? get appUser => _authService.appUser;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      throw e;
    }
  }

  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      await _authService.registerWithEmailAndPassword(email, password);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw e;
    }
  }
}
