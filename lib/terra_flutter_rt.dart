import 'dart:async';

import 'package:flutter/services.dart';

// streaming connections
enum Connection { ble, apple, googleFit, wearOs, android, ant }

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
      case Connection.googleFit:
        return 'GOOGLE_FIT';
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

class TerraFlutterRt {
  static const MethodChannel _channel = MethodChannel('terra_flutter_rt');

  static Future<String?> get platformVersion async {
    final String? version =
        await _channel.invokeMethod('getPlatformVersion', {});
    return version;
  }

  static Future<bool?> init() async {
    final bool? complete = await _channel.invokeMethod('init', {});
    return complete;
  }

  static Future<bool?> initConnection(Connection connection) async {
    final bool? complete = await _channel.invokeMethod(
        'initConnection', {"connection": connection.connectionString});
    return complete;
  }

  static Future<bool?> startRealtime(
      Connection connection, String token, List<DataType> types) async {
    final bool? complete = await _channel.invokeMethod('startRealtime', {
      "connection": connection.connectionString,
      "token": token,
      "datatypes": types.map((t) => t.datatypeString).toList()
    });
    return complete;
  }

  static Future<bool?> stopRealtime(Connection connection) async {
    final bool? complete = await _channel.invokeMethod(
        'stopRealtime', {"connection": connection.connectionString});
    return complete;
  }

  static Future<bool?> disconnect(Connection connection) async {
    final bool? complete = await _channel.invokeMethod(
        'disconnect', {"connection": connection.connectionString});
    return complete;
  }

  static Future<bool?> startBluetoothScan(Connection connection) async {
    final bool? complete = await _channel.invokeMethod(
        'startBluetoothScan', {"connection": connection.connectionString});
    return complete;
  }

  static Future<bool?> startAntPlusScan() async {
    final bool? complete = await _channel.invokeMethod(
        'startAntPlusScan', {});
    return complete;
  }
}

// terraRT.startBluetoothScan(type: Connections, callback: (Boolean) -> Unit)
