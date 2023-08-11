import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  var ewsChannel: FlutterMethodChannel!

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
              
              CZExchange.exchangeInit()
      
             
              
      
              let flutterViewController: FlutterViewController = window.rootViewController as! FlutterViewController
              
              self.ewsChannel = FlutterMethodChannel(name: "zenmen_flutter_email", binaryMessenger: flutterViewController.binaryMessenger)
             
              
              GeneratedPluginRegistrant.register(with: self)
           
              ewsChannel.setMethodCallHandler { [weak self] (call:FlutterMethodCall, result) in
                  switch call.method {
                      case "ews_new_session":
                          let arguments = call.arguments as! [String: Any]
                          let url = arguments["url"] as! String
                          let address=arguments["address"] as! String
                          let password=arguments["password"] as! String
                          let domain=arguments["domain"] as! String
                          let pointer=CZExchange.newSession(uri: url, email: address, password:password ,domain:domain)
                          let session = self!.convertPointerToUInt64(pointer:pointer)
                          result(session);
                      case "ews_check_account":
                          let arguments = call.arguments as! [String: Any]
                          var session = arguments["session"] as! UInt64
                          let response=CZExchange.checkAccount(sess: UnsafeMutableRawPointer(&session))
                          result(response)
                      case "ews_get_folders":
                          let arguments = call.arguments as! [String: Any]
                          var session = arguments["session"] as! UInt64
                          let response=CZExchange.getFolders(sess: UnsafeMutableRawPointer(&session))
                          result(response)
                      default:
                          result(FlutterMethodNotImplemented)
                  }
              }
             return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func convertPointerToUInt64(pointer: UnsafeMutableRawPointer?) -> UInt64? {
    let convertedValue = pointer?.assumingMemoryBound(to: UInt64.self).pointee
    return convertedValue
  }
}
