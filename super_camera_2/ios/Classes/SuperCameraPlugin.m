#import "SuperCameraPlugin+Internal.h"

@implementation SuperCameraPlugin
static NSMutableDictionary<NSNumber *, id<MethodCallHandler>> *methodHandlers;
static FlutterMethodChannel *channel;
static id<FlutterPluginRegistrar> registrar;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)pluginRegistrar {
  methodHandlers = [NSMutableDictionary new];
  registrar = pluginRegistrar;
  channel = [FlutterMethodChannel
      methodChannelWithName:@"dev.plugins/super_camera"
            binaryMessenger:[registrar messenger]];

  SuperCameraPlugin* instance = [SuperCameraPlugin new];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"CaptureDiscoverySession#devices" isEqualToString:call.method]) {
    result([FLTCaptureDiscoverySession devices:call]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

+ (void)addMethodHandler:(NSNumber *)handle methodHandler:(id<MethodCallHandler>)handler {
  if (methodHandlers[handle]) {
    NSString *reason =
    [[NSString alloc] initWithFormat:@"Object for handle already exists: %d", handle.intValue];
    @throw [[NSException alloc] initWithName:NSInvalidArgumentException reason:reason userInfo:nil];
  }

  methodHandlers[handle] = handler;
}

+ (void)removeMethodHandler:(NSNumber *)handle {
  [methodHandlers removeObjectForKey:handle];
}
@end
