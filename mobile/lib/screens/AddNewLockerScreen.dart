import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nlocker/components/DropDownList.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

enum AddNewLockerViewType {
  connectToAccessPointRequest,
  connectionForm,
  waitForResponse,
  connectedSuccessfully,
  connectionError
}

class AddNewLockerScreen extends StatefulWidget {
  const AddNewLockerScreen({ Key? key }): super(key: key);

  @override
  State<StatefulWidget> createState() => _AddNewLockerScreen();
}

class _AddNewLockerScreen extends State<AddNewLockerScreen> {
  AddNewLockerViewType viewType = AddNewLockerViewType.connectToAccessPointRequest;

  Widget getCurrentWidget() {
    switch (viewType) {
      case AddNewLockerViewType.connectToAccessPointRequest:
        return ConnectToAccessPointRequest(callback: () {
          setState(() {
            viewType = AddNewLockerViewType.connectionForm;
          });
        });
      case AddNewLockerViewType.connectionForm:
        return LockerAddForm(callback: () {
          setState(() {
            viewType = AddNewLockerViewType.waitForResponse;
          });
        });
      case AddNewLockerViewType.waitForResponse:
        return WaitForResponse(callback: () {
          setState(() {
            viewType = AddNewLockerViewType.connectedSuccessfully;
          });
        });
      case AddNewLockerViewType.connectedSuccessfully:
        return ConnectedSuccessfully(callback: () {
          Navigator.pop(context);
        });
      case AddNewLockerViewType.connectionError:
        return ConnectionError(callback: () {
          Navigator.pop(context);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add a new locker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: getCurrentWidget()
      )
    );
  }
}

class ConnectToAccessPointRequest extends StatefulWidget {
  final callback;

  const ConnectToAccessPointRequest({ Key? key, required this.callback }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConnectToAccessPointRequest();
  }
}

class _ConnectToAccessPointRequest extends State<ConnectToAccessPointRequest> {
  late Timer timer;

  @override
  void initState() {
    super.initState();

    (() async {
      var status = await Permission.location.request();

      if (status.isGranted) {
        int i = 0;
        timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          String? name = await WifiInfo().getWifiName();
          if (/*name!.contains('HUAWEI')*/ true) {
            widget.callback();
            timer.cancel();
          }
        });
      } else {
        Navigator.pop(context);
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Center(
            child: Text(
              'Please connect to your NLocker Wi-Fi network',
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SpinKitFoldingCube(
          color: Colors.blue,
          size: 30
        )
      ],
    );
  }
}

class LockerAddForm extends StatelessWidget {
  final callback;
  final _formKey = GlobalKey<FormState>();

  LockerAddForm({ Key? key, required this.callback }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Center(
                            child: Text('Choose the network from the dropdown list and type the password in the input below.'
                                'Then click the button. After you do it, wait for a while and read a message on locker\'s screen.',
                              textAlign: TextAlign.justify,
                            )
                        )
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: DropDownList(
                        options: [
                          'Network A',
                          'Network B',
                          'Network C',
                          'Network D',
                          'Network E',
                          'Network F',
                          'Network G',
                        ],
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'Password'
                          ),
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return 'Type a valid password';
                            } else {
                              return null;
                            }
                          },
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        child: const Padding(
                          padding: EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
                          child: Text(
                            'Add locker'
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            callback();
                          }
                        },
                      ),
                    ),
                  ]
              )
            )
          ],
        )
      )
    );
  }
}

class WaitForResponse extends StatefulWidget {
  final callback;

  const WaitForResponse({ Key? key, required this.callback }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WaitForResponse();
  }
}

class _WaitForResponse extends State<WaitForResponse> {
  late Timer timer;
  
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      widget.callback();
      timer.cancel();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Center(
            child: Text(
              'Please wait for a while',
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SpinKitFoldingCube(
            color: Colors.blue,
            size: 30
        )
      ],
    );
  }
}

class ConnectedSuccessfully extends StatelessWidget {
  final callback;
  const ConnectedSuccessfully({ Key? key, required this.callback }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
         child: Text('Connected successfully'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ElevatedButton(
            onPressed: callback,
            child: const Padding(
              padding: EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
              child: Text(
                'Return'
              ),
            )
          ),
        ),
      ],
    );
  }
}

class ConnectionError extends StatelessWidget {
  final callback;
  const ConnectionError({ Key? key, required this.callback }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text('Connection Error'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ElevatedButton(
              onPressed: callback,
              child: const Padding(
                padding: EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
                child: Text(
                  'Return'
                ),
              )
          ),
        ),
      ],
    );
  }
}

