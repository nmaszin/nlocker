import 'package:flutter/material.dart';
import 'package:nlocker/SecureStorage.dart';
import 'package:nlocker/screens/LoginScreen.dart';

dynamic pushReplacement(context, callback) async {
  final token = await secureStorage.read(key: 'auth-token');
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => token == null ?
          const LoginScreen() :
          callback(context)
      )
  );
}

dynamic push(context, callback) async {
  final token = await secureStorage.read(key: 'auth-token');
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => token == null ?
          const LoginScreen() :
          callback(context)
      )
  );
}


