import Flutter
import UIKit

public class FlutterEmailPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "zenmen_flutter_email", binaryMessenger: registrar.messenger())
    let instance = FlutterEmailPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    Cryptor.cryptorInit()
    CZExchange.exchangeInit()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method {
          case "ews_new_session":
              let arguments = call.arguments as! [String: Any]
              let url = arguments["url"] as! String
              let address=arguments["address"] as! String
              let password=arguments["password"] as! String
              let domain=arguments["domain"] as! String
              let pointer=CZExchange.newSession(uri: url, email: address, password:password ,domain:domain)
              let session = UInt(bitPattern: pointer!)
              print("++++++++++ews_new_session:",session)
              result(session);
          case "ews_check_account":
              let arguments = call.arguments as! [String: Any]
              var session = arguments["session"] as! UInt
              print("++++++++++ews_check_account,session:",session)
              let pointer=UnsafeMutableRawPointer(bitPattern: session)
              let response=CZExchange.checkAccount(sess: pointer!)
              result(response)
          case "ews_get_folders":
              let arguments = call.arguments as! [String: Any]
              var session = arguments["session"] as! UInt
              print("++++++++++ews_get_folders,session:",session)
              let pointer=UnsafeMutableRawPointer(bitPattern: session)
              let response=CZExchange.getFolders(sess: pointer!)
              result(response)
          default:
              result(FlutterMethodNotImplemented)
      }
  }
}
