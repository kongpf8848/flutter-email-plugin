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
           
              ewsChannel.setMethodCallHandler { [weak self] (call, result) in
                  switch call.method {
                  case "ews_new_session":
                      let session=CZExchange.newSession(uri: "webmail.zenmen.com", email: "kongpf@zenmen.com", password:"God3$Mfc123789" ,domain:"zenmen")
                      result(session);
                  default:
                      result(FlutterMethodNotImplemented)
                  }
              }
             return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
