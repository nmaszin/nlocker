import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:nlocker/screens/LoginScreen.dart';
import 'package:nlocker/screens/YourLockersScreen.dart';

import 'SecureStorage.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future main() async {
  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();
  /*secureStorage.write(
      key: 'auth-token',
      value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidHlwZSI6InVzZXIiLCJpYXQiOjE2NDQwOTkzNjQsImV4cCI6MTY0NDEwMDU2NH0.aM80FZov73mDMbw60baWhi-Bezmwk7e-mF7Q0MyEzvM'
  );*/

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NLocker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: secureStorage.read(key: 'auth-token'),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return const YourLockersScreen();
          } else {
            return const LoginScreen();
          }
        }
      )
    );
  }
}
