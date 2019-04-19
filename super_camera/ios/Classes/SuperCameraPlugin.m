#import "SuperCameraPlugin.h"

@interface Pair : NSObject
@property(readwrite) FlutterMethodChannel *channel;
@property(readwrite) CameraController *controller;
@end

@implementation Pair
@end

@interface SuperCameraPlugin ()
@property NSMutableArray<Pair *> *controllers;
@property id<FlutterPluginRegistrar> registrar;
@end

@implementation SuperCameraPlugin
static NSString *const kPluginChannelName = @"bmparr2450.plugins/super_camera";

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _controllers = [NSMutableArray new];
    _registrar = registrar;
  }
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:kPluginChannelName
            binaryMessenger:[registrar messenger]];
  
  SuperCameraPlugin* instance = [[SuperCameraPlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"Camera#availableCameras" isEqualToString:call.method]) {
    result([CameraController availableCameras]);
  } else if ([@"Camera#createCameraController" isEqualToString:call.method]) {
    [self createCameraController:call];
    result(nil);
  } else if ([@"Camera#releaseAllResources" isEqualToString:call.method]) {
    [self releaseAllResources];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)createCameraController:(FlutterMethodCall*)call {
  NSString *channelName = call.arguments[@"channelName"];
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                methodChannelWithName:channelName
                                      binaryMessenger:[_registrar messenger]];

  NSString *cameraId = call.arguments[@"cameraId"];
  CameraController *controller = [[CameraController alloc] initWithCameraId:cameraId
                                                            textureRegistry:[_registrar textures]
                                                                  messenger:[_registrar messenger]];

  [_registrar addMethodCallDelegate:controller channel:channel];

  Pair *pair = [Pair new];
  pair.channel = channel;
  pair.controller = controller;
  [_controllers addObject:pair];
}

- (void)releaseAllResources {
  for (Pair *controllerPair in _controllers) {
    [controllerPair.controller close];
  }

  [_controllers removeAllObjects];
}
@end
