import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:terra_flutter_rt/types.dart';
import 'package:terra_flutter_rt/ios_controller.dart';

typedef UpdateCallback = void Function(Update);
final iOSScanController _iOSScanController = iOSScanController.init(0);

class TerraFlutterRt {
  static UpdateCallback? _callback;
  static const MethodChannel _channel = MethodChannel('terra_flutter_rt');

  static Future<String?> get platformVersion async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController.channel
            .invokeMethod('getPlatformVersion', {});
      case TargetPlatform.android:
        return await _channel.invokeMethod('getPlatformVersion', {});
      default:
        return "UNKNOWN";
    }
  }

  static Future<bool?> init(String devId, String? referenceId) async {
    _channel.setMethodCallHandler(myUtilsHandler);
    _iOSScanController.channel.setMethodCallHandler(myUtilsHandler);
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController.channel
            .invokeMethod('init', {"devId": devId, "referenceId": referenceId});
      case TargetPlatform.android:
        return await _channel
            .invokeMethod('init', {"devId": devId, "referenceId": referenceId});
      default:
        return null;
    }
  }

  static Future<bool?> initConnection(String token) async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController.channel
            .invokeMethod('initConnection', {"token": token});
      case TargetPlatform.android:
        return await _channel.invokeMethod('initConnection', {"token": token});
      default:
        return null;
    }
  }

  static Future<bool?> startRealtimeToServer(
      Connection connection, List<DataType> types, String token) async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController.channel
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
        return null;
    }
  }

  static Future<bool?> startRealtimeToApp(Connection connection,
      List<DataType> types, UpdateCallback callback) async {
    _callback = callback;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController.channel
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
        return null;
    }
  }

  static Future<bool?> stopRealtime(Connection connection) async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController.channel.invokeMethod(
            'stopRealtime', {"connection": connection.connectionString});
      case TargetPlatform.android:
        return await _channel.invokeMethod(
            'stopRealtime', {"connection": connection.connectionString});
      default:
        return null;
    }
  }

  static Future<bool?> disconnect(Connection connection) async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController.channel.invokeMethod(
            'disconnect', {"connection": connection.connectionString});
      case TargetPlatform.android:
        return await _channel.invokeMethod(
            'disconnect', {"connection": connection.connectionString});
      default:
        return null;
    }
  }

  static Future<String?> getUserId() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await _iOSScanController.channel.invokeMethod('getUserId', {});
      case TargetPlatform.android:
        return await _channel.invokeMethod('getUserId', {});
      default:
        return null;
    }
  }

  static Future<bool?> startDeviceScan(Connection connection,
      {bool useCache = false}) async {
    bool? output;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        output = await _iOSScanController.channel
            .invokeMethod('startBluetoothScan', {
          "connection": connection == Connection.allDevices
              ? Connection.ble
              : connection.connectionString,
          "useCache": useCache
        });
        await Future.delayed(const Duration(seconds: 1));
        return output;
      case TargetPlatform.android:
        output = await _channel.invokeMethod('startDeviceScan',
            {"connection": connection.connectionString, "useCache": useCache});
        await Future.delayed(const Duration(seconds: 1));
        return output;
      default:
        return null;
    }
  }

  static Future<dynamic> myUtilsHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'update':
        if (_callback != null) {
          Map<String, dynamic> updateMap = jsonDecode(methodCall.arguments);
          var update = Update.fromJson(updateMap);
          _callback!(update);
        }
        return true;
      default:
        throw MissingPluginException('notImplemented');
    }
  }
}
