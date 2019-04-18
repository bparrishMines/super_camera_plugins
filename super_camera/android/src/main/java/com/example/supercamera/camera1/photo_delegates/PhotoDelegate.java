package com.example.supercamera.camera1.photo_delegates;

import android.hardware.Camera;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public interface PhotoDelegate {
  void initialize(
      Map<String, Object> settings, TextureRegistry textureRegistry, BinaryMessenger messenger);

  Camera.ShutterCallback getShutterCallback();
  Camera.PictureCallback getRawCallback();
  Camera.PictureCallback getPostViewCallback();
  Camera.PictureCallback getJpegCallback();

  void onFinishSetup(MethodChannel.Result result);

  void close();
}
