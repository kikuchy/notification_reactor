import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

typedef NotificationHandler = void Function(Map<String, dynamic>);

class NotificationReactor {
  static NotificationReactor _instance;
  final MethodChannel _channel;

  NotificationHandler _onMessage;
  NotificationHandler _onResume;
  NotificationHandler _onLaunch;

  @visibleForTesting
  NotificationReactor.private(MethodChannel channel) : _channel = channel {
    _channel.setMethodCallHandler(_handleMethod);
  }

  factory NotificationReactor() =>
      _instance ??
      (_instance =
          NotificationReactor.private(const MethodChannel('notification_reactor')));

  void setHandlers(
      {NotificationHandler onLaunch,
      NotificationHandler onResume,
      NotificationHandler onMessage}) {
    _onMessage = onMessage;
    _onResume = onResume;
    _onLaunch = onLaunch;
    _channel.invokeMethod("setHandlers");
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    switch (call.method) {
      case "onMessage":
        _onMessage?.call(call.arguments.cast<String, dynamic>());
        return null;
      case "onResume":
        _onResume?.call(call.arguments.cast<String, dynamic>());
        return null;
      case "onLaunch":
        _onLaunch?.call(call.arguments.cast<String, dynamic>());
        return null;
      default:
        return null;
    }
  }
}
