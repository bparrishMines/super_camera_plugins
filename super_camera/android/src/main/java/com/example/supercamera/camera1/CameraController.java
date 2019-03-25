package com.example.supercamera.camera1;

import android.graphics.SurfaceTexture;
import android.hardware.Camera;

import com.example.supercamera.base.BaseCameraController;
import com.example.supercamera.camera1.repeating_capture_delegates.RepeatingCaptureDelegate;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class CameraController extends BaseCameraController {
  private Camera camera;
  private RepeatingCaptureDelegate repeatingCaptureDelegate;

  public CameraController(final String cameraId, final TextureRegistry textureRegistry) {
    super(cameraId, textureRegistry);
  }

  public static List<Map<String, Object>> availableCameras() {
    List<Map<String, Object>> allCameraData = new ArrayList<>();

    for (int i = 0, count = Camera.getNumberOfCameras(); i < count; i++) {
      final Camera.CameraInfo info = new Camera.CameraInfo();
      Camera.getCameraInfo(i, info);

      final Map<String, Object> cameraData = new HashMap<>();
      cameraData.put("cameraId", String.valueOf(i));

      switch(info.facing) {
        case Camera.CameraInfo.CAMERA_FACING_FRONT:
          cameraData.put("lensDirection", "front");

          // We subtract orientation from 360 to compensate for the automatic mirroring of the front
          // camera. See
          // https://developer.android.com/reference/android/hardware/Camera.html#setDisplayOrientation(int)
          cameraData.put("orientation", 360 - info.orientation % 360);
          break;
        case Camera.CameraInfo.CAMERA_FACING_BACK:
          cameraData.put("lensDirection", "back");
          cameraData.put("orientation", info.orientation);
          break;
      }

      final Camera camera = Camera.open(i);
      final Camera.Parameters parameters = camera.getParameters();

      final List<Camera.Size> repeatingCaptureSizes = parameters.getSupportedPreviewSizes();

      final List<int[]> allRepeatingCaptureSizeData = new ArrayList<>();
      for (Camera.Size size : repeatingCaptureSizes) {
        allRepeatingCaptureSizeData.add(new int[]{size.width, size.height});
      }

      cameraData.put("repeatingCaptureSizes", allRepeatingCaptureSizeData);

      camera.release();

      allCameraData.add(cameraData);
    }

    return allCameraData;
  }

  @Override
  public void open(MethodChannel.Result result) {
    camera = Camera.open(Integer.parseInt(cameraId));
    result.success(null);
  }

  @Override
  public void putSingleCaptureRequest(Map<String, Object> settings, MethodChannel.Result result) {
    throw new UnsupportedOperationException();
  }

  @Override
  public void putRepeatingCaptureRequest(Map<String, Object> settings, MethodChannel.Result result) {
    if (camera == null) {
      result.error("CameraNotOpenException", "Camera is not open.", null);
      return;
    }

    final String androidDelegateName = (String) settings.get("androidDelegateName");
    if (androidDelegateName == null) {
      result.error("CameraDelegateNameIsNull", "Camera delegate name is null.", null);
      return;
    }

    try {
      repeatingCaptureDelegate =
          (RepeatingCaptureDelegate) Class.forName(androidDelegateName).newInstance();
    } catch (Exception exception) {
      result.error(exception.getClass().getSimpleName(), exception.getMessage(), null);
      return;
    }

    repeatingCaptureDelegate.initialize(textureRegistry);

    final SurfaceTexture surfaceTexture = repeatingCaptureDelegate.getSurfaceTexture();
    if (surfaceTexture != null) {
      try {
        camera.setPreviewTexture(surfaceTexture);
      } catch (IOException exception) {
        repeatingCaptureDelegate = null;
        result.error(exception.getClass().getSimpleName(), exception.getMessage(), null);
        return;
      }
    }

    // Before API level 24, the default value for orientation is 0. However, the default could be
    // different for 24+. See
    // https://developer.android.com/reference/android/hardware/Camera.html#setDisplayOrientation(int)
    camera.setDisplayOrientation(0);

    final Camera.Parameters parameters = camera.getParameters();
    setPreviewSize(parameters, (Double) settings.get("width"), (Double) settings.get("height"));

    final Camera.PreviewCallback callback = repeatingCaptureDelegate.getPreviewCallback();
    if (callback != null) {
      camera.setPreviewCallback(callback);
    }

    camera.startPreview();
    repeatingCaptureDelegate.onStart(result);
  }

  @Override
  public void stopRepeatingCaptureRequest(MethodChannel.Result result) {
    camera.stopPreview();
    closeRepeatingCaptureDelegate(result);
  }

  @Override
  public void close(MethodChannel.Result result) {
    camera.stopPreview();
    camera.release();
    camera = null;

    closeRepeatingCaptureDelegate(result);
  }

  // Helper Methods
  private void closeRepeatingCaptureDelegate(MethodChannel.Result result) {
    if (repeatingCaptureDelegate != null) {
      repeatingCaptureDelegate.close(result);
      repeatingCaptureDelegate = null;
    } else {
      result.success(null);
    }
  }

  private void setPreviewSize(final Camera.Parameters parameters, Double width, Double height) {
    if (width != null && height != null) {
      parameters.setPreviewSize(width.intValue(), height.intValue());
    }
  }
}
