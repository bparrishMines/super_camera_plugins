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
  } else if ([@"CaptureSession#startRunning" isEqualToString:call.method]) {
    [FLTCaptureSession startRunning:call result:result];
  } else if ([@"CaptureSession#stopRunning" isEqualToString:call.method]) {
    [FLTCaptureSession stopRunning:call result:result];
  } else if ([@"CaptureSession#running" isEqualToString:call.method]) {
    NSNumber *handle = call.arguments[@"handle"];
    if (methodHandlers[handle]) {
      result([NSNumber numberWithBool:YES]);
    } else {
      result([NSNumber numberWithBool:NO]);
    }
  } else if ([@"Camera#createPlatformTexture" isEqualToString:call.method]) {
    NSNumber *handle = call.arguments[@"handle"];
    PlatformTexture *texture = [[PlatformTexture alloc] initWithTextureRegistry:registrar.textures
                                                                         handle:handle];
    [SuperCameraPlugin addMethodHandler:handle methodHandler:texture];
  } else {
    NSNumber *handle = call.arguments[@"handle"];
    id<MethodCallHandler> handler = [SuperCameraPlugin getHandler:handle];
    
    if (handler) {
      [handler handleMethodCall:call result:result];
    } else {
      result(FlutterMethodNotImplemented);
    }
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

+ (id<MethodCallHandler>)getHandler:(NSNumber *)handle {
  return methodHandlers[handle];
}
@end
