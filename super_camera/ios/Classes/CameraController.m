#import "SuperCameraPlugin.h"

@interface CameraController ()
@property id<FlutterTextureRegistry> textureRegistry;
@property id<VideoDelegate> videoDelegate;
@property id<PhotoDelegate> photoDelegate;
@property AVCaptureSession *session;
@property AVCaptureDevice *device;
@property AVCaptureInput *videoInput;
@property AVCaptureVideoDataOutput *videoOutput;
@property AVCaptureConnection *videoConnection;
@property AVCaptureStillImageOutput *stillImageOutput;
@property AVCaptureConnection *stillImageConnection;
@end

@implementation CameraController
+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {}

+ (NSArray<NSDictionary *> *)availableCameras {
  NSArray<AVCaptureDevice *> *devices;

  if (@available(iOS 10.0, *)) {
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
                          discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                                mediaType:AVMediaTypeVideo
                                                 position:AVCaptureDevicePositionUnspecified];
    devices = discoverySession.devices;
  } else {
    devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  }

  NSMutableArray<NSDictionary<NSString *, NSObject *> *> *allCameraData =
      [[NSMutableArray alloc] initWithCapacity:devices.count];

  for (AVCaptureDevice *device in devices) {
    NSString *lensFacing;
    switch ([device position]) {
      case AVCaptureDevicePositionBack:
        lensFacing = @"back";
        break;
      case AVCaptureDevicePositionFront:
        lensFacing = @"front";
        break;
      case AVCaptureDevicePositionUnspecified:
        lensFacing = @"external";
        break;
    }

    NSMutableArray<NSArray *> *supportedVideoSizes = [NSMutableArray array];
    if (@available(iOS 9.0, *)) {
      if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset3840x2160]) {
        [supportedVideoSizes addObject:@[@(3840), @(2160)]];
      }
    }
    if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
      [supportedVideoSizes addObject:@[@(1920), @(1080)]];
    }
    if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1280x720]) {
      [supportedVideoSizes addObject:@[@(1280), @(720)]];
    }
    if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset640x480]) {
      [supportedVideoSizes addObject:@[@(640), @(480)]];
    }
    if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset352x288]) {
      [supportedVideoSizes addObject:@[@(352), @(288)]];
    }

    [allCameraData addObject:@{
      @"cameraId": [device uniqueID],
      @"lensDirection": lensFacing,
      @"orientation": @(90),
      @"supportedVideoSizes": supportedVideoSizes,
    }];
  }

  return allCameraData;
}

- (instancetype)initWithCameraId:(NSString *)cameraId
                 textureRegistry:(NSObject<FlutterTextureRegistry> *)textureRegistry {
  self = [super init];
  if (self) {
    _cameraId = cameraId;
    _textureRegistry = textureRegistry;
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"CameraController#open" isEqualToString:call.method]) {
    [self open:result];
  } else if ([@"CameraController#startRunning" isEqualToString:call.method]) {
    [self startRunning:result];
  } else if ([@"CameraController#takePhoto" isEqualToString:call.method]) {
    [self takePhoto:call.arguments result:result];
  } else if ([@"CameraController#setVideoSettings" isEqualToString:call.method]) {
    [self setVideoSettings:call.arguments result:result];
  } else if ([@"CameraController#stopRunning" isEqualToString:call.method]) {
    [self stopRunning];
    result(nil);
  } else if ([@"CameraController#close" isEqualToString:call.method]) {
    [self close];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)open:(FlutterResult _Nonnull)result {
  if ([self cameraIsOpen]) {
    result([FlutterError errorWithCode:kCameraControllerAlreadyOpen
                               message:@"CameraController is already open."
                               details:nil]);
    return;
  }

  _session = [AVCaptureSession new];
  _device = [AVCaptureDevice deviceWithUniqueID:_cameraId];

  _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_device
                                                      error:nil];
  [_session addInputWithNoConnections:_videoInput];

  _videoOutput = [AVCaptureVideoDataOutput new];
  [_session addOutputWithNoConnections:_videoOutput];

  _videoConnection = [AVCaptureConnection
                      connectionWithInputPorts:_videoInput.ports
                                        output:_videoOutput];
  [_session addConnection:_videoConnection];

  _stillImageOutput = [AVCaptureStillImageOutput new];
  [_session addOutputWithNoConnections:_stillImageOutput];

  _stillImageConnection = [AVCaptureConnection
                           connectionWithInputPorts:_videoInput.ports
                                             output:_stillImageOutput];
  [_session addConnection:_stillImageConnection];

  result(nil);
}

- (void)startRunning:(FlutterResult)result {
  if (![self cameraIsOpen]) {
    result([FlutterError errorWithCode:kCameraControllerNotOpen
                               message:@"CameraController is not open."
                               details:nil]);
    return;
  }

  [_session startRunning];
  result(nil);
}

