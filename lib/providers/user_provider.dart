import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mugorithm/model/User.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  User? _user;

  final String _localhost = '192.168.0.2';

  // user getter
  User? get user => _user;

  // 비동기로 유저 존재 유무 확인
  Future<void> fetchUserDataFromServer(String email, String password) async {
    final String _userApi = 'http://${_localhost}:8080/login';

    User user = User(email: email, password: password); // 입력받은 유저 정보
    print('${_userApi}\n');
    // 서버로 데이터 전송
    try {
      final response = await http.post(Uri.parse(_userApi),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }));
      print(response.body);
      print(email);
      print(password);
      if (response.statusCode == 200) {
        // 유저 존재
        print('유저존재\n');
        _user = user;
      } else {
        // 유전 존재 안함
        print('유저존재안함\n');
        _user = null;
      }
    } catch (e) {
      print('오류 발생 : $e');
    }

    notifyListeners();
  }

  Future<void> registerUser(String email, String password) async {
    final String _registerApi = 'http://${_localhost}:8080/register';

    // 서버로 데이터 전송
    try {
      final response = await http.post(Uri.parse(_registerApi),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }));
      print(response.body);

      if (response.statusCode == 200) {
        print('유저등록\n');
      } else {
        print('유저존재못함\n');
      }
    } catch (e) {
      print('오류 발생 : $e');
    }

    notifyListeners();
  }
}
