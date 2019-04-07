package com.example.supercamera.camera2.video_delegates;

import android.graphics.SurfaceTexture;
import java.util.Map;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class TextureDelegate implements VideoDelegate {
  private TextureRegistry.SurfaceTextureEntry entry;

  @Override
  public void initialize(Map<String, Object> settings, TextureRegistry textureRegistry) {
    this.entry = textureRegistry.createSurfaceTexture();
  }

  @Override
  public SurfaceTexture getSurfaceTexture() {
    return entry.surfaceTexture();
  }

  @Override
  public void onFinishSetup(MethodChannel.Result result) {
    result.success(entry.id());
  }

  @Override
  public void close() {
    entry.release();
  }
}
