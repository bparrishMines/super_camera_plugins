package com.example.supercamera.common;

import com.example.supercamera.SuperCameraPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class NativeTexture implements MethodChannel.MethodCallHandler {
  public final TextureRegistry.SurfaceTextureEntry textureEntry;
  private final Integer handle;

  public NativeTexture(TextureRegistry.SurfaceTextureEntry textureEntry, Integer handle) {
    this.textureEntry = textureEntry;
    this.handle = handle;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (call.method.equals("NativeTexture#release")) {
      release(result);
    } else {
      result.notImplemented();
    }
  }

  private void release(MethodChannel.Result result) {
    textureEntry.release();
    SuperCameraPlugin.removeHandler(handle);
    result.success(null);
  }
}
