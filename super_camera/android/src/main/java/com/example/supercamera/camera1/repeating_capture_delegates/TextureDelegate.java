package com.example.supercamera.camera1.repeating_capture_delegates;

import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import java.util.Map;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class TextureDelegate implements RepeatingCaptureDelegate {
  private TextureRegistry.SurfaceTextureEntry entry;

  @Override
  public void initialize(Map<String,Object> settings, TextureRegistry textureRegistry) {
    this.entry = textureRegistry.createSurfaceTexture();
  }

  @Override
  public void onStart(MethodChannel.Result result) {
    result.success(entry.id());
  }

  @Override
  public SurfaceTexture getSurfaceTexture() {
    return entry.surfaceTexture();
  }

  @Override
  public Camera.PreviewCallback getPreviewCallback() {
    return null;
  }

  @Override
  public void close() {
    entry.release();
  }
}
