package com.example.supercamera.base;

import java.util.Map;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public abstract class BaseCameraController implements MethodChannel.MethodCallHandler {
  protected final String cameraId;
  protected final TextureRegistry textureRegistry;

  public BaseCameraController(final String cameraId, final TextureRegistry textureRegistry) {
    this.cameraId = cameraId;
    this.textureRegistry = textureRegistry;
  }

  public abstract void open(MethodChannel.Result result);

  public abstract void putSingleCaptureRequest(Map<String, Object> settings, MethodChannel.Result result);

  public abstract void putRepeatingCaptureRequest(Map<String, Object> settings, MethodChannel.Result result);
  public abstract void stopRepeatingCaptureRequest();

  public abstract void close();
}
