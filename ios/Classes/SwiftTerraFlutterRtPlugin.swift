import Flutter
import UIKit
import TerraRTiOS
import Foundation
import SwiftUI

public struct Device_: Codable  {
    init(_ deviceName: String, _ deviceUUID: String){
        self.deviceName = deviceName
        self.deviceUUID = deviceUUID
    }
    
    let deviceName: String
    let deviceUUID: String
}

public class SwiftTerraFlutterRtPlugin: NSObject, FlutterPlugin {
    private static let channelName = "terra_flutter_rt_0"
    private var scanView: FlutteriOSScanView!

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName,
                                           binaryMessenger: registrar.messenger())
        let instance = SwiftTerraFlutterRtPlugin(channel: channel)

        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.register(
            iOSScanViewFactory(scanView: instance.scanView),
            withId: "terra_flutter_rt_0"
        )
    }


    private init(channel: FlutterMethodChannel) {
        super.init()
        self.scanView = FlutteriOSScanView(channel: channel)
    }

    public func handle(_ call: FlutterMethodCall,
                       result: @escaping FlutterResult) {
        scanView.onMethodCall(call: call, result: result)
    }
}

class iOSScanViewFactory: NSObject, FlutterPlatformViewFactory {
  private let sharedScanView: FlutteriOSScanView
  init(scanView: FlutteriOSScanView) { self.sharedScanView = scanView }

  func create(withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?) -> FlutterPlatformView {
    sharedScanView
  }
}

class FlutteriOSScanView: NSObject, FlutterPlatformView {
  
  private let mainview = UIView()
  var scoreLabel = UILabel()

  func view() -> UIView { mainview }
  private let channel: FlutterMethodChannel       

  init(channel: FlutterMethodChannel) {           
      self.channel = channel
      super.init()
  }
  private static var deviceMap: [String: Device] = [:]

  private var terraRT: TerraRT?

  private func connectionParse(connection: String) -> Connections? {
		switch connection {
			case "APPLE":
				return Connections.APPLE
			case "BLE":
				return Connections.BLE
      case "ALL_DEVICES":
				return Connections.BLE
      case "WATCH_OS":
        return Connections.WATCH_OS
			default:
				print("Passed invalid connection")
		}
    	return nil
  }

  private func typeParse(datatype: String) -> Set<DataTypes> {
    switch datatype {
      case "HEART_RATE":
        return Set([DataTypes.HEART_RATE])
      case "ECG":
        return Set([DataTypes.ECG])
      case "STEPS":
        return Set([DataTypes.STEPS])
      case "HRV":
        return Set([DataTypes.HRV])
      case "CALORIES":
        return Set([DataTypes.CALORIES])
      case "LOCATION":
        return Set([DataTypes.LOCATION])
      case "SPEED":
        return Set([DataTypes.SPEED])
      case "STEPS_CADENCE":
        return Set([DataTypes.STEPS_CADENCE])
      case "FLOORS_CLIMBED":
        return Set([DataTypes.FLOORS_CLIMBED])
      case "GYROSCOPE":
        return Set([DataTypes.GYROSCOPE])
      case "ACCELERATION":
        return Set([DataTypes.ACCELERATION])
      case "DISTANCE":
        return Set([DataTypes.DISTANCE])
      default:
        return Set([])
      }
  }

  private func datatypeSet(datatypes: [String]) -> Set<DataTypes> {
    var out: Set<DataTypes> = Set([])
    for datatype in datatypes {
      out.formUnion(typeParse(datatype: datatype))
    }
    return out
  }


  private func initConnection(token: String, result: @escaping FlutterResult){
		if terraRT != nil {
      terraRT!.initConnection(token: token){
        success in result(true)
      }
		} else {
			result(FlutterError(
				code: "Connection Type Error",
				message: "Could not call initConnection. make sure that terraRT is initialised by calling 'init'",
				details: nil
			))
		}
  }

