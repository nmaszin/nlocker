import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:nlocker/components/AppMenu.dart';
import 'package:nlocker/models/Locker.dart';
import 'package:nlocker/screens/AddNewLockerScreen.dart';
import '../SecureStorage.dart';
import 'LockerScreen.dart';


class YourLockersScreen extends StatefulWidget {
  const YourLockersScreen({ Key? key }): super(key: key);

  @override
  State<StatefulWidget> createState() => _YourLockersScreenState();
}

class _YourLockersScreenState extends State<YourLockersScreen> {
  late Future<List<Locker>> futureLockers;

  @override
  void initState() {
    super.initState();
    futureLockers = fetchLockers();
  }

  Future<List<Locker>> fetchLockers() async {
    final token = await secureStorage.read(key: 'auth-token');
    final url = '${dotenv.env['API_URL']}/lockers';
    final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token'
        }
    );

    if (response.statusCode == 200) {
      List<Locker> lockers = List<Locker>.from(
          jsonDecode(response.body)['data']
            .map((e) => Locker.fromJson(e))
      );
      return lockers;
    } else {
      throw Exception('Failed to load locker');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Your lockers'),
      ),
      body: FutureBuilder<List<Locker>>(
        future: futureLockers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Locker> lockers = snapshot.data!;

            return ListView(
              children: lockers.map(
                (e) => LockerTile(
                  locker: e,
                  onTap: (locker) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LockerScreen(locker: locker)
                        )
                    ).then((value) => setState(() {
                      futureLockers = fetchLockers();
                    }));
                  },
                )
              ).toList(),
            );
          } else if (snapshot.hasError) {

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                  'Something went wrong :(',
                    style: TextStyle(
                        color: Colors.red
                    ),
                  ),
                ),
                Center(child: Text(snapshot.error.toString()))
              ],
            );
          } else {
            return const Center(
              child: SpinKitCircle(
                color: Colors.blue,
                size: 20,
              ),
            );
          }
        }
      ),
      drawer: const AppMenu(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        tooltip: 'Add new locker',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewLockerScreen())
          );
        },
      ),
    );
  }
}

class LockerTile extends StatelessWidget {
  final Locker locker;
  final onTap;

  const LockerTile({ Key? key, required this.locker, required this.onTap }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [Icon(Icons.https)]
        ),
        title: Text(locker.name),
        subtitle: locker.connected ? const Text('Connected') : const Text('Inactive (disconnected)', style: TextStyle(fontStyle: FontStyle.italic)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          onTap(locker);
        },
      ),
    );
  }
}
