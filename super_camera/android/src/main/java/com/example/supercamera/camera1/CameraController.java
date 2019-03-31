package com.example.supercamera.camera1;

import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import com.example.supercamera.base.BaseCameraController;
import com.example.supercamera.camera1.video_delegates.VideoDelegate;
import com.example.supercamera.camera1.photo_delegates.PhotoDelegate;
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
  private VideoDelegate videoDelegate;

  public CameraController(final String cameraId, final TextureRegistry textureRegistry) {
    super(cameraId, textureRegistry);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch(call.method) {
      case "CameraController#open":
        open(result);
        break;
      case "CameraController#startRunning":
        startRunning(result);
        break;
      case "CameraController#takePhoto":
        @SuppressWarnings("unchecked")
        Map<String, Object> photoSettings = (Map<String, Object>) call.arguments;
        takePhoto(photoSettings, result);
        break;
      case "CameraController#setVideoSettings":
        @SuppressWarnings("unchecked")
        Map<String, Object> videoSettings = (Map<String, Object>) call.arguments;
        setVideoSettings(videoSettings, result);
        break;
      case "CameraController#stopRunning":
        stopRunning();
        result.success(null);
        break;
      case "CameraController#close":
        close();
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void open(MethodChannel.Result result) {
    if (cameraIsOpen()) {
      result.error(ErrorCodes.CAMERA_CONTROLLER_ALREADY_OPEN, "CameraController is already open.", null);
      return;
    }

    camera = Camera.open(Integer.parseInt(cameraId));
    result.success(null);
  }

  @Override
  public void startRunning(MethodChannel.Result result) {
    if (!cameraIsOpen()) {
      result.error(ErrorCodes.CAMERA_CONTROLLER_NOT_OPEN, "CameraController is not open.", null);
      return;
    }

    camera.startPreview();
    result.success(null);
  }

  @Override
  public void takePhoto(Map<String, Object> settings, MethodChannel.Result result) {
    if (!cameraIsOpen()) {
      result.error(ErrorCodes.CAMERA_CONTROLLER_NOT_OPEN, "CameraController is not open.", null);
      return;
    }

    final String androidDelegateName = (String) settings.get("androidDelegateName");
    if (androidDelegateName == null) {
      result.error(ErrorCodes.INVALID_DELEGATE_NAME, "Camera delegate name is null.", null);
      return;
    }

    final PhotoDelegate delegate;
    try {
      delegate = (PhotoDelegate) Class.forName(androidDelegateName).newInstance();
    } catch (Exception exception) {
      result.error(ErrorCodes.INVALID_DELEGATE_NAME, exception.getMessage(), null);
      return;
    }

    @SuppressWarnings("unchecked")
    Map<String, Object> delegateSettings = (Map<String, Object>) settings.get("delegateSettings");
    delegate.initialize(delegateSettings, textureRegistry, result);

    camera.takePicture(
        delegate.getShutterCallback(),
        delegate.getRawCallback(),
        delegate.getPostViewCallback(),
        new Camera.PictureCallback() {
          @Override
          public void onPictureTaken(byte[] data, Camera camera) {
            final Camera.PictureCallback callback = delegate.getJpegCallback();

            if (callback != null) {
              callback.onPictureTaken(data, camera);
            }
            camera.startPreview();
          }
        });
  }

  @Override
  public void setVideoSettings(Map<String, Object> settings, MethodChannel.Result result) {
    if (!cameraIsOpen()) {
      result.error(ErrorCodes.CAMERA_CONTROLLER_NOT_OPEN, "CameraController is not open.", null);
      return;
    }

    final String androidDelegateName = (String) settings.get("androidDelegateName");
    if (androidDelegateName == null) {
      result.error(ErrorCodes.INVALID_DELEGATE_NAME, "Camera delegate name is null.", null);
      return;
    }

    try {
      videoDelegate = (VideoDelegate) Class.forName(androidDelegateName).newInstance();
    } catch (Exception exception) {
      result.error(ErrorCodes.INVALID_DELEGATE_NAME, exception.getMessage(), null);
      return;
    }

    @SuppressWarnings("unchecked")
    Map<String, Object> delegateSettings = (Map<String, Object>) settings.get("delegateSettings");
    videoDelegate.initialize(delegateSettings, textureRegistry);

    final SurfaceTexture surfaceTexture = videoDelegate.getSurfaceTexture();
    try {
      camera.setPreviewTexture(surfaceTexture);
    } catch (IOException exception) {
      closeVideoDelegate();
      result.error(exception.getClass().getSimpleName(), exception.getMessage(), null);
      return;
    }

    final Camera.PreviewCallback callback = videoDelegate.getPreviewCallback();
    camera.setPreviewCallback(callback);

    // Before API level 24, the default value for orientation is 0. However, the default could be
    // different for 24+. See
    // https://developer.android.com/reference/android/hardware/Camera.html#setDisplayOrientation(int)
    camera.setDisplayOrientation(0);

    final Camera.Parameters parameters = camera.getParameters();
    try {
      setResolution(parameters, (Double) settings.get("width"), (Double) settings.get("height"));
      camera.setParameters(parameters);
      setVideoOrientation((String) settings.get("orientation"));
    } catch (Exception exception) {
      closeVideoDelegate();

      final String exceptionName = exception.getClass().getSimpleName();
      final String message = String.format("%s: %s", exceptionName, exception.getMessage());
      result.error(ErrorCodes.INVALID_SETTING, message, null);

      return;
    }

    videoDelegate.onFinishSetup(result);
  }

  @Override
  public void stopRunning() {
    if (!cameraIsOpen()) return;

    camera.stopPreview();
  }

  @Override
  public void close() {
    if (!cameraIsOpen()) return;

    stopRunning();
    closeVideoDelegate();

    camera.release();
    camera = null;
  }

  // Settings Methods
  private void setResolution(final Camera.Parameters parameters, Double width, Double height) {
    if (width != null && height != null) {
      parameters.setPreviewSize(width.intValue(), height.intValue());
    }
  }

  // TODO(Maurice): Design way for this to work with tablets.
  private void setVideoOrientation(String orientation) throws IllegalAccessException {
    final Camera.CameraInfo info = new Camera.CameraInfo();
    Camera.getCameraInfo(Integer.parseInt(cameraId), info);

    final int cameraOrientation;
    switch(info.facing) {
      case Camera.CameraInfo.CAMERA_FACING_FRONT:
        // We subtract orientation from 360 to compensate for the automatic mirroring of the front
        // camera. See
        // https://developer.android.com/reference/android/hardware/Camera.html#setDisplayOrientation(int)
        cameraOrientation = 360 - info.orientation % 360;
        break;
      case Camera.CameraInfo.CAMERA_FACING_BACK:
        cameraOrientation = info.orientation;
        break;
      default:
        throw new IllegalAccessException("Using non front or back camera with Camera API");
    }

    switch(orientation) {
      case "VideoOrientation.portraitUp":
        camera.setDisplayOrientation(cameraOrientation);
        break;
      case "VideoOrientation.landscapeRight":
        camera.setDisplayOrientation((cameraOrientation + 90) % 360);
        break;
      case "VideoOrientation.portraitDown":
        camera.setDisplayOrientation((cameraOrientation + 180) % 360);
        break;
      case "VideoOrientation.landscapeLeft":
        camera.setDisplayOrientation((cameraOrientation + 270) % 360);
        break;
      default:
        final String message = String.format("Invalid video orientation of %s", orientation);
        throw new IllegalArgumentException(message);
    }
  }

  // Helper Methods
  private void closeVideoDelegate() {
    if (videoDelegate == null) return;

    videoDelegate.close();
    videoDelegate = null;

    try {
      camera.setPreviewTexture(null);
    } catch (IOException exception) {
      // Do nothing. Exception won't throw when setting to null;
    }
    camera.setPreviewCallback(null);
  }

  private boolean cameraIsOpen() {
    return camera != null;
  }
}
