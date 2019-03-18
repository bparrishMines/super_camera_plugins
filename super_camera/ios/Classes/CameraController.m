#import <Foundation/Foundation.h>
#import "SuperCameraPlugin.h"

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
  return nil;
}

- (void) putSingleCaptureRequest:(NSDictionary *)settings result:(FlutterResult)result {
    
}

- (void) putRepeatingCaptureRequest:(NSDictionary *)settings result:(FlutterResult)result {
    
}

- (void) stopRepeatingCaptureRequest:(FlutterResult _Nullable)result {
    
}

- (void) close {
    
}
@end
