import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDateOfToken;
  String? _userId;
  Timer? _authTimer;

  bool get isAuthenticate {
    return _token != null;
  }

  String? get token {
    if (_token != null && _expiryDateOfToken!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String authModeLink) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$authModeLink?key=AIzaSyCGw3rlSaGhzI3ly9f5VEbzwQkCsVE5l54');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _userId = responseData['localId'];
      _token = responseData['idToken'];
      _expiryDateOfToken = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDateOfToken': _expiryDateOfToken.toString(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    await _authenticate(email, password, 'signUp');
  }

  Future<void> signInWithPassword(String email, String password) async {
    await _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final data = prefs.getString('userData');
    final extractedUserData = json.decode(data!) as Map<String, dynamic>;
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDateOfToken'] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDateOfToken = DateTime.parse(extractedUserData['expiryDateOfToken']);
    notifyListeners();
    _autoLogout();
    return true;
  }

  void signOut() async {
    _token = null;
    _userId = null;
    _expiryDateOfToken = null;
    _authTimer?.cancel();
    _authTimer = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    _authTimer?.cancel();
    final int timeToExpiry =
        this._expiryDateOfToken!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), signOut);
  }
}