  private func getUserId(result: @escaping FlutterResult){
		if terraRT != nil {
      result(terraRT!.getUserid())
		} else {
			result(FlutterError(
				code: "Connection Type Error",
				message: "Could not call getUserId. make sure that terraRT is initialised by calling 'init'",
				details: nil
			))
		}
  }

  private func startRealtime(
    connection: String,
    token: String,
    datatypes: [String], 
    result: @escaping FlutterResult
  ){
    let c = connectionParse(connection: connection)
		if c != nil && terraRT != nil {
      terraRT!.startRealtime(type: c!, dataType: datatypeSet(datatypes: datatypes), token: token)
      result(true)
		} else {
			result(FlutterError(
				code: "Connection Type Error",
				message: "Could not call startRealtime. make sure you are passing a valid connection and that terraRT is initialised by calling 'init'",
				details: nil
			))
		}
  }

  private func startRealtime(
    connection: String,
    datatypes: [String], 
    result: @escaping FlutterResult
  ){
    let c = connectionParse(connection: connection)
		if c != nil && terraRT != nil {
      terraRT!.startRealtime(type: c!, dataType: datatypeSet(datatypes: datatypes)){
        update in self.callChannel(update: update)
      }
      result(true)
		} else {
			result(FlutterError(
				code: "Connection Type Error",
				message: "Could not call startRealtime. make sure you are passing a valid connection and that terraRT is initialised by calling 'init'",
				details: nil
			))
		}
  }

  private func stopRealtime(connection: String, result: @escaping FlutterResult){
    let c = connectionParse(connection: connection)
		if c != nil && terraRT != nil {
      terraRT!.stopRealtime(type: c!)
      result(true)
		} else {
			result(FlutterError(
				code: "Connection Type Error",
				message: "Could not call stopRealtime. make sure you are passing a valid iOS connection and that terraRT is initialised by calling 'init'",
				details: nil
			))
		}
  }

  private func disconnect(connection: String, result: @escaping FlutterResult){
    let c = connectionParse(connection: connection)
		if c != nil && terraRT != nil {
      terraRT!.disconnect(type: c!)
      result(true)
		} else {
			result(FlutterError(
				code: "Connection Type Error",
				message: "Could not call disconnect. make sure you are passing a valid connection and that terraRT is initialised by calling 'init'",
				details: nil
			))
		}
  }

  private func startBluetoothScan(connection: String, result: @escaping FlutterResult){
    if terraRT != nil {
      if let c = connectionParse(connection: connection){
        terraRT!.startBluetoothScan(type: c){device in 
          self.deviceCallChannel(device: device)
          FlutteriOSScanView.deviceMap[device.deviceName] = device
        }
        result(true)
      }
		} else {
			result(FlutterError(
				code: "Dependency error",
				message: "Could not call startBluetoothScan. make sure that terraRT is initialised by calling 'init'",
				details: nil
			))
		}
  }

  private func connectDevice(device: String, result: @escaping FlutterResult){
    if let device = FlutteriOSScanView.deviceMap[device], terraRT != nil{
      terraRT!.connectDevice(device){success in
        result(success)
      }
    }else{
      result(false)
    }
  }

  private func startBluetoothScan(useCache: Bool, result: @escaping FlutterResult){
      guard let terraRT = terraRT else {
          result(FlutterError(
              code: "DependencyError",
              message: "terraRT is not initialized.",
              details: nil
          ))
          return
      }

      // Perform scanning asynchronously
      DispatchQueue.global(qos: .utility).async {
          let scanView = terraRT.startBluetoothScan(
              type: .BLE,
              bluetoothLowEnergyFromCache: useCache
          ) { success in
              DispatchQueue.main.async {
                  result(success)
              }
          }

          DispatchQueue.main.async {
              let child = UIHostingController(rootView: scanView)
              child.view.translatesAutoresizingMaskIntoConstraints = false
              child.view.frame = self.mainview.bounds
              child.view.tag = 100
              self.mainview.addSubview(child.view)
          }
      }
  }

