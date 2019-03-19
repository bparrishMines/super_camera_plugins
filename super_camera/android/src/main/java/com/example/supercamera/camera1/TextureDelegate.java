package com.example.supercamera.camera1;

import android.graphics.SurfaceTexture;
import android.hardware.Camera;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class TextureDelegate implements RepeatingCaptureDelegate {
  private TextureRegistry.SurfaceTextureEntry entry;

  @Override
  public SurfaceTexture getSurfaceTexture(TextureRegistry.SurfaceTextureEntry entry) {
    this.entry = entry;
    return entry.surfaceTexture();
  }

  @Override
  public Camera.PreviewCallback getPreviewCallback() {
    return null;
  }

  @Override
  public void finishSetup(MethodChannel.Result result) {
    result.success(entry.id());
  }

  @Override
  public void close() {
    entry.release();
  }
}
