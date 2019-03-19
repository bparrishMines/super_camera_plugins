package com.example.supercamera.camera1;

import android.graphics.SurfaceTexture;
import android.hardware.Camera;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public interface RepeatingCaptureDelegate {
  SurfaceTexture getSurfaceTexture(TextureRegistry.SurfaceTextureEntry entry);
  Camera.PreviewCallback getPreviewCallback();
  void finishSetup(MethodChannel.Result result);
  void close();
}
