#import "NotificationReactorPlugin.h"

@implementation NotificationReactorPlugin {
    FlutterMethodChannel *_channel;
    BOOL _resumingFromBackground;
    NSDictionary *_launchNotification;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"notification_reactor"
            binaryMessenger:[registrar messenger]];
    NotificationReactorPlugin* instance = [[NotificationReactorPlugin alloc] initWithChannel:channel];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    
    if (self) {
        _channel = channel;
        _resumingFromBackground = NO;
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"setHandlers" isEqualToString:call.method]) {
      if (_launchNotification != nil) {
          [_channel invokeMethod:@"onLaunch" arguments:_launchNotification];
      }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (_resumingFromBackground) {
        [_channel invokeMethod:@"onResume" arguments:userInfo];
    } else {
        [_channel invokeMethod:@"onMessage" arguments:userInfo];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    _resumingFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    _resumingFromBackground = NO;
    application.applicationIconBadgeNumber = 0;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (launchOptions != nil) {
        _launchNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    }
    return YES;
}

- (bool)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
  [self didReceiveRemoteNotification:userInfo];
  completionHandler(UIBackgroundFetchResultNoData);
  return YES;
}

@end
