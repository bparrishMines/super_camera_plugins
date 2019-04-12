package com.example.supercamera.camera2.video_delegates;

import android.graphics.SurfaceTexture;
import java.util.Map;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public interface VideoDelegate {
  void initialize(Map<String, Object> settings, TextureRegistry textureRegistry);
  SurfaceTexture getPreviewSurfaceTexture();
  void onFinishSetup(MethodChannel.Result result);
  void close();
}
