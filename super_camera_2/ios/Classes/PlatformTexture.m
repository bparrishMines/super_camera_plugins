// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SuperCameraPlugin+Internal.h"
#import <libkern/OSAtomic.h>

@interface PlatformTexture ()
@property CVPixelBufferRef volatile latestPixelBuffer;
@property NSNumber *handle;
@end

@implementation PlatformTexture
- (instancetype _Nonnull)initWithTextureRegistry:(NSObject<FlutterTextureRegistry> *_Nonnull)registry
                                          handle:(NSNumber *)handle {
  self = [self init];
  if (self) {
    _registry = registry;
    _textureId = [_registry registerTexture:self];
    _handle = handle;
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
  if ([@"PlatformTexture#release" isEqualToString:call.method]) {
    [self release:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (CVPixelBufferRef)copyPixelBuffer {
  CVPixelBufferRef pixelBuffer = _latestPixelBuffer;
  while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, (void **)&_latestPixelBuffer)) {
    pixelBuffer = _latestPixelBuffer;
  }

  return pixelBuffer;
}

- (void)updatePixelBuffer:(CVPixelBufferRef)pixelBuffer {
  CFRetain(pixelBuffer);

  CVPixelBufferRef old = _latestPixelBuffer;
  while (!OSAtomicCompareAndSwapPtrBarrier(old, pixelBuffer, (void **)&_latestPixelBuffer)) {
    old = _latestPixelBuffer;
  }

  if (old) {
    CFRelease(old);
  }

  [_registry textureFrameAvailable:_textureId];
}

- (void)release:(FlutterResult)result {
  [_registry unregisterTexture:_textureId];
  if (_latestPixelBuffer) {
    CFRelease(_latestPixelBuffer);
  }

  [SuperCameraPlugin removeMethodHandler:_handle];

  result(nil);
}
@end
