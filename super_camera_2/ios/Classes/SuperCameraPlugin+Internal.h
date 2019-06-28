// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SuperCameraPlugin.h"

@protocol MethodCallHandler
@required
- (void)handleMethodCall:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result;
@end

@interface SuperCameraPlugin (Internal)
+ (void)addMethodHandler:(NSNumber *_Nonnull)handle
           methodHandler:(id<MethodCallHandler> _Nonnull)handler;
+ (void)removeMethodHandler:(NSNumber *_Nonnull)handle;
+ (id<MethodCallHandler>)getHandler:(NSNumber *)handle;
@end

@interface FLTCaptureDiscoverySession : NSObject
+ (NSArray<NSDictionary *> *)devices:(FlutterMethodCall *)call;
@end

@interface FLTCaptureSession : NSObject<MethodCallhandler>
+ (void)startRunning:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result;
+ (void)stopRunning:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result;
@end

@interface PlatformTexture : NSObject<MethodCallHandler, FlutterTexture>
@property id<FlutterTextureRegistry> registry;
@property int64_t textureId;
- (instancetype _Nonnull)initWithTextureRegistry:(NSObject<FlutterTextureRegistry> *_Nonnull)registry
                                          handle:(NSNumber *)handle;
- (void)updatePixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end

@interface FLTCaptureVideoDataOutputSampleBufferDelegate : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
- (instancetype _Nonnull)initWithPlatformTexture:(PlatformTexture *_Nullable)texture;
@end
