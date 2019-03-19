#import "SuperCameraPlugin.h"

@implementation SuperCameraPlugin
NSMutableDictionary *controllers;

- (instancetype)init {
  self = [super init];
  if (self) {
    controllers = [NSMutableDictionary new];
  }
  return self;
}

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
  } else if ([@"CameraController#open" isEqualToString:call.method]) {
    [self openController:call result:result];
  } else if ([@"CameraController#close" isEqualToString:call.method]) {
    [self closeController:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)openController:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *arguments = call.arguments;
  NSString *cameraId = arguments[@"cameraId"];

  if (controllers[cameraId]) {
    result([FlutterError errorWithCode:@"Already opened CameraController for this camera."
                               message:nil
                               details:nil]);
    return;
  }

  CameraController *controller = [[CameraController alloc] initWithCameraId:cameraId];
  controllers[cameraId] = controller;

  result(nil);
}

- (void)closeController:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *arguments = call.arguments;
  NSString *cameraId = arguments[@"cameraId"];

  if (!controllers[cameraId]) {
    result([FlutterError errorWithCode:@"No CameraController for this camera"
                               message:nil
                               details:nil]);
    return;
  }

  CameraController *controller = controllers[cameraId];
  [controller close];

  [controllers removeObjectForKey:cameraId];

  result(nil);
}
@end
