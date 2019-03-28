package com.example.supercamera.camera1.video_delegates;

import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import java.util.Map;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public interface VideoDelegate {
  void initialize(Map<String, Object> settings, TextureRegistry textureRegistry);

  SurfaceTexture getSurfaceTexture();
  Camera.PreviewCallback getPreviewCallback();

  void onFinishSetup(MethodChannel.Result result);

  void close();
}
