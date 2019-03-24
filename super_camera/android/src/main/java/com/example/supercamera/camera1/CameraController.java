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

    final SurfaceTexture surfaceTexture =
        repeatingCaptureDelegate.createSurfaceTexture(textureRegistry.createSurfaceTexture());
    if (surfaceTexture != null) {
      try {
        camera.setPreviewTexture(surfaceTexture);
      } catch (IOException exception) {
        result.error(exception.getClass().getSimpleName(), exception.getMessage(), null);
        return;
      }
    }

    final Camera.PreviewCallback callback = repeatingCaptureDelegate.createPreviewCallback();
    if (callback != null) {
      camera.setPreviewCallback(callback);
    }

    camera.startPreview();

    repeatingCaptureDelegate.finishWithResult(result);
  }

  @Override
  public void stopRepeatingCaptureRequest(MethodChannel.Result result) {
    camera.stopPreview();

    if (repeatingCaptureDelegate != null) {
      repeatingCaptureDelegate.close(result);
      repeatingCaptureDelegate = null;
    } else {
      result.success(null);
    }
  }

  @Override
  public void close(MethodChannel.Result result) {
    camera.stopPreview();
    camera.release();
    camera = null;

    if (repeatingCaptureDelegate != null) {
      repeatingCaptureDelegate.close(result);
      repeatingCaptureDelegate = null;
    } else {
      result.success(null);
    }
  }
}
