import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nlocker/SecureStorage.dart';
import 'package:nlocker/models/Locker.dart';
import 'package:nlocker/screens/LockerOpeningHistoryScreen.dart';
import 'package:nlocker/screens/RfidTagsManageScreen.dart';

class LockerScreen extends StatefulWidget {
  final Locker locker;

  const LockerScreen({ Key? key, required this.locker }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LockerScreen();
  }
}

class _LockerScreen extends State<LockerScreen> {
  Locker? locker;
  TextEditingController? lockerNameController;

  @override
  void initState() {
    super.initState();
    locker = widget.locker;
    lockerNameController = TextEditingController(text: locker!.name);
  }


  Future<void> _displayLockerRenameModal(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set new locker name'),
          content: TextField(
            controller: lockerNameController,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () async {
                setState(() {
                  locker = Locker(
                    id: locker?.id,
                    name: lockerNameController!.text,
                    connected: locker!.connected
                  );
                });

                final token = await secureStorage.read(key: 'auth-token');
                final url = '${dotenv.env['API_URL']}/lockers/${locker!.id!}';
                final response = await http.put(
                    Uri.parse(url),
                    body: jsonEncode(<String, String>{
                      'name': locker!.name
                    }),
                    headers: {
                      'Content-Type': 'application/json; charset=UTF-8',
                      'Authorization': 'Bearer $token'
                    }
                );

                Navigator.pop(context);

                final String message = response.statusCode == 200 ? 'Name updated succesfully' : 'Could not update the name';
                final color = response.statusCode == 200 ? Colors.green : Colors.redAccent;
                final snackBar = SnackBar(
                  content: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(message),
                  ),
                  backgroundColor: color,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Manage the locker'),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                title: const Text('Name'),
                subtitle: Text(locker!.name),
                trailing: const Icon(Icons.settings),
                onTap: () {
                  _displayLockerRenameModal(context);
                }
              ),
              ListTile(
                title: const Text('Open'),
                subtitle: const Text('Open your locker'),
                trailing: const Icon(Icons.lock_open),
                onTap: () async {
                  final token = await secureStorage.read(key: 'auth-token');
                  final url = '${dotenv.env['API_URL']}/lockers/${locker!.id!}/openings';
                  final response = await http.post(
                      Uri.parse(url),
                      headers: {
                        'Authorization': 'Bearer $token'
                      }
                  );
                  print(response.statusCode);
                  print(response.body);

                  final String message = response.statusCode == 201 ? 'Locker opened succesfully' : 'Could not open the locker, because it\'s disconnected';
                  final color = response.statusCode == 201 ? Colors.green : Colors.redAccent;
                  final snackBar = SnackBar(
                    content: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(message),
                    ),
                    backgroundColor: color,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
              ListTile(
                title: const Text('Manage RFID tags'),
                subtitle: const Text('Assign tags to this locker'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RfidTagsManageScreen(locker: widget.locker)
                    )
                  );
                },
              ),
              ListTile(
                title: const Text('Browse opening history'),
                subtitle: const Text('See who and when has opened this locker'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LockerOpeningHistoryScreen(locker: widget.locker)
                    )
                  );
                },
              ),
              ListTile(
                title: const Text(
                  'Reset locker to factory settings',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text(
                  'Warning! It\'s a permanent operation!',
                ),
                trailing: const Icon(Icons.clear),
                onTap: () async {
                  final token = await secureStorage.read(key: 'auth-token');
                  final url = '${dotenv.env['API_URL']}/lockers/${locker!.id!}';
                  print(url);
                  final response = await http.delete(
                      Uri.parse(url),
                      headers: {
                        'Authorization': 'Bearer $token'
                      }
                  );

                  Navigator.pop(context);
                },
              ),
            ]
          ).toList(),
        )
    );
  }
}

/*enum PopupMenuEntryType {
  showDetails,
  manageTags,
  resetLocker
}

class PopupMenuEntry {
  final PopupMenuEntryType type;
  final String title;

  const PopupMenuEntry({ required this.type, required this.title });
}

class LockerScreen extends StatefulWidget {
  final popupMenuOptions = const [
    PopupMenuEntry(
        type: PopupMenuEntryType.showDetails,
        title: 'Show details'
    ),
    PopupMenuEntry(type: PopupMenuEntryType.manageTags, title: 'Manage tags'),
    PopupMenuEntry(type: PopupMenuEntryType.resetLocker, title: 'Reset locker')
  ];

  final Locker locker;

  const LockerScreen({ Key? key, required this.locker }): super(key: key);

  void popupMenuHandler(PopupMenuEntryType type) {
    switch (type) {
      case PopupMenuEntryType.showDetails:
        break;

      case PopupMenuEntryType.manageTags:
        break;

      case PopupMenuEntryType.resetLocker:
        break;
    }

  @override
  State<StatefulWidget> createState() {
    return _LockerScreen();
  }
}

class _LockerScreen extends State<LockerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(locker.title),
        actions: <Widget>[
          PopupMenuButton<PopupMenuEntryType>(
            onSelected: popupMenuHandler,
            itemBuilder: (BuildContext context) {
              return popupMenuOptions.map((PopupMenuEntry choice) {
                return PopupMenuItem<PopupMenuEntryType>(
                  value: choice.type,
                  child: Text(choice.title),
                );
              }).toList();
            }
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
                padding: EdgeInsets.only(top: 0),
                child: Text(
                  'Recently opened',
                  style: TextStyle(
                    fontSize: 20
                  ),
                )
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                child: Text(''),
              )
            ),
          ],
        ),
      )
    );
  }
}*/