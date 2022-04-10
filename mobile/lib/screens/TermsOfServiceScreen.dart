import 'package:flutter/material.dart';
import 'package:nlocker/components/AppMenu.dart';

class TermsOfServiceScreen extends StatelessWidget {
  final bool withDrawer;

  const TermsOfServiceScreen({ Key? key, required this.withDrawer }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Terms of Service'),
        ),
        body: const Center(
          child: Text('Terms of service'),
        ),
        drawer: withDrawer ? const AppMenu() : null
    );
  }
}
