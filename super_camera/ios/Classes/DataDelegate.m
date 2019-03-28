#import "SuperCameraPlugin.h"

@interface DataDelegate ()
@property FlutterResult result;
@end

@implementation DataDelegate
- (void)initialize:(NSDictionary * _Nullable)settings
   textureRegistry:(NSObject<FlutterTextureRegistry> *_Nonnull)textureRegistry
            result:(FlutterResult _Nonnull)result {
  _result = result;
}

- (void)onRelease {

}

- (void)onImageTaken:(CMSampleBufferRef _Nullable)imageDataSampleBuffer error:(NSError *_Nullable)error {
  NSData *bytes = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
  _result(bytes);
}
@end
