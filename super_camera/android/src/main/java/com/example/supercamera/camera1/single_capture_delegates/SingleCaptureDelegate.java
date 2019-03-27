package com.example.supercamera.camera1.single_capture_delegates;

import android.hardware.Camera;
import java.util.Map;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public interface SingleCaptureDelegate {
  void initialize(
      Map<String, Object> settings, TextureRegistry textureRegistry, MethodChannel.Result result);

  Camera.ShutterCallback getShutterCallback();
  Camera.PictureCallback getRawCallback();
  Camera.PictureCallback getPostViewCallback();
  Camera.PictureCallback getJpegCallback();
}
