package com.example.supercamera.camera1;

import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import com.example.supercamera.base.BaseCameraController;
import com.example.supercamera.camera1.repeating_capture_delegates.RepeatingCaptureDelegate;
import com.example.supercamera.camera1.single_capture_delegates.SingleCaptureDelegate;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class CameraController extends BaseCameraController {
  private static List<Map<String, Object>> availableCameraData;

  public static List<Map<String, Object>> availableCameras() {
    if (availableCameraData != null) return availableCameraData;

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

    availableCameraData = allCameraData;
    return allCameraData;
  }

  private Camera camera;
  private RepeatingCaptureDelegate repeatingCaptureDelegate;

  public CameraController(final String cameraId, final TextureRegistry textureRegistry) {
    super(cameraId, textureRegistry);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch(call.method) {
      case "CameraController#open":
        open(result);
        break;
      case "CameraController#close":
        close();
        result.success(null);
        break;
      case "CameraController#putSingleCaptureRequest":
        Map<String, Object> settings = (Map<String, Object>) call.arguments;
        putSingleCaptureRequest(settings, result);
        break;
      case "CameraController#putRepeatingCaptureRequest":
        Map<String, Object> repeatingSettings = (Map<String, Object>) call.arguments;
        putRepeatingCaptureRequest(repeatingSettings, result);
        break;
      case "CameraController#stopRepeatingCaptureRequest":
        stopRepeatingCaptureRequest();
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void open(MethodChannel.Result result) {
    camera = Camera.open(Integer.parseInt(cameraId));
    result.success(null);
  }

  @Override
  public void putSingleCaptureRequest(Map<String, Object> settings, MethodChannel.Result result) {
    if (camera == null) {
      result.error("CameraNotOpenException", "Camera is not open.", null);
      return;
    }

    final String androidDelegateName = (String) settings.get("androidDelegateName");
    if (androidDelegateName == null) {
      result.error("CameraDelegateNameIsNull", "Camera delegate name is null.", null);
      return;
    }

    SingleCaptureDelegate delegate;
    try {
      delegate = (SingleCaptureDelegate) Class.forName(androidDelegateName).newInstance();
    } catch (Exception exception) {
      result.error(exception.getClass().getSimpleName(), exception.getMessage(), null);
      return;
    }

    Map<String, Object> delegateSettings = (Map<String, Object>) settings.get("delegateSettings");
    delegate.initialize(delegateSettings, textureRegistry, result);

    camera.takePicture(
        delegate.getShutterCallback(),
        delegate.getRawCallback(),
        delegate.getPostViewCallback(),
        delegate.getJpegCallback());
  }

  @Override
  public void putRepeatingCaptureRequest(
      Map<String, Object> settings, MethodChannel.Result result) {
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

    Map<String, Object> delegateSettings = (Map<String, Object>) settings.get("delegateSettings");
    repeatingCaptureDelegate.initialize(delegateSettings, textureRegistry);

    final SurfaceTexture surfaceTexture = repeatingCaptureDelegate.getSurfaceTexture();
    if (surfaceTexture != null) {
      try {
        camera.setPreviewTexture(surfaceTexture);
      } catch (IOException exception) {
        stopRepeatingCaptureRequest();
        result.error(exception.getClass().getSimpleName(), exception.getMessage(), null);
        return;
      }
    }

    final Camera.PreviewCallback callback = repeatingCaptureDelegate.getPreviewCallback();
    if (callback != null) {
      camera.setPreviewCallback(callback);
    }

    // Before API level 24, the default value for orientation is 0. However, the default could be
    // different for 24+. See
    // https://developer.android.com/reference/android/hardware/Camera.html#setDisplayOrientation(int)
    camera.setDisplayOrientation(0);

    final Camera.Parameters parameters = camera.getParameters();
    setPreviewSize(parameters, (Double) settings.get("width"), (Double) settings.get("height"));
    camera.setParameters(parameters);

    camera.startPreview();
    repeatingCaptureDelegate.onStart(result);
  }

  @Override
  public void stopRepeatingCaptureRequest() {
    if (camera == null) return;

    camera.stopPreview();
    closeRepeatingCaptureDelegate();
  }

  @Override
  public void close() {
    if (camera == null) return;

    stopRepeatingCaptureRequest();

    camera.release();
    camera = null;
  }

  // Settings Methods
  private void setPreviewSize(final Camera.Parameters parameters, Double width, Double height) {
    if (width != null && height != null) {
      parameters.setPreviewSize(width.intValue(), height.intValue());
    }
  }

  // Helper Methods
  private void closeRepeatingCaptureDelegate() {
    if (repeatingCaptureDelegate == null) return;

    repeatingCaptureDelegate.close();
    repeatingCaptureDelegate = null;
  }
}
