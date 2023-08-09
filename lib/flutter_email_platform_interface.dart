
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_email_method_channel.dart';

abstract class FlutterEmailPlatform extends PlatformInterface {

  FlutterEmailPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterEmailPlatform _instance = MethodChannelFlutterEmail();

  static FlutterEmailPlatform get instance => _instance;

  static set instance(FlutterEmailPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<num?> newSession(String url,String address,String password,String domain) {
    throw UnimplementedError('newSession() has not been implemented.');
  }

  Future<String?> checkAccount(num session) {
    throw UnimplementedError('checkAccount() has not been implemented.');
  }

  Future<String?> getFolders(num session) {
    throw UnimplementedError('getFolders() has not been implemented.');
  }
}
