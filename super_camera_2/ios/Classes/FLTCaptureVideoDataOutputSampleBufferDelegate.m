// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SuperCameraPlugin+Internal.h"

@interface FLTCaptureVideoDataOutputSampleBufferDelegate ()
@property PlatformTexture *texture;
@end

@implementation FLTCaptureVideoDataOutputSampleBufferDelegate
- (instancetype _Nonnull)initWithPlatformTexture:(PlatformTexture *_Nullable)texture {
  self = [self init];
  if (self) {
    _texture = texture;
  }
  
  return self;
}

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
  CVPixelBufferRef newBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  //CFRetain(newBuffer);
  
  if (_texture) {
    [_texture updatePixelBuffer:newBuffer];
  }
}
@end
