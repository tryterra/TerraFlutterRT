import Flutter
import UIKit
import TerraRTiOS
import Foundation

class WebViewFactory: NSObject, FlutterPlatformViewFactory {
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
    return FlutterWebView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      binaryMessenger: messenger)
  }
}
class FlutterWebView: NSObject, FlutterPlatformView {
  private var _nativeWebView: UIWebView
  private var _methodChannel: FlutterMethodChannel
  
  func view() -> UIView {
    return _nativeWebView
  }
  
  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger
  ) {
    _nativeWebView = UIWebView()
    _methodChannel = FlutterMethodChannel(name: "terra_flutter_rt_\(viewId)", binaryMessenger: messenger)

    super.init()
    // iOS views can be created here
    _methodChannel.setMethodCallHandler(onMethodCall)

  }


  func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
    switch(call.method){
    case "setUrl":
      setText(call:call, result:result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  func setText(call: FlutterMethodCall, result: FlutterResult){
    let url = call.arguments as! String
    _nativeWebView.loadRequest(NSURLRequest(url: NSURL(string: url)! as URL) as URLRequest)
  }
  
}

public class SwiftTerraFlutterRtPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "terra_flutter_rt", binaryMessenger: registrar.messenger())
    let instance = SwiftTerraFlutterRtPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(WebViewFactory(messenger: registrar.messenger()), withId: "terra_flutter_rt")
  }

  // terra instance managed
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
    return Set([])
  }

  private func datatypeSet(datatypes: [String]) -> Set<DataTypes> {
    var out: Set<DataTypes> = Set([])
    for datatype in datatypes {
      out.formUnion(typeParse(datatype: datatype))
    }
    return out
  }


  private func initConnection(connection: String, result: @escaping FlutterResult){
    let c = connectionParse(connection: connection)
		if c != nil && terraRT != nil {
      terraRT!.initConnection(type: c!)
      result(true)
		} else {
			result(FlutterError(
				code: "Connection Type Error",
				message: "Could not call initConnection. make sure you are passing a valid iOS connection and that terraRT is initialised by calling 'init'",
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
      terraRT!.startRealtime(type: c!, token: token, dataType: datatypeSet(datatypes: datatypes))
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
      result(true)
		} else {
			result(FlutterError(
				code: "Dependency error",
				message: "Could not call startBluetoothScan. make sure that terraRT is initialised by calling 'init'",
				details: nil
			))
		}
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
					terraRT = TerraRT()
          result(true)
					break;
        case "initConnection":
          initConnection(
            connection: args["connection"] as! String,
						result: result
          )
          break
        case "startRealtime":
          startRealtime(
            connection: args["connection"] as! String,
            token: args["token"] as! String,
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
