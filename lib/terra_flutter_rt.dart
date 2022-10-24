// ignore_for_file: camel_case_types

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// streaming connections
enum Connection { ble, apple, wearOs, android, ant }

extension ConnectionExtension on Connection {
  String get connectionString {
    switch (this) {
      case Connection.android:
        return 'ANDROID';
      case Connection.ant:
        return 'ANT';
      case Connection.apple:
        return 'APPLE';
      case Connection.ble:
        return 'BLE';
      case Connection.wearOs:
        return 'WEAR_OS';
      default:
        return 'UNDEFINED';
    }
  }
}

// streaming data types
enum DataType {
  heartRate,
  ecg,
  steps,
  hrv,
  calories,
  location,
  speed,
  distance,
  stepsCadence,
  floorsClimbed,
  gyroscope,
  acceleration
}

extension DataTypeExtension on DataType {
  String get datatypeString {
    switch (this) {
      case DataType.heartRate:
        return "HEART_RATE";
      case DataType.ecg:
        return "ECG";
      case DataType.steps:
        return "STEPS";
      case DataType.hrv:
        return "HRV";
      case DataType.calories:
        return "CALORIES";
      case DataType.location:
        return "LOCATION";
      case DataType.speed:
        return "SPEED";
      case DataType.distance:
        return "DISTANCE";
      case DataType.stepsCadence:
        return "STEPS_CADENCE";
      case DataType.floorsClimbed:
        return "FLOORS_CLIMBED";
      case DataType.gyroscope:
        return "GYROSCOPE";
      case DataType.acceleration:
        return "ACCELERATION";
      default:
        return 'UNDEFINED';
    }
  }
}

typedef UpdateCallback = void Function(String);

class TerraFlutterRt {
  static UpdateCallback? _callback;
  static const MethodChannel _channel = MethodChannel('terra_flutter_rt');

  static Future<String?> get platformVersion async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController._channel
            .invokeMethod('getPlatformVersion', {});
      case TargetPlatform.android:
        return await _channel.invokeMethod('getPlatformVersion', {});
      default:
        return "UNKNOWN";
    }
  }

  static Future<bool?> init(String devId, String? referenceId) async {
    _channel.setMethodCallHandler(myUtilsHandler);
    _iOSScanController._channel.setMethodCallHandler(myUtilsHandler);
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController._channel
            .invokeMethod('init', {"devId": devId, "referenceId": referenceId});
      case TargetPlatform.android:
        return await _channel
            .invokeMethod('init', {"devId": devId, "referenceId": referenceId});
      default:
        return false;
    }
  }

  static Future<bool?> initConnection(String token) async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController._channel
            .invokeMethod('initConnection', {"token": token});
      case TargetPlatform.android:
        return await _channel.invokeMethod('initConnection', {"token": token});
      default:
        return false;
    }
  }

  static Future<bool?> startRealtimeToServer(
      Connection connection, List<DataType> types, String token) async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController._channel
            .invokeMethod('startRealtimeToServer', {
          "connection": connection.connectionString,
          "token": token,
          "datatypes": types.map((t) => t.datatypeString).toList()
        });
      case TargetPlatform.android:
        return await _channel.invokeMethod('startRealtimeToServer', {
          "connection": connection.connectionString,
          "token": token,
          "datatypes": types.map((t) => t.datatypeString).toList()
        });
      default:
        return false;
    }
  }

  static Future<bool?> startRealtimeToApp(Connection connection,
      List<DataType> types, UpdateCallback callback) async {
    _callback = callback;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController._channel
            .invokeMethod('startRealtimeToApp', {
          "connection": connection.connectionString,
          "datatypes": types.map((t) => t.datatypeString).toList()
        });
      case TargetPlatform.android:
        return await _channel.invokeMethod('startRealtimeToApp', {
          "connection": connection.connectionString,
          "datatypes": types.map((t) => t.datatypeString).toList()
        });
      default:
        return false;
    }
  }

  static Future<bool?> stopRealtime(Connection connection) async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController._channel.invokeMethod(
            'stopRealtime', {"connection": connection.connectionString});
      case TargetPlatform.android:
        return await _channel.invokeMethod(
            'stopRealtime', {"connection": connection.connectionString});
      default:
        return false;
    }
  }

  static Future<bool?> disconnect(Connection connection) async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController._channel.invokeMethod(
            'disconnect', {"connection": connection.connectionString});
      case TargetPlatform.android:
        return await _channel.invokeMethod(
            'disconnect', {"connection": connection.connectionString});
      default:
        return false;
    }
  }

  static Future<bool?> startBluetoothScan(Connection connection) async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController._channel.invokeMethod(
            'startBluetoothScan', {"connection": connection.connectionString});
      case TargetPlatform.android:
        return await _channel.invokeMethod(
            'startBluetoothScan', {"connection": connection.connectionString});
      default:
        return false;
    }
  }

  static Future<bool?> startAntPlusScan() async {
    final bool? complete = await _channel.invokeMethod('startAntPlusScan', {});
    return complete;
  }

  static Future<dynamic> myUtilsHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'update':
        print('Update got called');
        if (_callback != null) {
          _callback!(methodCall.arguments);
        }
        return true;
      default:
        throw MissingPluginException('notImplemented');
    }
  }
}

class iOSScanController {
  iOSScanController._(int id)
      : _channel = MethodChannel('terra_flutter_rt_$id');

  final MethodChannel _channel;
}

typedef iOSScanControllerCreatedCallback = void Function(
    iOSScanController controller);

final iOSScanController _iOSScanController = iOSScanController._(0);

class iOSScanView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return Expanded(child: UiKitView(viewType: 'terra_flutter_rt'));

      default:
        return Container();
    }
  }
}
