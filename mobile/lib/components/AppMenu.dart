import 'package:flutter/material.dart';
import 'package:nlocker/SecureStorage.dart';
import 'package:nlocker/components/ProductHeader.dart';
import 'package:nlocker/screens/AboutScreen.dart';
import 'package:nlocker/screens/LoginScreen.dart';
import 'package:nlocker/screens/TermsOfServiceScreen.dart';
import 'package:nlocker/screens/YourLockersScreen.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({Key? key}) : super(key: key);

  dynamic goto(context, viewCallback) {
    return () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: viewCallback)
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const MenuHeader(),
          ...ListTile.divideTiles(
              context: context,
              tiles: [
                MenuEntry(title: 'Your lockers', callback: goto(context, (context) => const YourLockersScreen())),
                MenuEntry(title: 'Terms of Service', callback: goto(context, (context) => const TermsOfServiceScreen(withDrawer: true))),
                MenuEntry(title: 'About', callback: goto(context, (context) => const AboutScreen())),
                MenuEntry(title: 'Logout', callback: () async {
                  await secureStorage.delete(key: 'auth-token');
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen())
                  );
                }),
              ]
          ).toList()
        ]
      ),
    );
  }
}

class MenuHeader extends StatelessWidget {
  const MenuHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue
      ),
      child: Center(
        child: ProductHeader()
      )
    );
  }
}

class MenuEntry extends StatelessWidget {
  final String title;
  final void Function() callback;

  const MenuEntry({ Key? key, required this.title, required this.callback }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Center(child: Text(title)),
      onTap: callback
    );
  }
}

