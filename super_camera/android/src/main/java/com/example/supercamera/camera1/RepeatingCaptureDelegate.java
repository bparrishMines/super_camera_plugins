package com.example.supercamera.camera1;

import android.graphics.SurfaceTexture;
import android.hardware.Camera;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public interface RepeatingCaptureDelegate {
  SurfaceTexture createSurfaceTexture(TextureRegistry.SurfaceTextureEntry entry);
  Camera.PreviewCallback createPreviewCallback();
  void finishWithResult(MethodChannel.Result result);
  void close(MethodChannel.Result result);
}
