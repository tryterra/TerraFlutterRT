# terra_flutter_rt

A new flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

##  Using the package

The Terra Real Time package offers the capability to stream data either in your app directly using a callback function, or to your server using websockets.

Import the package in your app file:

```dart
import 'package:terra_flutter_rt/terra_flutter_rt.dart';
import 'package:terra_flutter_rt/types.dart';
import 'package:terra_flutter_rt/ios_controller.dart';
```

The first line is for all the functionality. The types are for the different data types (connections, requested data types, and received data type). The iOS controller is for the iOS scanning controller UI.

Everytime your app opens, you need to initialise the library:

```dart
await TerraFlutterRt.init(devId, "reference_id");
```

The first time ever you want to use the package, you need to register the device with Terra using `initConnection`. You can generate an SDK token from [here](https://docs.tryterra.co/reference/generate-authentication-token) using your Terra dev credentatials:

```dart
await TerraFlutterRt.initConnection(sdktoken);
```

and then get the user id using `getUserId`

```dart
const userId = await TerraFlutterRt.getUserId();
```


The packages support streaming from the following wearable types:

```dart
enum Connection { ble, apple, wearOs, android, ant }
```

and supports streaming the following data types:

```dart
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
```

An example using a connection and a set of data to be streamed:

```dart
const connection = Connection.ble;
const datatypes = [DataType.heartRate];
```

For BLE connections, you can pull a BLE scanning UI for the user to select a device:

```dart
if (connection == Connection.ble || connection == Connection.wearOs) {
    await TerraFlutterRt.startBluetoothScan(connection);
}
```

you can optionally cache the devices. If set to true, this options will not pull the BLE scan screen if one of the cached devices is found:

```dart
await TerraFlutterRt.startBluetoothScan(connection, useCache: true);
```

The same applies to ANT devices:
```dart
if (connection == Connection.ant) {
    await TerraFlutterRt.startAntPlusScan();
}
```

With the device and dataypes set, you can now start streaming. To stream locally in your app directly, you can pass a callback function that will get triggered with the data:

```dart
void dataCallback(Update data) {
  print("Got data in app");
  print(data.ts);
  print(data.type.datatypeString);
  print(data.val);
  print(data.d);
}

// .......
await TerraFlutterRt.startRealtimeToApp(connection, datatypes, dataCallback);
```

Example payloads:

```json
{"val":86,"type":"HEART_RATE","ts":"2022-10-24T09:15:25Z"}

{"d":[1.373291015625E-4,-3.96728515625E-4,-1.068115234375E-4],"ts":"2022-10-24T09:20:27.985Z","type":"GYROSCOPE"}
```

To stream to your server using Websockets, you need a websocket token generated from [here](https://docs.tryterra.co/reference/generate-user-token):

```dart
await TerraFlutterRt.startRealtimeToServer(connection, datatypes, websockettoken);
```

Example payloads:

```json
{"op":5,"d":{"ts":"2022-10-24T09:18:27.729Z","val":83.0},"uid":"66fbb25f-e1d2-44d1-bc4d-6b4844bd0928","seq":16073,"t":"HEART_RATE"}

{"op":5,"d":{"d":[0.0049285888671875,-3.662109375E-4,-2.899169921875E-4],"ts":"2022-10-24T09:19:06.328Z"},"uid":"66fbb25f-e1d2-44d1-bc4d-6b4844bd0928","seq":16088,"t":"GYROSCOPE"}
```

Finally, you can stop streaming and disconnect the device on command:

```dart
await TerraFlutterRt.stopRealtime(connection);
await TerraFlutterRt.disconnect(connection);
```
