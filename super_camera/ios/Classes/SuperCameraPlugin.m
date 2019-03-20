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
  } else if ([@"CameraController#putRepeatingCaptureRequest" isEqualToString:call.method]) {
    [self putRepeatingCaptureRequest:call result:result];
  } else if ([@"CameraController#stopRepeatingCaptureRequest" isEqualToString:call.method]) {
    [self stopRepeatingCaptureRequest:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)openController:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *arguments = call.arguments;
  NSString *cameraId = arguments[@"cameraId"];

  if (controllers[cameraId]) {
    result([FlutterError errorWithCode:@"CameraAlreadyOpenException"
                               message:@"CameraController has already been opened."
                               details:nil]);
    return;
  }

  CameraController *controller = [[CameraController alloc] initWithCameraId:cameraId];
  controllers[cameraId] = controller;
  [controller open:result];
}

- (void)closeController:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *arguments = call.arguments;
  NSString *cameraId = arguments[@"cameraId"];

  CameraController *controller = controllers[cameraId];

  if (!controller) {
    result(nil);
    return;
  }

  [controllers removeObjectForKey:cameraId];
  [controller close:result];
}

- (void)putRepeatingCaptureRequest:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(@1);
}

- (void)stopRepeatingCaptureRequest:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(nil);
}
@end
