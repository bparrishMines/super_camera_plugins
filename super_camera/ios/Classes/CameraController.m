#import <AVFoundation/AVFoundation.h>
#import "SuperCameraPlugin.h"

@interface CameraController ()
@property(nonatomic, retain) AVCaptureSession *captureSession;
@property(readonly, nonatomic) AVCaptureDevice *captureDevice;
@property(readonly, nonatomic) AVCaptureInput *captureVideoInput;
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

- (void) open {
  _captureSession = [[AVCaptureSession alloc] init];
  _captureDevice = [AVCaptureDevice deviceWithUniqueID:_cameraId];

  _captureVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice
                                                             error:nil];
}

- (void) putSingleCaptureRequest:(NSDictionary *)settings result:(FlutterResult)result {
    
}

- (void) putRepeatingCaptureRequest:(NSDictionary *)settings result:(FlutterResult)result {
    
}

- (void) stopRepeatingCaptureRequest:(FlutterResult _Nullable)result {
    
}

- (void) close {
  if ([_captureSession isRunning]) {
    return [_captureSession stopRunning];
  }
}
@end
