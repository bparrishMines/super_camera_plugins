package com.example.supercamera.camera1.repeating_capture_delegates;

import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import java.util.Map;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public interface RepeatingCaptureDelegate {
  void initialize(Map<String, Object> settings, TextureRegistry textureRegistry);
  void onStart(MethodChannel.Result result);

  SurfaceTexture getSurfaceTexture();
  Camera.PreviewCallback getPreviewCallback();

  void close();
}