- (void)takePhoto:(NSDictionary *)settings result:(FlutterResult _Nonnull)result {
  if (![self cameraIsOpen]) {
    result([FlutterError errorWithCode:kCameraControllerNotOpen
                               message:@"CameraController is not open."
                               details:nil]);
    return;
  }

  NSString *iOSDelegateName = settings[@"iOSDelegateName"];
  if ([iOSDelegateName isEqual:[NSNull null]]) {
    result([FlutterError errorWithCode:kInvalidDelegateName
                               message:@"CameraController delegate name is null."
                               details:nil]);
    return;
  }

  _photoDelegate = [NSClassFromString(iOSDelegateName) new];

  [_photoDelegate initialize:settings[@"delegateSettings"]
             textureRegistry:_textureRegistry
                      result:result];

  [_stillImageOutput captureStillImageAsynchronouslyFromConnection:_stillImageConnection completionHandler:^(CMSampleBufferRef _Nullable imageDataSampleBuffer, NSError *_Nullable error) {
    [self->_photoDelegate onImageTaken:imageDataSampleBuffer error:error];

    self->_photoDelegate = nil;
  }];
}

- (void)setVideoSettings:(NSDictionary *)settings result:(FlutterResult _Nonnull)result {
  if (![self cameraIsOpen]) {
    result([FlutterError errorWithCode:kCameraControllerNotOpen
                               message:@"CameraController is not open."
                               details:nil]);
    return;
  }

  NSString *iOSDelegateName = settings[@"iOSDelegateName"];
  if ([iOSDelegateName isEqual:[NSNull null]]) {
    result([FlutterError errorWithCode:kInvalidDelegateName
                               message:@"CameraController delegate name is null."
                               details:nil]);
    return;
  }

  [self closeVideoDelegate];

  _videoDelegate = [NSClassFromString(iOSDelegateName) new];
  [_videoDelegate initialize:settings[@"delegateSettings"] textureRegistry:_textureRegistry];
  [_videoOutput setSampleBufferDelegate:_videoDelegate queue:dispatch_get_main_queue()];

  @try {
    _videoOutput.videoSettings =
        @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    [self setShouldMirror:settings[@"shouldMirror"]];
    [self setResolution:settings[@"width"] height:settings[@"height"]];
    [self setVideoOrientation:settings[@"orientation"]];
  } @catch (NSException *exception) {
    [self closeVideoDelegate];

    NSString *message = [NSString stringWithFormat:@"%@: %@", exception.name, exception.description];
    result([FlutterError errorWithCode:kInvalidSetting message:message details:nil]);
    return;
  }

  [_videoDelegate onFinishSetup:result];
}

- (void)stopRunning {
  if (![self cameraIsOpen]) return;

  if ([_session isRunning]) {
    [_session stopRunning];
  }
}

- (void) close {
  if (![self cameraIsOpen]) return;

  if ([_session isRunning]) {
    [_session stopRunning];
  }
  [self closeVideoDelegate];

  _session = nil;
  _device = nil;
}

// Settings Methods
- (void)setShouldMirror:(NSNumber *)shouldMirror {
  _videoConnection.videoMirrored = shouldMirror.boolValue;
}

- (void)setResolution:(NSNumber *)width height:(NSNumber *)height {
  if ([width isEqual:[NSNull null]] || [height isEqual:[NSNull null]]) {
    return;
  }

  BOOL shouldThrowException = NO;

  if (width.intValue == 3840 && height.intValue == 2160) {
    if (@available(iOS 9.0, *)) {
      _session.sessionPreset = AVCaptureSessionPreset3840x2160;
    } else {
      shouldThrowException = YES;
    }
  } else if (width.intValue == 1920 && height.intValue == 1080) {
    _session.sessionPreset = AVCaptureSessionPreset1920x1080;
  } else if (width.intValue == 1280 && height.intValue == 720) {
    _session.sessionPreset = AVCaptureSessionPreset1280x720;
  } else if (width.intValue == 640 && height.intValue == 480) {
    _session.sessionPreset = AVCaptureSessionPreset640x480;
  } else if (width.intValue == 352 && height.intValue == 288) {
    _session.sessionPreset = AVCaptureSessionPreset352x288;
  } else {
    shouldThrowException = YES;
  }

  if (shouldThrowException) {
    NSString *reason = [NSString stringWithFormat:@"Invalid capture size of Size(%@, %@)", width, height];
    @throw [NSException exceptionWithName:@"InvalidArgumentException" reason:reason userInfo:nil];
  }
}

- (void)setVideoOrientation:(NSString *)orientation {
  if ([@"VideoOrientation.portraitUp" isEqualToString:orientation]) {
    _videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
  } else if ([@"VideoOrientation.portraitDown" isEqualToString:orientation]) {
    _videoConnection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
  } else if ([@"VideoOrientation.landscapeRight" isEqualToString:orientation]) {
    _videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
  } else if ([@"VideoOrientation.landscapeLeft" isEqualToString:orientation]) {
    _videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
  } else {
    NSString *reason = [NSString stringWithFormat:@"Invalid video orientation of %@", orientation];
    @throw [NSException exceptionWithName:@"InvalidArgumentException" reason:reason userInfo:nil];
  }
}

// Helper Methods
- (void)closeVideoDelegate {
  if (!_videoDelegate) return;

  [_videoOutput setSampleBufferDelegate:nil queue:nil];

  [_videoDelegate close];
  _videoDelegate = nil;
}

- (BOOL)cameraIsOpen {
  return _session != nil;
}
@end
