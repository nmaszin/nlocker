import 'dart:convert';
import 'dart:developer';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nlocker/SecureStorage.dart';
import 'package:nlocker/components/ProductHeader.dart';
import 'package:nlocker/screens/YourLockersScreen.dart';
import 'package:http/http.dart' as http;
import 'SignUpScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginInvalidCredentialsException implements Exception {}

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/login'),
      body: jsonEncode(<String, String> {
        'email': email,
        'password': password
      }),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      }
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      String token = jsonDecode(response.body)['token'];
      log(token);
      secureStorage.write(key: 'auth-token', value: token);

      const snackBar = SnackBar(
        content: Padding(
          padding: EdgeInsets.all(10),
          child: Text('Logged in successfully'),
        ),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const YourLockersScreen())
        );
      });
    } else if (response.statusCode == 401) {
      const snackBar = SnackBar(
        content: Padding(
          padding: EdgeInsets.all(10),
          child: Text('Invalid credentials'),
        ),
        backgroundColor: Colors.redAccent,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      throw LoginInvalidCredentialsException();
    } else {
      const snackBar = SnackBar(
        content: Padding(
          padding: EdgeInsets.all(10),
          child: Text('Could not log in'),
        ),
        backgroundColor: Colors.redAccent,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const ProductHeader(),
                            const Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(
                                      fontSize: 20
                                  ),
                                )
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: TextFormField(
                                controller: _email,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    fillColor: Colors.white,
                                    filled: true,
                                    hintText: 'E-mail'
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'E-mail is empty';
                                  } else if (!EmailValidator.validate(value)) {
                                    return 'It \'s not a valid e-mail';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: TextFormField(
                                  obscureText: true,
                                  controller: _password,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      fillColor: Colors.white,
                                      filled: true,
                                      hintText: 'Password'
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is empty';
                                    } else if (value.length < 8) {
                                      return 'Password should contain at least 8 characters';
                                    } else {
                                      return null;
                                    }
                                  },
                                )
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      login(_email.text, _password.text);
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
                                    child: Text(
                                        'Sign in'
                                    ),
                                  )
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                            text: 'Don\'t have an account? ',
                                            style: TextStyle(color: Colors.black)
                                        ),
                                        TextSpan(
                                            text: 'Sign up',
                                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const SignUpScreen())
                                                );
                                              }
                                        )
                                      ],
                                    )
                                )
                            )
                          ]
                      ),
                    )
                  ],
                ),
              ),
            )
        )
    );
  }
}
