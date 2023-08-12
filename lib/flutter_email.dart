import 'flutter_email_platform_interface.dart';

class FlutterEmail {
  Future<String?> getPlatformVersion() {
    return FlutterEmailPlatform.instance.getPlatformVersion();
  }

  Future<num?> newSession(
      String url, String address, String password, String domain) {
    return FlutterEmailPlatform.instance
        .newSession(url, address, password, domain);
  }

  Future<String?> checkAccount(num session) {
    return FlutterEmailPlatform.instance.checkAccount(session);
  }

  Future<String?> getFolders(num session) {
    return FlutterEmailPlatform.instance.getFolders(session);
  }
}
