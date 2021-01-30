import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/storage.dart';
import 'package:shop/exceptions/auth_exception.dart';

class AuthProvider with ChangeNotifier {
  static const apiKey = 'AIzaSyDqZ6zqFv9wEb_BbMNXu_CRXr_WlansYWY';
  DateTime _expiryDate;
  String _token;
  String _userId;
  Timer _logoutTimer;

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()))
      return _token;
    else
      return null;
  }

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return isAuth ? _userId : null;
  }

  Future<void> _authenticate(String email, String password, String url) async {
    final response = await http.post(
      url,
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final responseBody = json.decode(response.body);
    if (responseBody['error'] != null) {
      throw AuthException(responseBody['error']['message']);
    } else {
      _userId = responseBody['localId'];
      _token = responseBody['idToken'];
      _expiryDate = DateTime.now().add(Duration(
        seconds: int.parse(
          responseBody['expiresIn'],
        ),
      ));

      Storage.saveMap('userData', {
        "token": _token,
        "userId": _userId,
        "expiryDate": _expiryDate.toIso8601String(),
      });

      _autoLogout();
      notifyListeners();
    }

    return Future.value();
  }

  Future<void> signup(String email, String password) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey";
    return _authenticate(email, password, url);
  }

  Future<void> login(String email, String password) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey";
    return _authenticate(email, password, url);
  }

  Future<void> tryAutoLogin() async {
    if (isAuth) return Future.value();

    final userData = await Storage.getMap('userData');
    if (userData == null) return Future.value();

    final expiryDate = DateTime.parse(userData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) return Future.value();

    _userId = userData['userId'];
    _token = userData['token'];
    _expiryDate = expiryDate;

    _autoLogout();
    notifyListeners();
    return Future.value();
  }

  Future<void> logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    Storage.remove('userData');
    notifyListeners();
    if (_logoutTimer != null) {
      _logoutTimer.cancel();
      _logoutTimer = null;
    }

    return Future.value();
  }

  void _autoLogout() {
    if (_logoutTimer != null) _logoutTimer.cancel();
    final timeToLogout = _expiryDate.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(Duration(seconds: timeToLogout), logout);
  }
}
