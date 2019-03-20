#import "SuperCameraPlugin.h"

@interface CameraController ()
@property(nonatomic, retain) AVCaptureSession *captureSession;
@property(nonatomic) AVCaptureDevice *captureDevice;
@property(nonatomic) AVCaptureInput *captureVideoInput;
@property(nonatomic) AVCaptureVideoDataOutput *captureVideoOutput;
@end

@implementation CameraController
- (instancetype)initWithCameraId:(NSString *)cameraId {
  self = [super init];
  if (self) {
    _cameraId = cameraId;
    _hasRepeatingCaptureRequest = false;
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

    [allCameraData addObject:@{
      @"cameraId" : [device uniqueID],
      @"lensDirection" : lensFacing,
    }];
  }

  return allCameraData;
}

- (void) open:(FlutterResult _Nonnull)result {
  _captureSession = [AVCaptureSession new];
  _captureDevice = [AVCaptureDevice deviceWithUniqueID:_cameraId];

  _captureVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice
                                                             error:nil];
  _captureVideoOutput = [AVCaptureVideoDataOutput new];

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

  _captureVideoOutput.videoSettings =
      @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};

  [_captureVideoOutput setAlwaysDiscardsLateVideoFrames:YES];

  [_captureSession addInput:_captureVideoInput];
  [_captureSession addOutput:_captureVideoOutput];

  [_captureSession startRunning];

  result(@1);
}

- (void) stopRepeatingCaptureRequest:(FlutterResult _Nonnull)result {
  [_captureSession stopRunning];
  result(nil);
}

- (void) close:(FlutterResult _Nonnull)result {
  if ([_captureSession isRunning]) {
    [_captureSession stopRunning];
  }

  _captureSession = nil;
  result(nil);
}
@end
