import Flutter
import UIKit
import TerraRTiOS
import Foundation
import SwiftUI

class iOSScanViewFactory: NSObject, FlutterPlatformViewFactory {
  private var messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return FlutteriOSScanView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      binaryMessenger: messenger)
  }
}
class FlutteriOSScanView: NSObject, FlutterPlatformView {
  private var _methodChannel: FlutterMethodChannel
  
  private var mainview: UIView
  var scoreLabel = UILabel()

  func view() -> UIView {
    return mainview
  }
  
  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger
  ) {
    mainview = UIView()
    print("Creating method channel")
    _methodChannel = FlutterMethodChannel(name: "terra_flutter_rt_\(viewId)", binaryMessenger: messenger)
    super.init()
    _methodChannel.setMethodCallHandler(onMethodCall)
  }

  private var terraRT: TerraRT?

  private func connectionParse(connection: String) -> Connections? {
		switch connection {
			case "APPLE":
				return Connections.APPLE
			case "BLE":
				return Connections.BLE
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

  private func startRealtime(
    connection: String,
    token: String,
    datatypes: [String], 
    result: @escaping FlutterResult
  ){
    let c = connectionParse(connection: connection)
		if c != nil && terraRT != nil {
      print("Should be streaming now to server for \(connection) and \(datatypeSet(datatypes: datatypes))")
      terraRT!.startRealtime(type: c!, dataType: datatypeSet(datatypes: datatypes), token: token)
      result(true)
		} else {
			result(FlutterError(
				code: "Connection Type Error",
				message: "Could not call startRealtime. make sure you are passing a valid iOS connection and that terraRT is initialised by calling 'init'",
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
      print("Should be streaming now in app for \(connection) and \(datatypeSet(datatypes: datatypes))")
      terraRT!.startRealtime(type: c!, dataType: datatypeSet(datatypes: datatypes)){
        update in self.callChannel(update: update)
      }
      result(true)
		} else {
			result(FlutterError(
				code: "Connection Type Error",
				message: "Could not call startRealtime. make sure you are passing a valid iOS connection and that terraRT is initialised by calling 'init'",
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
				message: "Could not call disconnect. make sure you are passing a valid iOS connection and that terraRT is initialised by calling 'init'",
				details: nil
			))
		}
  }

  private func startBluetoothScan(result: @escaping FlutterResult){
		if terraRT != nil {
      // todo: show BLE SwiftUI screen on iOS
      let child = UIHostingController(rootView: terraRT!.startBluetoothScan(type: .BLE, callback: {
      success in
        print("GOT SUCCESS THING HERE")
        // if let viewWithTag = self.mainview.viewWithTag(100) {
        //   print("Removing")
        //   viewWithTag.removeFromSuperview()
        //   print("View removed")
        // }
        result(success)
      }))
      child.view.translatesAutoresizingMaskIntoConstraints = false
      child.view.frame = mainview.bounds
      child.view.tag = 100
      mainview.addSubview(child.view)
		} else {
			result(FlutterError(
				code: "Dependency error",
				message: "Could not call startBluetoothScan. make sure that terraRT is initialised by calling 'init'",
				details: nil
			))
		}
  }

  private func callChannel(update: Update){
    do {
      print("attempting json parsing")
      let jsonData = try JSONEncoder().encode(update)
      let data = String(data: jsonData, encoding: .utf8) ?? ""
      print("Sending data to app: \(data)")
      _methodChannel.invokeMethod("update", arguments: data, result: {(r:Any?) -> () in
        print(type(of: r))
      })
    }
    catch {
      print("Could not parse json")
    }
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
        print("Initialising")
        terraRT = TerraRT(
          devId: args["devId"] as! String,
          referenceId: args["referenceId"] as? String ?? ""
        ){
          success in 
            result(success)
            print("Initialised")
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
      case "disconnect":
        disconnect(
          connection: args["connection"] as! String,
          result: result
        )
      case "startBluetoothScan":
        startBluetoothScan(
          result: result
        )
        break;
      default:
        result(FlutterMethodNotImplemented)
		}
  }
}

public class SwiftTerraFlutterRtPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "terra_flutter_rt", binaryMessenger: registrar.messenger())
    let instance = SwiftTerraFlutterRtPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(iOSScanViewFactory(messenger: registrar.messenger()), withId: "terra_flutter_rt")
  }
}
