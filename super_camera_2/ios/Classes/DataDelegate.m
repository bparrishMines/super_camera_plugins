#import "SuperCameraPlugin.h"

@interface DataDelegate ()
@property FlutterEventSink eventSink;
@end

@implementation DataDelegate
- (void)initialize:(NSDictionary * _Nullable)settings
   textureRegistry:(NSObject<FlutterTextureRegistry> * _Nonnull)textureRegistry
            messenger:(NSObject<FlutterBinaryMessenger> * _Nonnull)messenger {
  NSString *channelName = settings[@"channelName"];
  FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:channelName
                                                                binaryMessenger:messenger];

  [eventChannel setStreamHandler:self];
}

- (void)onImageTaken:(CMSampleBufferRef _Nullable)imageDataSampleBuffer error:(NSError *_Nullable)error {
  if (error) {
    _eventSink([FlutterError errorWithCode:@"CameraNotOpenException"
                               message:error.description
                               details:nil]);
    return;
  }

  NSData *bytes = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
  _eventSink(bytes);
}

- (void)close {
  _eventSink = nil;
}


- (void)onFinishSetup:(FlutterResult _Nonnull)result {
  result(nil);
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                        eventSink:(nonnull FlutterEventSink)events {
  _eventSink = events;
  return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _eventSink = nil;
  return nil;
}

@end
