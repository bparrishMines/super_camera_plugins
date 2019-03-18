package com.example.supercamera.camera1;

import android.hardware.Camera;

import com.example.supercamera.base.BaseCameraController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class CameraController extends BaseCameraController {
  public CameraController(final String cameraId) {
    super(cameraId);
  }

  public static List<Map<String, Object>> availableCameras() {
    List<Map<String, Object>> allCameraData = new ArrayList<>();

    for (int i = 0, count = Camera.getNumberOfCameras(); i < count; i++) {
      Camera.CameraInfo info = new Camera.CameraInfo();
      Camera.getCameraInfo(i, info);

      Map<String, Object> cameraData = new HashMap<>();
      cameraData.put("cameraId", String.valueOf(i));

      switch(info.facing) {
        case Camera.CameraInfo.CAMERA_FACING_FRONT:
          cameraData.put("lensDirection", "front");
          break;
        case Camera.CameraInfo.CAMERA_FACING_BACK:
          cameraData.put("lensDirection", "back");
          break;
      }

      allCameraData.add(cameraData);
    }

    return allCameraData;
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
