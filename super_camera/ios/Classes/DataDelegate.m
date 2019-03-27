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
  if (error) {
    NSLog(error.description);
  }
  CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
  _result([self toData:pixelBuffer]);
}

- (NSData *)toData:(CVPixelBufferRef)pixelBuffer {
  CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

  void *planeAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
  size_t height = CVPixelBufferGetHeight(pixelBuffer);

  NSNumber *length = @(bytesPerRow * height);
  NSData *bytes = [NSData dataWithBytes:planeAddress length:length.unsignedIntegerValue];

  CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

  return bytes;
}
@end
