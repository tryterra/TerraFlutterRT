enum Connection { ble, apple, wearOs, android, ant, allDevices }

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
      case Connection.allDevices:
        return 'ALL_DEVICES';
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

DataType datatypeTyped(String s) {
  switch (s) {
    case "HEART_RATE":
      return DataType.heartRate;
    case "ECG":
      return DataType.ecg;
    case "STEPS":
      return DataType.steps;
    case "HRV":
      return DataType.hrv;
    case "CALORIES":
      return DataType.calories;
    case "LOCATION":
      return DataType.location;
    case "SPEED":
      return DataType.speed;
    case "DISTANCE":
      return DataType.distance;
    case "STEPS_CADENCE":
      return DataType.stepsCadence;
    case "FLOORS_CLIMBED":
      return DataType.floorsClimbed;
    case "GYROSCOPE":
      return DataType.gyroscope;
    case "ACCELERATION":
      return DataType.acceleration;
    default:
      throw Exception('InvalidType');
  }
}

// update type
class Update {
  final String ts;
  final DataType type;
  final double? val;
  final List<double>? d;

  Update(this.ts, this.type, this.val, this.d);

  Update.fromJson(Map<String, dynamic> json)
      : ts = json['ts'],
        type = datatypeTyped(json['type']),
        val = json.containsKey('val') ? (json['val']).toDouble() : null,
        d = json.containsKey('d')
            ? (json['d'] as List).map((i) => i as double).toList()
            : null;
}

class Device {
  final String deviceId;
  final String deviceName;

  Device(this.deviceId, this.deviceName);

  Device.fromJson(Map<String, dynamic> json)
      : deviceId = json["deviceId"],
        deviceName = json["deviceName"];
}
