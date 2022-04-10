import 'package:flutter/material.dart';
import 'package:nlocker/components/AppMenu.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({ Key? key }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('About'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: const [
                Text('This app, as well as all of the hardware and software used in this project were prepared by:', textAlign: TextAlign.center),
                Text('Konrad Bankiewicz', style: TextStyle(height: 1.5)),
                Text('Paweł Błoch', style: TextStyle(height: 1.5)),
                Text('Eryk Andrzejewski', style: TextStyle(height: 1.5))
              ],
            )
          )
        ),
        drawer: const AppMenu()
    );
  }
}
