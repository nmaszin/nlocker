import 'dart:convert';
import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nlocker/components/FormCheckbox.dart';
import 'package:nlocker/components/FormResult.dart';
import 'package:nlocker/components/ProductHeader.dart';
import 'package:nlocker/screens/LoginScreen.dart';
import 'package:nlocker/screens/TermsOfServiceScreen.dart';
import 'package:http/http.dart' as http;

import '../SecureStorage.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({ Key? key }): super(key: key);

  @override
  State<StatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  Future<void>? signUpFuture;

  Future<void> signUp() async {
    final token = await secureStorage.read(key: 'auth-token');
    final url = '${dotenv.env['API_URL']}/register';
    final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(<String, String> {
          'email': _email.text,
          'password': _password.text,
          'confirmPassword': _confirmPassword.text
        }),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        }
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 201) {
      const snackBar = SnackBar(
        content: Padding(
          padding: EdgeInsets.all(10),
          child: Text('Registered successfully! Log in, please.'),
        ),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } else {
      const snackBar = SnackBar(
        content: Padding(
          padding: EdgeInsets.all(10),
          child: Text('Registration error!'),
        ),
        backgroundColor: Colors.redAccent,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      throw Exception('Could not register');
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
                                  'Sign up',
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
                                  controller: _password,
                                  obscureText: true,
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
                                child: TextFormField(
                                  controller: _confirmPassword,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      fillColor: Colors.white,
                                      filled: true,
                                      hintText: 'Confirm password'
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password confirmation is empty';
                                    } else if (_password.text != value) {
                                      return 'Passwords are different';
                                    } else {
                                      return null;
                                    }
                                  },
                                )
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: FormCheckbox(
                                  title: RichText(
                                      text: TextSpan(
                                          children: [
                                            const TextSpan(
                                                text: 'Accept ',
                                                style: TextStyle(color: Colors.black)
                                            ),
                                            TextSpan(
                                                text: 'Terms of Service',
                                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () async {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => const TermsOfServiceScreen(withDrawer: false))
                                                    );
                                                  }
                                            )
                                          ]
                                      )
                                  ),
                                  required: true
                                )
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      signUpFuture = signUp();
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
                                    child: Text(
                                      'Sign up'
                                    ),
                                  )
                              ),
                            ),
                          ]
                      ),
                    )
                  ],
                ),
              )
            )
        )
    );
  }
}

