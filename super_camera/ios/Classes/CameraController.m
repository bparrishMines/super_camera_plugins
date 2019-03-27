#import "SuperCameraPlugin.h"

@interface CameraController ()
@property id<FlutterTextureRegistry> textureRegistry;
@property id<RepeatingCaptureDelegate> repeatingCaptureDelegate;
@property AVCaptureSession *captureSession;
@property AVCaptureDevice *captureDevice;
@property AVCaptureInput *captureVideoInput;
@property AVCaptureVideoDataOutput *captureVideoOutput;
@property AVCaptureConnection *captureVideoConnection;
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
    result(nil);
  } else if ([@"CameraController#close" isEqualToString:call.method]) {
    [self close];
    result(nil);
  } else if ([@"CameraController#putRepeatingCaptureRequest" isEqualToString:call.method]) {
    [self putRepeatingCaptureRequest:call.arguments result:result];
    result(nil);
  } else if ([@"CameraController#stopRepeatingCaptureRequest" isEqualToString:call.method]) {
    [self stopRepeatingCaptureRequest];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
  // Do nothing
}

- (void) open:(FlutterResult _Nonnull)result {
  _captureSession = [AVCaptureSession new];
  _captureDevice = [AVCaptureDevice deviceWithUniqueID:_cameraId];
  result(nil);
}

- (void) putSingleCaptureRequest:(NSDictionary *)settings result:(FlutterResult _Nonnull)result {

}

- (void) putRepeatingCaptureRequest:(NSDictionary *)settings result:(FlutterResult _Nonnull)result {
  if (!_captureSession) {
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

  _captureVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice
                                                             error:nil];
  [_captureSession addInputWithNoConnections:_captureVideoInput];

  _captureVideoOutput = [AVCaptureVideoDataOutput new];
  _captureVideoOutput.videoSettings =
      @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
  [_captureVideoOutput setAlwaysDiscardsLateVideoFrames:YES];
  [_captureSession addOutputWithNoConnections:_captureVideoOutput];
  [_captureVideoOutput setSampleBufferDelegate:_repeatingCaptureDelegate queue:dispatch_get_main_queue()];

  _captureVideoConnection = [AVCaptureConnection
                             connectionWithInputPorts:_captureVideoInput.ports
                                               output:_captureVideoOutput];
  [_captureSession addConnection:_captureVideoConnection];

  @try {
    [self setShouldMirror:settings[@"shouldMirror"]];
    [self setResolution:settings[@"width"] height:settings[@"height"]];
  } @catch (NSException *exception) {
    [self stopRepeatingCaptureRequest];
    result([FlutterError errorWithCode:exception.name message:exception.reason details:nil]);
    return;
  }

  [_captureSession startRunning];
  [_repeatingCaptureDelegate onStart:result];
}

- (void)stopRepeatingCaptureRequest {
  if (!_captureSession) return;

  if ([_captureSession isRunning]) {
    [_captureSession stopRunning];
  }

  if ([[_captureSession outputs] containsObject:_captureVideoOutput]) {
    [self removeCaptureVideoInputsAndOutputs];
  }

  [self closeRepeatingCaptureDelegate];
}

- (void) close {
  if (!_captureSession) return;

  [self stopRepeatingCaptureRequest];

  _captureSession = nil;
  _captureDevice = nil;
}

// Helper Methods
- (void)closeRepeatingCaptureDelegate {
  if (!_repeatingCaptureDelegate) return;

  [_repeatingCaptureDelegate close];
  _repeatingCaptureDelegate = nil;
}

- (void)removeCaptureVideoInputsAndOutputs {
  if (!_captureSession) return;

  [_captureSession removeConnection:_captureVideoConnection];
  _captureVideoConnection = nil;

  [_captureSession removeInput:_captureVideoInput];
  _captureVideoInput = nil;

  [_captureSession removeOutput:_captureVideoOutput];
  _captureVideoOutput = nil;
}

- (void)setShouldMirror:(NSNumber *)shouldMirror {
  _captureVideoConnection.videoMirrored = shouldMirror.boolValue;
}

- (void)setResolution:(NSNumber *)width height:(NSNumber *)height {
  if ([width isEqual:[NSNull null]] || [height isEqual:[NSNull null]]) {
    return;
  }

  BOOL shouldThrowException = NO;

  if (width.intValue == 3840 && height.intValue == 2160) {
    if (@available(iOS 9.0, *)) {
      _captureSession.sessionPreset = AVCaptureSessionPreset3840x2160;
    } else {
      shouldThrowException = YES;
    }
  } else if (width.intValue == 1920 && height.intValue == 1080) {
    _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
  } else if (width.intValue == 1280 && height.intValue == 720) {
    _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
  } else if (width.intValue == 640 && height.intValue == 480) {
    _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
  } else if (width.intValue == 352 && height.intValue == 288) {
    _captureSession.sessionPreset = AVCaptureSessionPreset352x288;
  } else {
    shouldThrowException = YES;
  }

  if (shouldThrowException) {
    NSString *reason = [NSString stringWithFormat:@"Invalid capture size of Size(%@, %@)", width, height];
    @throw [NSException exceptionWithName:@"InvalidArgumentException" reason:reason userInfo:nil];
  }
}
@end
