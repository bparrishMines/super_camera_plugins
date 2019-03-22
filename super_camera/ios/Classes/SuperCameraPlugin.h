#import <AVFoundation/AVFoundation.h>
#import <Flutter/Flutter.h>

@interface SuperCameraPlugin : NSObject<FlutterPlugin>
@end

@interface CameraController : NSObject
@property(readonly) NSString *_Nonnull cameraId;

+ (NSArray<NSDictionary *> *_Nonnull)availableCameras;

- (instancetype _Nonnull)initWithCameraId:(NSString *_Nonnull)cameraId
                          textureRegistry:(NSObject<FlutterTextureRegistry> *_Nonnull)textureRegistry;

- (void) putSingleCaptureRequest:(NSDictionary *_Nonnull)settings result:(FlutterResult _Nonnull)result;
- (void) putRepeatingCaptureRequest:(NSDictionary *_Nonnull)settings result:(FlutterResult _Nonnull)result;
- (void) stopRepeatingCaptureRequest:(FlutterResult _Nonnull)result;

- (void) open:(FlutterResult _Nonnull)result;
- (void) close:(FlutterResult _Nonnull)result;
@end

@protocol RepeatingCaptureDelegate <AVCaptureVideoDataOutputSampleBufferDelegate>
@required
- (void)initialize:(NSObject<FlutterTextureRegistry> *_Nonnull)textureRegistry
            result:(FlutterResult _Nonnull)result;
- (void)close:(FlutterResult _Nonnull)result;
@end

@interface TextureDelegate : NSObject<RepeatingCaptureDelegate, FlutterTexture>
@end
