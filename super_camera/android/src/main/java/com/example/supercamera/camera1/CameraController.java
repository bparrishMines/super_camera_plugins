package com.example.supercamera.camera1;

import com.example.supercamera.base.BaseCameraController;

import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class CameraController extends BaseCameraController {
  public CameraController(final String cameraId) {
    super(cameraId);
  }

  @Override
  public void putSingleCaptureRequest(Map<String, Object> settings, MethodChannel.Result result) {
    throw new UnsupportedOperationException();
  }

  @Override
  public void putRepeatingCaptureRequest(Map<String, Object> settings, MethodChannel.Result result) {
    throw new UnsupportedOperationException();
  }

  @Override
  public void stopRepeatingCaptureRequest(MethodChannel.Result result) {
    throw new UnsupportedOperationException();
  }

  @Override
  public void close() {
    throw new UnsupportedOperationException();
  }
}
