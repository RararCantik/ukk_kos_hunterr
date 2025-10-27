// lib/controller/auth_controller.dart
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/database_helper.dart';

class AuthController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper(); 

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  // Getters untuk UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  String? get userRole => _user?.role;
  int? get userId => _user?.id;

  Future<bool> attemptLogin(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      // Panggil fungsi login dari DatabaseHelper
      final Map<String, dynamic>? userDataMap = await _dbHelper.login(email, password);

      if (userDataMap != null) {
        _user = UserModel.fromMap(userDataMap); // Buat model dari map
        _setLoading(false);
        return true; // Login sukses
      } else {
        _setErrorMessage('Email atau password salah.');
        _setLoading(false);
        return false; // Login gagal
      }
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> attemptRegister({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    // Buat model baru
    final newUser = UserModel(
      name: name,
      email: email,
      password: password, 
      phone: phone,
      role: role,
    );

    try {
      // Panggil fungsi createUser dari DatabaseHelper
      await _dbHelper.createUser(newUser.toMap());
      _setLoading(false);
      return true; // Registrasi sukses
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed: users.email')) {
        _setErrorMessage('Email sudah terdaftar.');
      } else {
        _setErrorMessage(e.toString());
      }
      _setLoading(false);
      return false; // Registrasi gagal
    }
  }

  void logout() {
    _user = null;
    // Tidak perlu hapus token, karena kita tidak pakai token
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }
}