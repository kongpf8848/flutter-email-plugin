import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_email/flutter_email.dart';
import 'package:flutter_email/flutter_email_platform_interface.dart';
import 'package:flutter_email/flutter_email_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterEmailPlatform
    with MockPlatformInterfaceMixin
    implements FlutterEmailPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterEmailPlatform initialPlatform = FlutterEmailPlatform.instance;

  test('$MethodChannelFlutterEmail is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterEmail>());
  });

  test('getPlatformVersion', () async {
    FlutterEmail flutterEmailPlugin = FlutterEmail();
    MockFlutterEmailPlatform fakePlatform = MockFlutterEmailPlatform();
    FlutterEmailPlatform.instance = fakePlatform;

    expect(await flutterEmailPlugin.getPlatformVersion(), '42');
  });
}
