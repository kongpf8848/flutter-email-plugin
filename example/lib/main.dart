import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_email/flutter_email.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterEmailPlugin = FlutterEmail();

  static const platform = MethodChannel('zenmen_flutter_email');

  num? session = 0;
  String? inboxId = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    // try {
    //   platformVersion = await _flutterEmailPlugin.getPlatformVersion() ??
    //       'Unknown platform version';
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) return;

    // setState(() {
    //   _platformVersion = platformVersion;
    // });
  }

  void _onClickActionButton() async {
    print('++++++++++++++_onClickActionButton');
    if (session == 0) {
      session = await platform.invokeMethod("ews_new_session", {
        'url': 'webmail.zenmen.com',
        'address': 'kongpf@zenmen.com',
        'password': 'God3\$Mfc123789',
        'domain': 'zenmen'
      });
      print('++++++++++++++session:$session');
    } else if (inboxId == null || inboxId!.isEmpty) {
      var result = await platform.invokeMethod("ews_check_account", {
        'session': session,
      });
      print('++++++++++++++email_check_account:$result');
      if (result != null) {
        final data = jsonDecode(result);
        inboxId = data["inbox"];
        print('++++++++++++++inboxId:$inboxId');
      }
    } else {
      var result = await platform.invokeMethod("ews_get_folders", {
        'session': session,
      });
      print('++++++++++++++email_get_folders:$result');
    }
  }

  // void _onClickActionButton() async {
  //   if (session == 0) {
  //     session = await _flutterEmailPlugin.newSession(
  //         "webmail.zenmen.com", "kongpf@zenmen.com", "xxxx", "zenmen");
  //     print('++++++++++++++$session');
  //   } else if (inboxId == null || inboxId!.isEmpty) {
  //     var result = await _flutterEmailPlugin.checkAccount(session!);
  //     print('++++++++++++++email_check_account:$result');
  //     if (result != null) {
  //       final data = jsonDecode(result);
  //       inboxId = data["inbox"];
  //       print('++++++++++++++inboxId:$inboxId');
  //     }
  //   } else {
  //     var result = await _flutterEmailPlugin.getFolders(session!);
  //     print('++++++++++++++email_get_folders:$result');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onClickActionButton,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
