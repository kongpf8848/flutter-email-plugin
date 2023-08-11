import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_email_platform_interface.dart';

/// An implementation of [FlutterEmailPlatform] that uses method channels.
class MethodChannelFlutterEmail extends FlutterEmailPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('zenmen_flutter_email');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<num?> newSession(
      String url, String address, String password, String domain) async {
    final session = await methodChannel.invokeMethod<num>(
        'ews_new_session', <String, dynamic>{
      'url': url,
      'address': address,
      'password': password,
      'domain': domain
    });
    return session;
  }

  @override
  Future<String?> checkAccount(num session) async {
    final result = await methodChannel.invokeMethod<String>(
        'ews_check_account', <String, dynamic>{'session': session});
    return result;
  }

  @override
  Future<String?> getFolders(num session) async {
    final result = await methodChannel.invokeMethod<String>(
        'ews_get_folders', <String, dynamic>{'session': session});
    return result;
  }
}
