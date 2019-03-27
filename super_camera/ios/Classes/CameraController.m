#import "SuperCameraPlugin.h"

@interface CameraController ()
@property id<FlutterTextureRegistry> textureRegistry;
@property id<RepeatingCaptureDelegate> repeatingCaptureDelegate;
@property id<SingleCaptureDelegate> singleCaptureDelegate;
@property AVCaptureSession *session;
@property AVCaptureDevice *device;
@property AVCaptureInput *videoInput;
@property AVCaptureVideoDataOutput *videoOutput;
@property AVCaptureConnection *videoConnection;
@property AVCaptureStillImageOutput *stillImageOutput;
@property AVCaptureConnection *stillImageConnection;
@end

@implementation CameraController
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

    NSMutableArray<NSArray *> *repeatingCaptureSizes = [NSMutableArray array];
    if (@available(iOS 9.0, *)) {
      if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset3840x2160]) {
        [repeatingCaptureSizes addObject:@[@(3840), @(2160)]];
      }
    }
    if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
      [repeatingCaptureSizes addObject:@[@(1920), @(1080)]];
    }
    if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1280x720]) {
      [repeatingCaptureSizes addObject:@[@(1280), @(720)]];
    }
    if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset640x480]) {
      [repeatingCaptureSizes addObject:@[@(640), @(480)]];
    }
    if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset352x288]) {
      [repeatingCaptureSizes addObject:@[@(352), @(288)]];
    }

    [allCameraData addObject:@{
      @"cameraId": [device uniqueID],
      @"lensDirection": lensFacing,
      @"orientation": @(90),
      @"repeatingCaptureSizes": repeatingCaptureSizes,
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
  } else if ([@"CameraController#close" isEqualToString:call.method]) {
    [self close];
    result(nil);
  } else if ([@"CameraController#putSingleCaptureRequest" isEqualToString:call.method]) {
    [self putSingleCaptureRequest:call.arguments result:result];
  } else if ([@"CameraController#putRepeatingCaptureRequest" isEqualToString:call.method]) {
    [self putRepeatingCaptureRequest:call.arguments result:result];
  } else if ([@"CameraController#stopRepeatingCaptureRequest" isEqualToString:call.method]) {
    [self stopRepeatingCaptureRequest];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
  // Do nothing
}

- (void) open:(FlutterResult _Nonnull)result {
  _session = [AVCaptureSession new];
  _device = [AVCaptureDevice deviceWithUniqueID:_cameraId];
  result(nil);
}

- (void) putSingleCaptureRequest:(NSDictionary *)settings result:(FlutterResult _Nonnull)result {
  if (!_session) {
    result([FlutterError errorWithCode:@"CameraNotOpenException"
                               message:@"Camera is not open."
                               details:nil]);
    return;
  }

  NSString *iOSDelegateName = settings[@"iOSDelegateName"];
  if ([iOSDelegateName isEqual:[NSNull null]]) {
    result([FlutterError errorWithCode:@"CameraDelegateNameIsNull"
                               message:@"Camera delegate name is null."
                               details:nil]);
    return;
  }

  _singleCaptureDelegate = [NSClassFromString(iOSDelegateName) new];

  [_singleCaptureDelegate initialize:settings[@"delegateSettings"]
                     textureRegistry:_textureRegistry
                              result:result];

  _stillImageOutput = [AVCaptureStillImageOutput new];
  [_session addOutputWithNoConnections:_stillImageOutput];

  _stillImageConnection = [AVCaptureConnection
                           connectionWithInputPorts:_videoInput.ports
                           output:_stillImageOutput];
  [_session addConnection:_stillImageConnection];

  [_stillImageOutput captureStillImageAsynchronouslyFromConnection:_stillImageConnection completionHandler:^(CMSampleBufferRef _Nullable imageDataSampleBuffer, NSError *_Nullable error) {
    [self->_singleCaptureDelegate onImageTaken:imageDataSampleBuffer error:error];

    self->_singleCaptureDelegate = nil;
    self->_stillImageConnection = nil;
    [self->_singleCaptureDelegate onRelease];
  }];
}

- (void) putRepeatingCaptureRequest:(NSDictionary *)settings result:(FlutterResult _Nonnull)result {
  if (!_session) {
    result([FlutterError errorWithCode:@"CameraNotOpenException"
                               message:@"Camera is not open."
                               details:nil]);
    return;
  }

  NSString *iOSDelegateName = settings[@"iOSDelegateName"];
  if ([iOSDelegateName isEqual:[NSNull null]]) {
    result([FlutterError errorWithCode:@"CameraDelegateNameIsNull"
                               message:@"Camera delegate name is null."
                               details:nil]);
    return;
  }

  _repeatingCaptureDelegate = [NSClassFromString(iOSDelegateName) new];

  [_repeatingCaptureDelegate initialize:settings[@"delegateSettings"] textureRegistry:_textureRegistry];

  _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_device
                                                             error:nil];
  [_session addInputWithNoConnections:_videoInput];

  _videoOutput = [AVCaptureVideoDataOutput new];
  _videoOutput.videoSettings =
      @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
  [_videoOutput setAlwaysDiscardsLateVideoFrames:YES];
  [_session addOutputWithNoConnections:_videoOutput];
  [_videoOutput setSampleBufferDelegate:_repeatingCaptureDelegate queue:dispatch_get_main_queue()];

  _videoConnection = [AVCaptureConnection
                             connectionWithInputPorts:_videoInput.ports
                                               output:_videoOutput];
  [_session addConnection:_videoConnection];

  @try {
    [self setShouldMirror:settings[@"shouldMirror"]];
    [self setResolution:settings[@"width"] height:settings[@"height"]];
  } @catch (NSException *exception) {
    [self stopRepeatingCaptureRequest];
    result([FlutterError errorWithCode:exception.name message:exception.reason details:nil]);
    return;
  }

  [_session startRunning];
  [_repeatingCaptureDelegate onStart:result];
}

- (void)stopRepeatingCaptureRequest {
  if (!_session) return;

  if ([_session isRunning]) {
    [_session stopRunning];
  }

  if ([[_session outputs] containsObject:_videoOutput]) {
    [self removeCaptureVideoInputsAndOutputs];
  }

  [self closeRepeatingCaptureDelegate];
}

- (void) close {
  if (!_session) return;

  [self stopRepeatingCaptureRequest];

  _session = nil;
  _device = nil;
}

// Helper Methods
- (void)closeRepeatingCaptureDelegate {
  if (!_repeatingCaptureDelegate) return;

  [_repeatingCaptureDelegate close];
  _repeatingCaptureDelegate = nil;
}

- (void)removeCaptureVideoInputsAndOutputs {
  if (!_session) return;

  [_session removeConnection:_videoConnection];
  _videoConnection = nil;

  [_session removeInput:_videoInput];
  _videoInput = nil;

  [_session removeOutput:_videoOutput];
  _videoOutput = nil;
}

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
@end
