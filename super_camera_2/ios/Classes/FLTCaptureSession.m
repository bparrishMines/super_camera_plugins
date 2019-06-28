// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SuperCameraPlugin+Internal.h"

@interface FLTCaptureSession ()
@property AVCaptureSession *session;
@property NSNumber *handle;
@end

@implementation FLTCaptureSession
- (instancetype _Nonnull)initWithSession:(AVCaptureSession *)session handle:(NSNumber *)handle {
  self = [super init];
  if (self) {
    _session = session;
    _handle = handle;
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
  if ([@"CaptureSession#addOutput" isEqualToString:call.method]) {
    [self addOutput:call result:result];
  } else if ([@"CaptureSession#removeOutput" isEqualToString:call.method]) {
    [self removeOutput:call result:result];
  } else if ([@"CaptureSession#addInput" isEqualToString:call.method]) {
    [self addInput:call result:result];
  } else if ([@"CaptureSession#removeInput" isEqualToString:call.method]) {
    [self removeInput:call result:result];
  } else if ([@"CaptureSession#stopRunning" isEqualToString:call.method]) {
    [self stopRunning:call];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

+ (void)startRunning:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
  AVCaptureSession *session = [AVCaptureSession new];
  
  NSArray<NSDictionary *> *inputs = call.arguments[@"inputs"];
  for (NSDictionary *inputData in inputs) {
    if ([@"_CaptureInputClass.captureDeviceInput" isEqualToString:inputData[@"class"]]) {
      NSDictionary *deviceData = inputData[@"device"];
      
      NSString *uniqueId = deviceData[@"uniqueId"];
      AVCaptureDevice *captureDevice = [AVCaptureDevice deviceWithUniqueID:uniqueId];
      AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput
                                           deviceInputWithDevice:captureDevice error:nil];
      
      [session addInput:deviceInput];
    }
  }
  
  NSArray<NSDictionary *> *outputs = call.arguments[@"outputs"];
  for (NSDictionary *outputData in outputs) {
    if ([@"_CaptureOutputClass.captureVideoDataOutput" isEqualToString:outputData[@"class"]]) {
      AVCaptureVideoDataOutput *dataOutput = [AVCaptureVideoDataOutput new];
      
      NSString *formatStr = outputData[@"formatType"];
      if (formatStr) {
        if ([@"PixelFormatType.bgra32" isEqualToString:formatStr]) {
          dataOutput.videoSettings =
              @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
        }
      }
      
      NSDictionary *delegateData = outputData[@"delegate"];
      if (delegateData) {
        NSNumber *textureHandle = call.arguments[@"textureHandle"];
        PlatformTexture *texture = nil;
        if (textureHandle) {
          texture = (PlatformTexture *) [SuperCameraPlugin getHandler:textureHandle];
        }
        
        FLTCaptureVideoDataOutputSampleBufferDelegate *delegate = [[FLTCaptureVideoDataOutputSampleBufferDelegate alloc] initWithPlatformTexture:texture];
        
        [dataOutput setSampleBufferDelegate:delegate queue:nil];
      }
    }
  }
  
  NSNumber *handle = call.arguments[@"sessionHandle"];
  FLTCaptureSession *fltSession = [[FLTCaptureSession alloc] initWithSession:session
                                                                      handle:handle];
  [SuperCameraPlugin addMethodHandler:handle methodHandler:fltSession];
}

- (void)stopRunning:(FlutterMethodCall *_Nonnull)call {
  [_session stopRunning];
  [SuperCameraPlugin removeMethodHandler:_handle];
}

- (void)addOutput:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result {
  
}

- (void)removeOutput:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result {
  
}

- (void)addInput:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result {
  
}

- (void)removeInput:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result {
  
}
@end
