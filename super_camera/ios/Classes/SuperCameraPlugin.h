#import <AVFoundation/AVFoundation.h>
#import <Flutter/Flutter.h>

@interface SuperCameraPlugin : NSObject<FlutterPlugin>
@end

@interface CameraController : NSObject<FlutterPlugin>
@property NSString *_Nonnull cameraId;

+ (NSArray<NSDictionary *> *_Nonnull)availableCameras;

- (instancetype _Nonnull)initWithCameraId:(NSString *_Nonnull)cameraId
                          textureRegistry:(NSObject<FlutterTextureRegistry> *_Nonnull)textureRegistry;

- (void) putSingleCaptureRequest:(NSDictionary *_Nonnull)settings result:(FlutterResult _Nonnull)result;
- (void) putRepeatingCaptureRequest:(NSDictionary *_Nonnull)settings result:(FlutterResult _Nonnull)result;
- (void) stopRepeatingCaptureRequest;

- (void) open:(FlutterResult _Nonnull)result;
- (void) close;
@end

@protocol RepeatingCaptureDelegate <AVCaptureVideoDataOutputSampleBufferDelegate>
@required
- (void)initialize:(NSDictionary * _Nullable)settings
   textureRegistry:(NSObject<FlutterTextureRegistry> *_Nonnull)textureRegistry;
- (void)onStart:(FlutterResult _Nonnull)result;
- (void)close;
@end

@interface TextureDelegate : NSObject<RepeatingCaptureDelegate, FlutterTexture>
@end
