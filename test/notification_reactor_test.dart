import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notification_reactor/notification_reactor.dart';

class MockMethodChannel extends Mock implements MethodChannel {
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    return Future.value();
  }
}

void main() {
  final MethodChannel channel = MockMethodChannel();
  late NotificationReactor reactor;

  setUp(() {
    reactor = NotificationReactor.private(channel);
  });

  tearDown(() {
    reset(channel);
  });

  test('onLaunch', () async {
    final launchCompleter = Completer<Map<String, dynamic>>();
    final messageCompleter = Completer<Map<String, dynamic>>();
    final resumeCompleter = Completer<Map<String, dynamic>>();
    reactor.setHandlers(
      onLaunch: (message) {
        launchCompleter.complete(message);
      },
      onMessage: (message) {
        messageCompleter.complete(message);
      },
      onResume: (message) {
        resumeCompleter.complete(message);
      },
    );
    final dynamic handler =
        verify(channel.setMethodCallHandler(captureAny)).captured.single;
    final message = <String, dynamic>{
      "apns": <String, dynamic>{
        "alert": <String, dynamic>{"body": "Test"},
        "badge": 1,
        "sound": "default",
      },
      "myData": "Hello from iOS",
    };
    handler(MethodCall("onLaunch", message));
    expect(await launchCompleter.future, message);
    expect(messageCompleter.isCompleted, false);
    expect(resumeCompleter.isCompleted, false);
  });

  test('onMessage', () async {
    final launchCompleter = Completer<Map<String, dynamic>>();
    final messageCompleter = Completer<Map<String, dynamic>>();
    final resumeCompleter = Completer<Map<String, dynamic>>();
    reactor.setHandlers(
      onLaunch: (message) {
        launchCompleter.complete(message);
      },
      onMessage: (message) {
        messageCompleter.complete(message);
      },
      onResume: (message) {
        resumeCompleter.complete(message);
      },
    );
    final dynamic handler =
        verify(channel.setMethodCallHandler(captureAny)).captured.single;
    final message = <String, dynamic>{
      "apns": <String, dynamic>{
        "alert": <String, dynamic>{"body": "Test"},
        "badge": 1,
        "sound": "default",
      },
      "myData": "Hello from iOS",
    };
    handler(MethodCall("onMessage", message));
    expect(launchCompleter.isCompleted, false);
    expect(await messageCompleter.future, message);
    expect(resumeCompleter.isCompleted, false);
  });

  test('onResume', () async {
    final launchCompleter = Completer<Map<String, dynamic>>();
    final messageCompleter = Completer<Map<String, dynamic>>();
    final resumeCompleter = Completer<Map<String, dynamic>>();
    reactor.setHandlers(
      onLaunch: (message) {
        launchCompleter.complete(message);
      },
      onMessage: (message) {
        messageCompleter.complete(message);
      },
      onResume: (message) {
        resumeCompleter.complete(message);
      },
    );
    final dynamic handler =
        verify(channel.setMethodCallHandler(captureAny)).captured.single;
    final message = <String, dynamic>{
      "apns": <String, dynamic>{
        "alert": <String, dynamic>{"body": "Test"},
        "badge": 1,
        "sound": "default",
      },
      "myData": "Hello from iOS",
    };
    handler(MethodCall("onResume", message));
    expect(launchCompleter.isCompleted, false);
    expect(messageCompleter.isCompleted, false);
    expect(await resumeCompleter.future, message);
  });
}
