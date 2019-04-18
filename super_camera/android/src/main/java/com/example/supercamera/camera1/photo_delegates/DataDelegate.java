package com.example.supercamera.camera1.photo_delegates;

import android.hardware.Camera;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class DataDelegate implements PhotoDelegate {
  private EventChannel.EventSink eventSink;

  @Override
  public void initialize(
      Map<String, Object> settings, TextureRegistry textureRegistry, BinaryMessenger messenger) {
    final String channelName = (String) settings.get("channelName");
    final EventChannel eventChannel = new EventChannel(messenger, channelName);

    eventChannel.setStreamHandler(
        new EventChannel.StreamHandler() {
          @Override
          public void onListen(Object arguments, EventChannel.EventSink sink) {
            eventSink = sink;
          }

          @Override
          public void onCancel(Object arguments) {}
        });
  }

  @Override
  public Camera.ShutterCallback getShutterCallback() {
    return null;
  }

  @Override
  public Camera.PictureCallback getRawCallback() {
    return null;
  }

  @Override
  public Camera.PictureCallback getPostViewCallback() {
    return null;
  }

  @Override
  public Camera.PictureCallback getJpegCallback() {
    return new Camera.PictureCallback() {
      @Override
      public void onPictureTaken(byte[] data, Camera camera) {
        eventSink.success(data);
      }
    };
  }

  @Override
  public void onFinishSetup(MethodChannel.Result result) {
    result.success(null);
  }

  @Override
  public void close() {
    eventSink.endOfStream();
  }
}
