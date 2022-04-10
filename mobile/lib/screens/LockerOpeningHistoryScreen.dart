import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nlocker/models/Locker.dart';
import 'package:nlocker/models/Opening.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../SecureStorage.dart';

class LockerOpeningHistoryScreen extends StatefulWidget {
  final Locker locker;

  const LockerOpeningHistoryScreen({ Key? key, required this.locker }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LockerOpeningHistoryScreen();
  }
}

class _LockerOpeningHistoryScreen extends State<LockerOpeningHistoryScreen> {
  late Future<List<Opening>> futureOpenings;

  @override
  void initState() {
    super.initState();
    futureOpenings = fetchOpenings(widget.locker);
  }

  Future<List<Opening>> fetchOpenings(Locker locker) async {
    final token = await secureStorage.read(key: 'auth-token');
    final url = '${dotenv.env['API_URL']}/lockers/${locker.id}/openings';
    final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token'
        }
    );

    if (response.statusCode == 200) {
      List<Opening> openings = List<Opening>.from(
          jsonDecode(response.body)['data']
              .map((e) => Opening.fromJson(e))
      );
      return openings;
    } else {
      throw Exception('Failed to load locker');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locker opening history'),
      ),
      body: FutureBuilder<List<Opening>>(
        future: futureOpenings,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Opening> openings = snapshot.data!;
            return ListView(
              children: openings.map((opening) => Card(
                  elevation: 2,
                  child: opening.rfidId == null ? LockerOpenedByMobile(opening: opening) : LockerOpenedByRfid(opening: opening)
              )).toList()
            );
          }

          return const Center(
            child: SpinKitCircle(
              color: Colors.blue,
              size: 20,
            ),
          );
        }
      )
    );
  }
}

class LockerOpenedByMobile extends StatelessWidget {
  final Opening opening;

  const LockerOpenedByMobile({ Key? key, required this.opening }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime time = DateTime.parse(opening.time);

    return ListTile(
      title: const Text('Mobile app'),
      subtitle: Text('Opened on ${DateFormat('yyyy-MM-dd').format(time)} at ${DateFormat('HH:mm:ss').format(time)}'),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [Icon(Icons.smartphone)],
      ),
    );
  }
}

class LockerOpenedByRfid extends StatelessWidget {
  final Opening opening;

  const LockerOpenedByRfid({ Key? key, required this.opening }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime time = DateTime.parse(opening.time);

    return ListTile(
      title: Text(opening.name!),
      subtitle: Text('Opened on ${DateFormat('yyyy-MM-dd').format(time)} at ${DateFormat('hh:mm:ss').format(time)}'),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [Icon(Icons.vpn_key)],
      ),
    );
  }
}