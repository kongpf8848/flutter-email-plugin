import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  var ewsChannel: FlutterMethodChannel!

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
              
              Cryptor.cryptorInit()
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
             return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

}
