import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:terra_flutter_rt/terra_flutter_rt.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    print("Setting platform");
    try {
      platformVersion =
          await TerraFlutterRt.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    const apiKey = '';
    const devId = '';
    const connection = Connection.ble;
    const datatypes = [DataType.heartRate];

    // token (DO THIS IN YOUR BACKEND)
    var token = '';
    var headers = {'x-api-key': apiKey, 'dev-id': devId};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://ws.tryterra.co/auth/user?id=66fbb25f-e1d2-44d1-bc4d-6b4844bd0928'));

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      token = json.decode(await response.stream.bytesToString())['token'];
      print('got token!');
    } else {
      print(response.reasonPhrase);
    }

    // Real-time
    print("Entering TerraRT");
    await TerraFlutterRt.init();
    print("Initialised");
    await TerraFlutterRt.initConnection(connection);
    if (connection == Connection.ble || connection == Connection.wearOs)
      print(await TerraFlutterRt.startBluetoothScan(connection));
    if (connection == Connection.ant)
      print(await TerraFlutterRt.startAntPlusScan());
    print("Connected");
    print(await TerraFlutterRt.startRealtime(connection, token, datatypes));
    print("Should be streaming");
    await Future.delayed(const Duration(seconds: 5));
    await TerraFlutterRt.stopRealtime(connection);
    print("Should've stopped streaming");
    await TerraFlutterRt.disconnect(connection);
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
