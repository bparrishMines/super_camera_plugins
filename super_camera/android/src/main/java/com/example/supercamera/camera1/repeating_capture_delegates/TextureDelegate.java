package com.example.supercamera.camera1.repeating_capture_delegates;

import android.graphics.SurfaceTexture;
import android.hardware.Camera;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class TextureDelegate implements RepeatingCaptureDelegate {
  private TextureRegistry.SurfaceTextureEntry entry;

  @Override
  public SurfaceTexture createSurfaceTexture(TextureRegistry.SurfaceTextureEntry entry) {
    this.entry = entry;
    return entry.surfaceTexture();
  }

  @Override
  public Camera.PreviewCallback createPreviewCallback() {
    return null;
  }

  @Override
  public void finishWithResult(MethodChannel.Result result) {
    result.success(entry.id());
  }

  @Override
  public void close(MethodChannel.Result result) {
    entry.release();
    result.success(null);
  }
}
