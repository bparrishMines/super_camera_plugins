package com.example.supercamera.base;

import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public abstract class BaseCameraController {
  public final String cameraId;

  public boolean hasRepeatingCaptureRequest = false;

  public BaseCameraController(final String cameraId) {
    this.cameraId = cameraId;
  }

  public abstract void putSingleCaptureRequest(Map<String, Object> settings, MethodChannel.Result result);
  public abstract void putRepeatingCaptureRequest(Map<String, Object> settings, MethodChannel.Result result);

  public abstract void stopRepeatingCaptureRequest(MethodChannel.Result result);

  public abstract void close();
}