  private func _connectWatchOS(result: @escaping FlutterResult){
    guard let terraRT = terraRT else {
      result(FlutterError(
				code: "Dependency error",
				message: "Could not call connect to WatchOS. make sure that terraRT is initialised by calling 'init'",
				details: nil
			))
      return
    }

    do {
      try terraRT.connectWithWatchOS()
      result(true)
    }
    catch {
      result(false)
    }
  }

  private func _resumeWatchOSWorkout(result: @escaping FlutterResult){
    guard let terraRT = terraRT else {
      result(FlutterError(
        code: "Dependency error",
        message: "Could not call resumeWatchOSWorkout. make sure that terraRT is initialised by calling 'init'",
        details: nil
      ))
      return
    }

    terraRT.resumeWatchOSWorkout {success in
      result(success)
    }
  }

  private func _pauseWatchOSWorkout(result: @escaping FlutterResult){
    guard let terraRT = terraRT else {
      result(FlutterError(
        code: "Dependency error",
        message: "Could not call pauseWatchOSWorkout. make sure that terraRT is initialised by calling 'init'",
        details: nil
      ))
      return
    }

    terraRT.pauseWatchOSWorkout {success in
      result(success)
    }
  }

  private func _stopWatchOSWorkout(result: @escaping FlutterResult){
    guard let terraRT = terraRT else {
      result(FlutterError(
        code: "Dependency error",
        message: "Could not call stopWatchOSWorkout. make sure that terraRT is initialised by calling 'init'",
        details: nil
      ))
      return
    }

    terraRT.stopWatchOSWorkout {success in
      result(success)
    }
  }


  private func callChannel(update: Update) {
    do {
      let data = try JSONEncoder().encode(update)
      self.channel.invokeMethod("update",
      arguments: String(data: data, encoding: .utf8))
    } catch { print("Could not serialise update") }
  }

  private func deviceCallChannel(device: Device) {
    do {
      let payload = try JSONEncoder().encode(
        Device_(device.deviceName, device.deviceUUID)
      )
      self.channel.invokeMethod("device",
      arguments: String(data: payload,
      encoding: .utf8))
    } catch { print("Could not serialise device") }
  }

  func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args_op = call.arguments else {
			result("ERROR")
			return
		}
		let args = args_op as! [String: Any]
		switch call.method {
      case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
        break;
      case "init":
        terraRT = TerraRT(
          devId: args["devId"] as! String,
          referenceId: args["referenceId"] as? String ?? ""
        ){
          success in 
            result(success)
        }
        break;
      case "initConnection":
        initConnection(
          token: args["token"] as! String,
          result: result
        )
        break
      case "startRealtimeToServer":
        startRealtime(
          connection: args["connection"] as! String,
          token: args["token"] as! String,
          datatypes: args["datatypes"] as! [String],
          result: result
        )
        break;
      case "startRealtimeToApp":
        startRealtime(
          connection: args["connection"] as! String,
          datatypes: args["datatypes"] as! [String],
          result: result
        )
        break;
      case "stopRealtime":
        stopRealtime(
          connection: args["connection"] as! String,
          result: result
        )
        break;
      case "getUserId":
        getUserId(result: result)
        break;
      case "disconnect":
        disconnect(
          connection: args["connection"] as! String,
          result: result
        )
      case "startBluetoothScan":
        startBluetoothScan(
          useCache: args["useCache"] as! Bool,
          result: result
        )
        break;
      case "startDeviceScanWithCallback":
        startBluetoothScan(
          connection: args["connection"] as! String,
          result: result
        )
        break;
      case "connectDevice":
        connectDevice(
          device: args["deviceName"] as! String,
          result: result
        )
        break;
      case "connectWatchOS":
        _connectWatchOS(result: result)
        break;
      case "resumeWatchOSWorkout":
        _resumeWatchOSWorkout(result: result)
        break;
      case "pauseWatchOSWorkout":
        _pauseWatchOSWorkout(result: result)
        break;
      case "stopWatchOSWorkout":
        _stopWatchOSWorkout(result: result)
        break;
      default:
        result(FlutterMethodNotImplemented)
		}
  }
}
