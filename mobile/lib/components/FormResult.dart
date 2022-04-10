import 'package:flutter/material.dart';

class FormResultOk extends StatelessWidget {
  final String message;

  const FormResultOk({ Key? key, required this.message }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12
      ),
    );
  }
}

class FormResultError extends StatelessWidget {
  final String message;

  const FormResultError({ Key? key, required this.message }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
          color: Colors.red,
          fontSize: 12
      ),
    );
  }
}