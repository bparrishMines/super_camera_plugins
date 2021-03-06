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
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class CameraController extends BaseCameraController {
  // We can store camera data because the Camera API can't access external cameras.
  private static List<Map<String, Object>> availableCameraData;

  public static List<Map<String, Object>> availableCameras() {
    if (availableCameraData != null) return availableCameraData;

    List<Map<String, Object>> allCameraData = new ArrayList<>();

    for (int i = 0, count = Camera.getNumberOfCameras(); i < count; i++) {
      final Map<String, Object> cameraData = new HashMap<>();
      cameraData.put("cameraId", String.valueOf(i));

      final Camera.CameraInfo info = new Camera.CameraInfo();
      Camera.getCameraInfo(i, info);

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

      final List<Map<String, Object>> allVideoFormatData = new ArrayList<>();
      for (Integer format : parameters.getSupportedPreviewFormats()) {
        for (Camera.Size size : parameters.getSupportedPreviewSizes()) {
          final Map<String, Object> videoFormatData = new HashMap<>();

          videoFormatData.put("width", size.width);
          videoFormatData.put("height", size.height);

          final Map<String, Object> pixelFormat = new HashMap<>();
          pixelFormat.put("rawAndroid", format);
          videoFormatData.put("pixelFormat", pixelFormat);

          allVideoFormatData.add(videoFormatData);
        }
      }

      cameraData.put("videoFormats", allVideoFormatData);

      camera.release();

      allCameraData.add(cameraData);
    }

    availableCameraData = allCameraData;
    return allCameraData;
  }

  private Camera camera;
  private VideoDelegate videoDelegate;
  private PhotoDelegate photoDelegate;

  public CameraController(
      final String cameraId,
      final TextureRegistry textureRegistry,
      final BinaryMessenger messenger) {
    super(cameraId, textureRegistry, messenger);
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
      case "CameraController#setPhotoSettings":
        @SuppressWarnings("unchecked")
        Map<String, Object> photoSettings = (Map<String, Object>) call.arguments;
        setPhotoSettings(photoSettings, result);
        break;
      case "CameraController#setVideoSettings":
        @SuppressWarnings("unchecked")
        Map<String, Object> videoSettings = (Map<String, Object>) call.arguments;
        setVideoSettings(videoSettings, result);
        break;
      case "CameraController#takePhoto":
        takePhoto(result);
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
  public void setPhotoSettings(Map<String, Object> settings, MethodChannel.Result result) {
    closePhotoDelegate();

    if (!cameraIsOpen()) {
      result.error(ErrorCodes.CAMERA_CONTROLLER_NOT_OPEN, "CameraController is not open.", null);
      return;
    }

    final String delegateName = (String) settings.get("androidClassName");
    if (delegateName == null) {
      result.error(ErrorCodes.INVALID_DELEGATE_NAME, "Camera delegate name is null.", null);
      return;
    }

    try {
      photoDelegate = (PhotoDelegate) Class.forName(delegateName).newInstance();
    } catch (Exception exception) {
      result.error(ErrorCodes.INVALID_DELEGATE_NAME, exception.getMessage(), null);
      return;
    }

    @SuppressWarnings("unchecked")
    Map<String, Object> delegateSettings = (Map<String, Object>) settings.get("delegateSettings");
    photoDelegate.initialize(delegateSettings, textureRegistry, binaryMessenger);

    photoDelegate.onFinishSetup(result);
  }

  @Override
  public void takePhoto(final MethodChannel.Result result) {
    if (!cameraIsOpen()) {
      result.error(ErrorCodes.CAMERA_CONTROLLER_NOT_OPEN, "CameraController is not open.", null);
      return;
    }

    // Still take a photo even if settings are not set.
    if (!photoSettingsSet()) {
      camera.takePicture(null, null, null);
      result.success(null);
      return;
    }

    camera.takePicture(
        photoDelegate.getShutterCallback(),
        photoDelegate.getRawCallback(),
        photoDelegate.getPostViewCallback(),
        new Camera.PictureCallback() {
          @Override
          public void onPictureTaken(byte[] data, Camera camera) {
            final Camera.PictureCallback callback = photoDelegate.getJpegCallback();

            if (callback != null) {
              callback.onPictureTaken(data, camera);
            }

            camera.startPreview();
            result.success(null);
          }
        });
  }

  @Override
  public void setVideoSettings(Map<String, Object> settings, MethodChannel.Result result) {
    closeVideoDelegate();

    if (!cameraIsOpen()) {
      result.error(ErrorCodes.CAMERA_CONTROLLER_NOT_OPEN, "CameraController is not open.", null);
      return;
    }

    final String androidDelegateName = (String) settings.get("androidClassName");
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

    final SurfaceTexture surfaceTexture = videoDelegate.getPreviewTexture();
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
      @SuppressWarnings("unchecked")
      final Map<String, Object> videoFormat = (Map<String, Object>) settings.get("videoFormat");
      setVideoFormat(parameters, videoFormat);
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
    closePhotoDelegate();

    camera.release();
    camera = null;
  }

  // Settings Methods
  private void setVideoFormat(
      final Camera.Parameters parameters, Map<String, Object> videoFormatData) {
    if (videoFormatData == null) return;

    final Double width = (Double) videoFormatData.get("width");
    final Double height = (Double) videoFormatData.get("height");
    final Integer format = (Integer) videoFormatData.get("pixelFormat");

    parameters.setPreviewSize(width.intValue(), height.intValue());
    parameters.setPreviewFormat(format);
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

    try {
      camera.setPreviewTexture(null);
    } catch (IOException exception) {
      // Do nothing. Exception won't throw when setting to null.
    }
    camera.setPreviewCallback(null);

    videoDelegate.close();
    videoDelegate = null;
  }

  private void closePhotoDelegate() {
    if (photoDelegate == null) return;

    photoDelegate.close();
    photoDelegate = null;
  }

  private boolean cameraIsOpen() {
    return camera != null;
  }

  private boolean photoSettingsSet() {
    return photoDelegate != null;
  }
}
