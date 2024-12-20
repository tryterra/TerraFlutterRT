package co.tryterra.terra_flutter_rt;

import androidx.annotation.NonNull;

import android.content.Context;
import android.os.Looper;
import android.os.Handler;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Objects;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;

import co.tryterra.terrartandroid.TerraRT;
import co.tryterra.terrartandroid.enums.Connections;
import co.tryterra.terrartandroid.enums.DataTypes;
import co.tryterra.terrartandroid.models.Update;
import co.tryterra.terrartandroid.Device;

import kotlin.Unit;

import com.google.gson.Gson;

/** TerraFlutterRtPlugin */
public class TerraFlutterRtPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context context;
  private FlutterActivity activity = null;
  private BinaryMessenger binaryMessenger = null;

  public TerraRT terraRT;

  private static HashMap<String, Device> deviceMap = new HashMap<>();
  private Gson gson = new Gson();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    binaryMessenger = flutterPluginBinding.getBinaryMessenger();
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    this.context = (Context) binding.getActivity();
    channel = new MethodChannel(binaryMessenger, "terra_flutter_rt");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {}

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {}

  @Override
  public void onDetachedFromActivity() {}

  private Connections parseConnection(String connection) {
    switch (connection) {
      case "ANDROID":
        return Connections.ANDROID;
      case "ANT":
        return Connections.ANT;
      case "BLE":
        return Connections.BLE;
      case "WEAR_OS":
        return Connections.WEAR_OS;
      case "ALL_DEVICES":
        return Connections.ALL_DEVICES;
    }
    return null;
  }

  private DataTypes parseDatatype(String dataType) {
    switch (dataType) {
      case "HEART_RATE":
        return DataTypes.HEART_RATE;
      case "ECG":
        return DataTypes.ECG;
      case "STEPS":
        return DataTypes.STEPS;
      case "HRV":
        return DataTypes.HRV;
      case "CALORIES":
        return DataTypes.CALORIES;
      case "LOCATION":
        return DataTypes.LOCATION;
      case "SPEED":
        return DataTypes.SPEED;
      case "DISTANCE":
        return DataTypes.DISTANCE;
      case "STEPS_CADENCE":
        return DataTypes.STEPS_CADENCE;
      case "FLOORS_CLIMBED":
        return DataTypes.FLOORS_CLIMBED;
      case "GYROSCOPE":
        return DataTypes.GYROSCOPE;
      case "ACCELERATION":
        return DataTypes.ACCELERATION;
      default:
        return null;
    }
  }

  private void initConnection(
    String token,
    Result result
  ) {
    this.terraRT.initConnection(
      token,
      (success) -> {
        result.success(success);
        return Unit.INSTANCE;
      }
    );
  }

  private void startRealtime(
    String connection,
    String token,
    ArrayList<String> datatypes,
    Result result
  ) {
    if (parseConnection(connection) == null) {
      result.error("Connection Failure", "Invalid Connection has been passed for the android platform", null);
      return;
    }

    HashSet<DataTypes> parsedDatatypes = new HashSet<>();
    for (Object datatype: datatypes) {
        if (datatype == null) {
            continue;
        }
        parsedDatatypes.add(parseDatatype((String) datatype));
    }

    this.terraRT.startRealtime(
      Objects.requireNonNull(parseConnection(connection)),
      token,
      parsedDatatypes,
      (ignored) -> {
        return Unit.INSTANCE;
      }
    );
    result.success(true);
  }

  private void startRealtime(
    String connection,
    ArrayList<String> datatypes,
    Result result
  ) {
    if (parseConnection(connection) == null) {
      result.error("Connection Failure", "Invalid Connection has been passed for the android platform", null);
      return;
    }

    HashSet<DataTypes> parsedDatatypes = new HashSet<>();
    for (Object datatype: datatypes) {
        if (datatype == null) {
            continue;
        }
        parsedDatatypes.add(parseDatatype((String) datatype));
    }

    this.terraRT.startRealtime(
      Objects.requireNonNull(parseConnection(connection)),
      parsedDatatypes,
      (success) -> {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
          @Override
          public void run() {
            callChannel(success);
          }
        });
        return Unit.INSTANCE;
      }
    );
    result.success(true);
  }

  private void stopRealtime(
    String connection,
    Result result
  ) {
    if (parseConnection(connection) == null) {
      result.error("Connection Failure", "Invalid Connection has been passed for the android platform", null);
      return;
    }
    this.terraRT.stopRealtime(Objects.requireNonNull(parseConnection(connection)));
    result.success(true);
  }

  private void disconnect(
    String connection,
    Result result
  ) {
    if (parseConnection(connection) == null) {
      result.error("Connection Failure", "Invalid Connection has been passed for the android platform", null);
      return;
    }
    this.terraRT.disconnect(Objects.requireNonNull(parseConnection(connection)));
    result.success(true);
  }

  private void startDeviceScan(
    String connection,
    boolean useCache,
    Result result
  ) {
    if (parseConnection(connection) == null) {
      result.error("Connection Failure", "Invalid Connection has been passed for the android platform", null);
      return;
    }
    this.terraRT.startDeviceScan(
      Objects.requireNonNull(parseConnection(connection)),
      useCache,
      true,
      (success) -> {
        result.success(success);
        return Unit.INSTANCE;
      }
    );
  }

  private void connectDevice(
    String deviceName,
    Result result
  ){
    Device device = deviceMap.get(deviceName);

    if (device == null){
      result.success(false);
      return;
    }

    this.terraRT.connectDevice(device, (success) -> {
      result.success(success);
      return Unit.INSTANCE;
    });
  }

  private void startDeviceScan(
    String connection,
    Result result
  ){
    if (parseConnection(connection) == null) {
      result.error("Connection Failure", "Invalid Connection has been passed for the android platform", null);
      return;
    }
    this.terraRT.startDeviceScan(
      Objects.requireNonNull(parseConnection(connection)),
      (Device device) -> {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
          @Override
          public void run() {
            deviceMap.put(device.getDeviceName(), device);
            deviceChannel(device);
          }
        });
        return Unit.INSTANCE;
      }
    );
    result.success(true);
  }

  private void callChannel(Object a){
    this.channel.invokeMethod("update", gson.toJson(a), new Result() {
      @Override
      public void success(Object o) {}
      @Override
      public void error(String s, String s1, Object o) {}
      @Override
      public void notImplemented() {}
    });
  }

  private void deviceChannel(Object a){
    this.channel.invokeMethod("device", gson.toJson(a), new Result() {
      @Override
      public void success(Object o) {}
      @Override
      public void error(String s, String s1, Object o) {}
      @Override
      public void notImplemented() {}
    });
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "init":
        this.terraRT = new TerraRT (
          call.argument("devId"),
          Objects.requireNonNull(this.context),
          call.argument("referenceId"),
          (success) -> {
            result.success(success);
            return Unit.INSTANCE;
          }
        );
        break;
      case "initConnection":
        initConnection(
          call.argument("token"),
          result
        );
        break;
      case "startRealtimeToServer":
        startRealtime(
          call.argument("connection"),
          call.argument("token"),
          call.argument("datatypes"),
          result
        );
        break;
      case "startRealtimeToApp":
        startRealtime(
          call.argument("connection"),
          call.argument("datatypes"),
          result
        );
        break;
      case "stopRealtime":
        stopRealtime(
          call.argument("connection"),
          result
        );
        break;
      case "getUserId":
        result.success(this.terraRT.getUserId());
        break;
      case "disconnect":
        disconnect(
          call.argument("connection"),
          result
        );
        break;
      case "startDeviceScan":
        startDeviceScan(
          call.argument("connection"),
          call.argument("useCache"),
          result
        );
        break;
      case "startDeviceScanWithCallback":
          startDeviceScan(
            call.argument("connection"),
            result
          );
          break;
      case "connectDevice":
          connectDevice(
            call.argument("deviceName"),
            result
          );
          break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
