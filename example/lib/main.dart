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

  num? session = 0;
  String? inboxId = "";

  @override
  void initState() {
    super.initState();
  }

  void _onClickActionButton() async {
    if (session == 0) {
      session = await _flutterEmailPlugin.newSession(
          "webmail.zenmen.com", "kongpf@zenmen.com", "xxx", "zenmen");
      print('++++++++++++++$session');
    } else if (inboxId == null || inboxId!.isEmpty) {
      var result = await _flutterEmailPlugin.checkAccount(session!);
      print('++++++++++++++email_check_account:$result');
      if (result != null) {
        final data = jsonDecode(result);
        inboxId = data["inbox"];
        print('++++++++++++++inboxId:$inboxId');
      }
    } else {
      var result = await _flutterEmailPlugin.getFolders(session!);
      print('++++++++++++++email_get_folders:$result');
    }
  }

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
