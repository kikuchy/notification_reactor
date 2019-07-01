import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notification_reactor/notification_reactor.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _route;
  Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    NotificationReactor().setHandlers(
      onLaunch: (message) {
        _route = "onLaunch";
        _data = message;
      },
      onResume: (message) {
        _route = "onResume";
        _data = message;
      },
      onMessage: (message) {
        _route = "onMessage";
        _data = message;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text(
              '${(_route != null) ? _route : "no push"}\n${(_data != null) ? _data : "no data"}'),
        ),
      ),
    );
  }
}
