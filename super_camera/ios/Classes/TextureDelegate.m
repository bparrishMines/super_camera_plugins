#import "SuperCameraPlugin.h"
#import <libkern/OSAtomic.h>

@interface TextureDelegate ()
@property id<FlutterTextureRegistry> textureRegistry;
@property int64_t textureId;
@property CVPixelBufferRef volatile latestPixelBuffer;
@end

@implementation TextureDelegate
- (void)initialize:(NSObject<FlutterTextureRegistry> *)textureRegistry
            result:(FlutterResult)result {
  _textureRegistry = textureRegistry;
  _textureId = [_textureRegistry registerTexture:self];
  result(@(_textureId));
}

- (void)close:(FlutterResult)result {
  [_textureRegistry unregisterTexture:_textureId];
  if (_latestPixelBuffer) {
    CFRelease(_latestPixelBuffer);
  }
  result(nil);
}

- (void)captureOutput:(AVCaptureOutput *)output
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
            fromConnection:(AVCaptureConnection *)connection {
  CVPixelBufferRef newBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  CFRetain(newBuffer);
  
  CVPixelBufferRef old = _latestPixelBuffer;
  while (!OSAtomicCompareAndSwapPtrBarrier(old, newBuffer, (void **)&_latestPixelBuffer)) {
    old = _latestPixelBuffer;
  }
  
  if (old) {
    CFRelease(old);
  }

  [_textureRegistry textureFrameAvailable:_textureId];
}

- (CVPixelBufferRef)copyPixelBuffer {
  CVPixelBufferRef pixelBuffer = _latestPixelBuffer;
  while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, (void **)&_latestPixelBuffer)) {
    pixelBuffer = _latestPixelBuffer;
  }
  
  return pixelBuffer;
}
@end
