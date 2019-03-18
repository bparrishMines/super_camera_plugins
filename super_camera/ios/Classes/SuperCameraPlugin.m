#import "SuperCameraPlugin.h"

@implementation SuperCameraPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"bmparr2450.plugins/super_camera"
            binaryMessenger:[registrar messenger]];
  SuperCameraPlugin* instance = [[SuperCameraPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"Camera#availableCameras" isEqualToString:call.method]) {
    result([CameraController availableCameras]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}
@end
