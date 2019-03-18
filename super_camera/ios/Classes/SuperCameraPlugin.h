#import <AVFoundation/AVFoundation.h>
#import <Flutter/Flutter.h>

@interface SuperCameraPlugin : NSObject<FlutterPlugin>
@end

@interface CameraController : NSObject
@property(readonly) NSString *_Nonnull cameraId;
@property(readonly) BOOL hasRepeatingCaptureRequest;

+ (NSArray<NSDictionary *> *_Nonnull)availableCameras;

- (instancetype _Nonnull )initWithCameraId:(NSString *_Nonnull)cameraId;

- (void) putSingleCaptureRequest:(NSDictionary *_Nonnull)settings result:(FlutterResult _Nonnull)result;
- (void) putRepeatingCaptureRequest:(NSDictionary *_Nonnull)settings result:(FlutterResult _Nonnull)result;

- (void) stopRepeatingCaptureRequest:(FlutterResult _Nullable)result;

- (void) close;
@end
