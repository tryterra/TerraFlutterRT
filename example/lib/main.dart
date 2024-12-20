import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:terra_flutter_rt/terra_flutter_rt.dart';
import 'package:terra_flutter_rt/types.dart';
import 'package:terra_flutter_rt/ios_controller.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

void dataCallback(Update data) {
  print("Got data in app");
  print(data.ts);
  print(data.type.datatypeString);
  print(data.val);
  print(data.d);
}

void deviceCallback(Device d) async{
  print("Device found");
  print(d.deviceName);
  //print(d.deviceId);
  if (d.deviceName == "WHOOP 4A0834169"){
    bool? connect = await TerraFlutterRt.connectDevice(d);
    print(connect);
    const connection = Connection.ble;
    const datatypes = [DataType.heartRate];
    await TerraFlutterRt.startRealtimeToApp(
    connection, datatypes, dataCallback);
    // await TerraFlutterRt.startRealtimeToServer(
    //     connection, datatypes, websockettoken);

    // After 15 seconds stop streaming and disconnect
    await Future.delayed(const Duration(seconds: 15));
    await TerraFlutterRt.stopRealtime(connection);
    await TerraFlutterRt.disconnect(connection);
  }
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
    var headers = {'x-api-key': apiKey, 'dev-id': devId};
    const connection = Connection.ble;
    const datatypes = [DataType.heartRate];
    
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
  
  
    // Initialise the library
    await TerraFlutterRt.init(devId, "reference_id_flutter");

    // Need to run this once only to register the device with Terra
    // sdk token (DO THIS IN YOUR BACKEND)
    var sdktoken = '';
    var sdkrequest = http.Request(
        'POST', Uri.parse('https://api.tryterra.co/v2/auth/generateAuthToken'));
    sdkrequest.headers.addAll(headers);
    http.StreamedResponse sdkresponse = await sdkrequest.send();
    if (sdkresponse.statusCode == 200) {
      sdktoken = json.decode(await sdkresponse.stream.bytesToString())['token'];
    }

    await TerraFlutterRt.initConnection(sdktoken);

    // If streaming to websocket, need a websocket token
    var websockettoken = '';
    var userId = await TerraFlutterRt.getUserId();
    var websocketrequest = http.Request(
        'POST', Uri.parse('https://ws.tryterra.co/auth/user?id=' + userId!));
    websocketrequest.headers.addAll(headers);
    http.StreamedResponse websocketresponse = await websocketrequest.send();
    if (websocketresponse.statusCode == 200) {
      websockettoken =
          json.decode(await websocketresponse.stream.bytesToString())['token'];
    }

    // For BLE or WearOS connection, pull scanning widget to select a device
    if (connection == Connection.ble ||
        connection == Connection.wearOs ||
        connection == Connection.ant ||
        connection == Connection.allDevices) {
      await TerraFlutterRt.startDeviceScan(connection);
    }

    // Start streaming either to server (using token) or locally (using callback)
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
            children: [Text('Running on: $_platformVersion\n'),  iOSScanView()],
          ),
        ),
      ),
    );
  }
}
