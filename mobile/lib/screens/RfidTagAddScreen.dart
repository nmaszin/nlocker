import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nlocker/components/FormCheckbox.dart';
import 'package:http/http.dart' as http;
import 'package:nlocker/models/Locker.dart';
import 'package:nlocker/models/RfidTag.dart';

import '../SecureStorage.dart';

class RfidTagAddScreen extends StatefulWidget {
  final Locker locker;

  const RfidTagAddScreen({ Key? key, required this.locker }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RfidTagAddScreen();
  }
}

class _RfidTagAddScreen extends State<RfidTagAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();

  Timer? timer;
  Future<RfidTag>? rfidFuture;

  Future<RfidTag> postRfid() async {
    final token = await secureStorage.read(key: 'auth-token');
    final url = '${dotenv.env['API_URL']}/lockers/${widget.locker.id}/rfids';
    final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(<String, String> {
          'name': _name.text
        }),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        }
    );

    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 201) {
      return RfidTag.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Something went wrong');
    }
  }

  @override
  void initState() {
    super.initState();

    /*timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      timer.cancel();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new RFID tag'),
      ),
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
                      const  Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Text(
                          'To add new RFID tag type it\'s name below and tap your tag to the locker',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: TextFormField(
                            controller: _name,
                            readOnly: rfidFuture != null,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                fillColor: Colors.white,
                                filled: true,
                                hintText: 'Type the new RFID tag name'
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'The name is empty';
                              } else {
                                return null;
                              }
                            },
                          )
                      ),
                      rfidFuture == null ? Container() : FutureBuilder<RfidTag>(
                        future: rfidFuture!,
                        builder: (context, snapshot) {
                          final title = snapshot.hasError ? 'The locker is disconnected' : (snapshot.hasData ? 'Card paired successfully!' : 'Waiting for card tap');
                          final icon = snapshot.hasError ? const Icon(Icons.close, color: Colors.red) : (snapshot.hasData ? const Icon(Icons.check, color: Colors.green) : const SpinKitCircle(color: Colors.blue, size: 20));

                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: icon
                                  )
                                ],
                              )
                          );
                        }
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          child: const Padding(
                            padding: EdgeInsets.all(15),
                            child: Text('Confirm'),
                          ),
                          onPressed: rfidFuture != null ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                rfidFuture = postRfid();
                              });
                            }
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}
