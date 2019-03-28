#import <AVFoundation/AVFoundation.h>
#import <Flutter/Flutter.h>

@interface SuperCameraPlugin : NSObject<FlutterPlugin>
@end

@interface CameraController : NSObject<FlutterPlugin>
@property NSString *_Nonnull cameraId;

+ (NSArray<NSDictionary *> *_Nonnull)availableCameras;

- (instancetype _Nonnull)initWithCameraId:(NSString *_Nonnull)cameraId
                          textureRegistry:(NSObject<FlutterTextureRegistry> *_Nonnull)textureRegistry;

- (void) open:(FlutterResult _Nonnull)result;
- (void) startRunning:(FlutterResult _Nonnull)result;

- (void) takePhoto:(NSDictionary *_Nonnull)settings result:(FlutterResult _Nonnull)result;
- (void) setVideoSettings:(NSDictionary *_Nonnull)settings result:(FlutterResult _Nonnull)result;

- (void) stopRunning;
- (void) close;
@end

@protocol VideoDelegate <AVCaptureVideoDataOutputSampleBufferDelegate>
@required
- (void)initialize:(NSDictionary * _Nullable)settings
   textureRegistry:(NSObject<FlutterTextureRegistry> *_Nonnull)textureRegistry;
- (void)onFinishSetup:(FlutterResult _Nonnull)result;
- (void)close;
@end

@protocol PhotoDelegate <AVCapturePhotoCaptureDelegate>
@required
- (void)initialize:(NSDictionary *_Nullable)settings
   textureRegistry:(NSObject<FlutterTextureRegistry> *_Nonnull)textureRegistry
            result:(FlutterResult _Nonnull)result;
- (void)onImageTaken:(CMSampleBufferRef _Nullable)imageDataSampleBuffer
               error:(NSError *_Nullable)error;
@end

@interface TextureDelegate : NSObject<VideoDelegate, FlutterTexture>
@end

@interface DataDelegate : NSObject<PhotoDelegate>
@end
