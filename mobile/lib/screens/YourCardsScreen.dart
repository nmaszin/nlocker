import 'package:flutter/material.dart';
import 'package:nlocker/components/AppMenu.dart';

class YourCardsScreen extends StatelessWidget {
  const YourCardsScreen({ Key? key }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cards')
      ),
      body: Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: const [
           Text('You don\'t have any cards yet. Click button to add one')
         ],
       ),
      ),
      drawer: AppMenu()
    );
  }
}
