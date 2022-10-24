import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:terra_flutter_rt/terra_flutter_rt.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef FlutterWebViewCreatedCallback = void Function(
    WebViewController controller);

class WebView extends StatelessWidget {
  final FlutterWebViewCreatedCallback onMapViewCreated;
  const WebView({Key? key, required this.onMapViewCreated}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: 'terra_flutter_rt',
          onPlatformViewCreated: _onPlatformViewCreated,
        );
      default:
        return Text(
            '$defaultTargetPlatform is not yet supported by the web_view plugin');
    }
  }

  // Callback method when platform view is created
  void _onPlatformViewCreated(int id) =>
      onMapViewCreated(WebViewController._(id));
}

// WebView Controller class to set url etc
class WebViewController {
  WebViewController._(int id)
      : _channel = MethodChannel('terra_flutter_rt_$id');

  final MethodChannel _channel;

  Future<void> setUrl({required String url}) async {
    return _channel.invokeMethod('setUrl', url);
  }
}

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
            'https://ws.tryterra.co/auth/user?id=<USER ID>'));

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      token = json.decode(await response.stream.bytesToString())['token'];
      print('got token!');
    } else {
      print(response.reasonPhrase);
    }

    // Real-time
    await TerraFlutterRt.init();
    await TerraFlutterRt.initConnection(connection);
    if (connection == Connection.ble || connection == Connection.wearOs)
      print(await TerraFlutterRt.startBluetoothScan(connection));
    if (connection == Connection.ant)
      print(await TerraFlutterRt.startAntPlusScan());
    print(await TerraFlutterRt.startRealtime(connection, token, datatypes));
    await Future.delayed(const Duration(seconds: 5));
    await TerraFlutterRt.stopRealtime(connection);
    await TerraFlutterRt.disconnect(connection);
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  late final WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              WebView(onMapViewCreated: _onMapViewCreated)
            ],
          ),
        ),
      ),
    );
  }

  void _onMapViewCreated(WebViewController controller) {
    _webViewController = controller;
    controller.setUrl(url: "www.google.com");
  }
}
