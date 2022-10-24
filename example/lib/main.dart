import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:terra_flutter_rt/terra_flutter_rt.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

void dataCallback(String data) {
  print("Got data in app");
  print(data);
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
    const apiKey = '';
    const devId = '';
    const connection = Connection.ble;
    const datatypes = [DataType.heartRate];

    // sdk and websocket tokens (DO THIS IN YOUR BACKEND)
    var sdktoken = '';
    var websockettoken = '';
    var headers = {'x-api-key': apiKey, 'dev-id': devId};
    var websocketrequest = http.Request(
        'POST', Uri.parse('https://ws.tryterra.co/auth/user?id=<USERID>'));
    var sdkrequest = http.Request(
        'POST', Uri.parse('https://api.tryterra.co/v2/auth/generateAuthToken'));
    websocketrequest.headers.addAll(headers);
    http.StreamedResponse websocketresponse = await websocketrequest.send();
    if (websocketresponse.statusCode == 200) {
      websockettoken =
          json.decode(await websocketresponse.stream.bytesToString())['token'];
      print(websockettoken);
    } else {
      print(websocketresponse.reasonPhrase);
    }
    sdkrequest.headers.addAll(headers);
    http.StreamedResponse sdkresponse = await sdkrequest.send();
    if (sdkresponse.statusCode == 200) {
      sdktoken = json.decode(await sdkresponse.stream.bytesToString())['token'];
      print(sdktoken);
    } else {
      print(sdkresponse.reasonPhrase);
    }

    // Platform version - visual state confirmation
    String platformVersion;
    try {
      platformVersion =
          await TerraFlutterRt.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    // // Initialise the library
    await TerraFlutterRt.init(devId, "reference_id_flutter");
    // // Need to run this once only to register the device with Terra
    await TerraFlutterRt.initConnection(sdktoken);
    // // For BLE or WearOS connection, pull scanning widget to select a device
    if (connection == Connection.ble || connection == Connection.wearOs) {
      await TerraFlutterRt.startBluetoothScan(connection);
    }
    // // For ANT connection scan to select device
    if (connection == Connection.ant) {
      await TerraFlutterRt.startAntPlusScan();
    }
    // // Start streaming either to server (using token) or locally (using callback)
    print("Starting streaming");
    await TerraFlutterRt.startRealtimeToApp(
        connection, datatypes, dataCallback);
    // await TerraFlutterRt.startRealtimeToServer(
    // connection, datatypes, websockettoken);

    // After 15 seconds stop streaming and disconnect
    await Future.delayed(const Duration(seconds: 15));
    print("Stopping streaming");
    await TerraFlutterRt.stopRealtime(connection);
    await TerraFlutterRt.disconnect(connection);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            // iOSScanView() is required since apple doesn't have context access
            children: [Text('Running on: $_platformVersion\n'), iOSScanView()],
          ),
        ),
      ),
    );
  }
}
