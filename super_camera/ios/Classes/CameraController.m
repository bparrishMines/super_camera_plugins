#import "SuperCameraPlugin.h"
#import <libkern/OSAtomic.h>

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
- (instancetype)initWithCameraId:(NSString *)cameraId
                 textureRegistry:(NSObject<FlutterTextureRegistry> *)textureRegistry {
  self = [super init];
  if (self) {
    _cameraId = cameraId;
    _textureRegistry = textureRegistry;
  }
  return self;
}

+ (NSArray<NSDictionary *> *)availableCameras {
  NSArray<AVCaptureDevice *> *devices;

  if (@available(iOS 10.0, *)) {
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
          discoverySessionWithDeviceTypes:@[ AVCaptureDeviceTypeBuiltInWideAngleCamera ]
                                mediaType:AVMediaTypeVideo
                                 position:AVCaptureDevicePositionUnspecified];
    devices = discoverySession.devices;
  } else {
    devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  }

  NSMutableArray<NSDictionary<NSString *, NSObject *> *> *allCameraData = [[NSMutableArray alloc] initWithCapacity:devices.count];

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

  [_repeatingCaptureDelegate initialize:_textureRegistry];

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

  [self setShouldMirror:settings[@"shouldMirror"]];

  [_captureSession startRunning];

  [_repeatingCaptureDelegate onStart:result];
}

- (void)stopRepeatingCaptureRequest:(FlutterResult)result {
  if (![_captureSession isRunning] || ![[_captureSession outputs] containsObject:_captureVideoOutput]) {
    result(nil);
    return;
  }

  [_captureSession stopRunning];

  [self removeCaptureVideoInputsAndOutputs];
  [self closeRepeatingCaptureDelegate:result];
}

- (void) close:(FlutterResult)result {
  if ([_captureSession isRunning]) {
    [_captureSession stopRunning];
    [self removeCaptureVideoInputsAndOutputs];
  }

  _captureSession = nil;
  _captureDevice = nil;
  [self closeRepeatingCaptureDelegate:result];
}

// Helper Methods
- (void)closeRepeatingCaptureDelegate:(FlutterResult)result {
  if (!_repeatingCaptureDelegate) {
    result(nil);
    return;
  }

  [_repeatingCaptureDelegate close:result];
  _repeatingCaptureDelegate = nil;
}

- (void)removeCaptureVideoInputsAndOutputs {
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
@end
