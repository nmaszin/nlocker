import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:nlocker/models/Locker.dart';
import 'package:nlocker/models/RfidTag.dart';
import 'package:nlocker/screens/RfidTagAddScreen.dart';
import 'package:http/http.dart' as http;

import '../SecureStorage.dart';

class RfidTagsManageScreen extends StatefulWidget {
  final Locker locker;

  const RfidTagsManageScreen({ Key? key, required this.locker }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RfidTagsManageScreen();
  }
}

class _RfidTagsManageScreen extends State<RfidTagsManageScreen> {
  late Future<List<RfidTag>> futureTags;

  @override
  void initState() {
    super.initState();
    futureTags = fetchRfidTagsList();
  }

  Future<List<RfidTag>> fetchRfidTagsList() async {
    final token = await secureStorage.read(key: 'auth-token');
    final url = '${dotenv.env['API_URL']}/lockers/${widget.locker.id}/rfids';
    final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token'
        }
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      List<RfidTag> tags = List<RfidTag>.from(
          jsonDecode(response.body)['data']
              .map((e) => RfidTag.fromJson(e))
      );
      return tags;
    } else {
      throw Exception('Something went wrong');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage RFID tags'),
      ),
      body: FutureBuilder<List<RfidTag>>(
        future: futureTags,
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return ListView(children: [],);
          }

          final List<RfidTag> tags = snapshot.data!;
          return ListView(
            children: tags.map((tag) {
              final DateTime time = DateTime.parse(tag.creationTime);
              return Card(
                elevation: 2,
                child: Tooltip(
                  message: 'Long press to delete',
                  triggerMode: TooltipTriggerMode.tap,
                  child: ListTile(
                    title: Text(tag.name),
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [Icon(Icons.vpn_key)],
                    ),
                    subtitle: Text('Created on ${DateFormat('yyyy-MM-dd').format(time)} at ${DateFormat('HH:mm:ss').format(time)}'),
                    trailing: const Icon(Icons.delete),
                    onLongPress: () async {
                      final token = await secureStorage.read(key: 'auth-token');
                      final url = '${dotenv.env['API_URL']}/lockers/${widget.locker.id}/rfids/${tag.id}';
                      final response = await http.delete(
                          Uri.parse(url),
                          headers: {
                            'Authorization': 'Bearer $token'
                          }
                      );

                      setState(() {
                        futureTags = fetchRfidTagsList();
                      });

                      final String message = response.statusCode == 200 ? 'RFID tag deleted succesfully' : 'Could not delete the RFID tag';
                      final color = response.statusCode == 200 ? Colors.green : Colors.redAccent;

                      final snackBar = SnackBar(
                        content: Padding(
                        padding: const EdgeInsets.all(10),
                          child: Text(message),
                        ),
                        backgroundColor: color,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  )
                )
              );
            }).toList()
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        tooltip: 'Add new RFID tag',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RfidTagAddScreen(locker: widget.locker))
          ).then((value) => setState(() {
            futureTags = fetchRfidTagsList();
          }));
        },
      ),
    );
  }
}
