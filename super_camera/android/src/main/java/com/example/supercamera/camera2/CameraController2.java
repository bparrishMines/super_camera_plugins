package com.example.supercamera.camera2;

import android.graphics.ImageFormat;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.ImageReader;
import android.os.Build;
import android.util.Size;
import android.view.Surface;
import com.example.supercamera.base.BaseCameraController;
import com.example.supercamera.camera2.photo_delegates.PhotoDelegate;
import com.example.supercamera.camera2.video_delegates.VideoDelegate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class CameraController2 extends BaseCameraController {
  public static void returnAvailableCameras(CameraManager manager, MethodChannel.Result result) {
    List<Map<String, Object>> allCameraData = new ArrayList<>();

    try {
      for (String cameraId : manager.getCameraIdList()) {
        final Map<String, Object> cameraData = new HashMap<>();
        cameraData.put("cameraId", cameraId);

        final CameraCharacteristics characteristics = manager.getCameraCharacteristics(cameraId);

        Integer lensFacing = characteristics.get(CameraCharacteristics.LENS_FACING);
        switch(lensFacing) {
          case CameraMetadata.LENS_FACING_FRONT:
            cameraData.put("lensDirection", "front");
            break;
          case CameraMetadata.LENS_FACING_BACK:
            cameraData.put("lensDirection", "back");
            break;
          case CameraMetadata.LENS_FACING_EXTERNAL:
            cameraData.put("lensDirection", "external");
            break;
        }

        final Integer sensorOrientation = characteristics.get(
            CameraCharacteristics.SENSOR_ORIENTATION);
        cameraData.put("orientation", sensorOrientation);

        final StreamConfigurationMap configs = characteristics.get(
            CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);

        final List<Map<String, Object>> allVideoFormatData = new ArrayList<>();
        for (Integer format : configs.getOutputFormats()) {
          for (Size size : configs.getOutputSizes(format)) {
            final Map<String, Object> videoFormatData = new HashMap<>();

            videoFormatData.put("width", size.getWidth());
            videoFormatData.put("height", size.getHeight());

            final Map<String, Object> pixelFormat = new HashMap<>();
            pixelFormat.put("rawAndroid", format);
            videoFormatData.put("pixelFormat", pixelFormat);

            allVideoFormatData.add(videoFormatData);
          }
        }

        cameraData.put("videoFormats", allVideoFormatData);

        allCameraData.add(cameraData);
      }
    } catch (CameraAccessException exception) {
      handleCameraAccessException(exception, result);
      return;
    }

    result.success(allCameraData);
  }

  private final CameraManager cameraManager;
  private CameraDevice cameraDevice;
  private CameraCaptureSession session;

  private CaptureRequest videoCaptureRequest;
  private VideoDelegate videoDelegate;
  private Surface videoSurface;

  private CaptureRequest photoCaptureRequest;
  private PhotoDelegate photoDelegate;
  private ImageReader photoImageReader;

  public CameraController2(
      String cameraId,
      TextureRegistry textureRegistry,
      BinaryMessenger messenger,
      CameraManager manager) {
    super(cameraId, textureRegistry, messenger);
    cameraManager = manager;
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

  // TODO(maurice): remove camera permission from manifest
  @Override
  public void open(final MethodChannel.Result result) {
    if (cameraIsOpen()) {
      result.error(
          ErrorCodes.CAMERA_CONTROLLER_ALREADY_OPEN, "CameraController is already open.", null);
      return;
    }

    try {
      cameraManager.openCamera(
          cameraId,
          new CameraDevice.StateCallback() {
            @Override
            public void onOpened(@NonNull CameraDevice camera) {
              cameraDevice = camera;
              result.success(null);
            }

            @Override
            public void onDisconnected(@NonNull CameraDevice camera) {
            }

            @Override
            public void onError(@NonNull CameraDevice camera, int error) {
            }
          }, null
      );
    } catch(CameraAccessException exception) {
      handleCameraAccessException(exception, result);
    }
  }

  @Override
  public void startRunning(final MethodChannel.Result result) {
    final List<Surface> surfaces = new ArrayList<>();

    if (videoSettingsSet()) {
      surfaces.add(videoSurface);
    }
    if (photoSettingsSet()) {
      surfaces.add(photoImageReader.getSurface());
    }

    try {
      cameraDevice.createCaptureSession(
          surfaces,
          new CameraCaptureSession.StateCallback() {

            @Override
            public void onConfigured(@NonNull CameraCaptureSession captureSession) {
              session = captureSession;

              try {
                session.setRepeatingRequest(videoCaptureRequest, null, null);
                result.success(null);
              } catch (CameraAccessException exception) {
                handleCameraAccessException(exception, result);
              } catch (IllegalStateException | IllegalArgumentException exception) {
                final String exceptionName = exception.getClass().getSimpleName();
                final String message = String.format("%s: %s", exceptionName, exception.getMessage());

                result.error(ErrorCodes.UNKNOWN, message, null);
              }
            }

            @Override
            public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession) {
              result.error("ConfigurationFailed", "Failed to configure camera session.", null);
            }
          },
          null);
    } catch (CameraAccessException exception) {
      handleCameraAccessException(exception, result);
    }
  }

  @Override
  public void setPhotoSettings(Map<String, Object> settings, MethodChannel.Result result) {
    closePhotoDelegate();

    if (!cameraIsOpen()) {
      result.error(ErrorCodes.CAMERA_CONTROLLER_NOT_OPEN, "CameraController is not open.", null);
      return;
    }

    final String delegateName = (String) settings.get("androidClassNameCamera2");
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

    final CaptureRequest.Builder captureBuilder;
    try {
      captureBuilder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
    } catch (CameraAccessException exception) {
      handleCameraAccessException(exception, result);
      return;
    }

    final ImageReader imageReader = ImageReader.newInstance(1080, 720, ImageFormat.JPEG, 1);
    imageReader.setOnImageAvailableListener(photoDelegate.getOnImageAvailableListener(), null);

    captureBuilder.addTarget(imageReader.getSurface());
    photoCaptureRequest = captureBuilder.build();

    photoImageReader = imageReader;

    photoDelegate.onFinishSetup(result);
  }

  @Override
  public void takePhoto(final MethodChannel.Result result) {
    if (!cameraIsOpen()) {
      result.error(ErrorCodes.CAMERA_CONTROLLER_NOT_OPEN, "CameraController is not open.", null);
      return;
    }

    if (!photoSettingsSet()) {
      result.success(null);
      return;
    }

    try {
      session.capture(photoCaptureRequest, null, null);
    } catch (CameraAccessException exception) {
      handleCameraAccessException(exception, result);
    }
  }

  @Override
  public void setVideoSettings(Map<String, Object> settings, MethodChannel.Result result) {
    closeVideoDelegate();

    if (!cameraIsOpen()) {
      result.error(ErrorCodes.CAMERA_CONTROLLER_NOT_OPEN, "CameraController is not open.", null);
      return;
    }

    final String delegateName = (String) settings.get("androidClassNameCamera2");
    if (delegateName == null) {
      result.error(ErrorCodes.INVALID_DELEGATE_NAME, "Camera delegate name is null.", null);
      return;
    }

    try {
      videoDelegate = (VideoDelegate) Class.forName(delegateName).newInstance();
    } catch (Exception exception) {
      result.error(ErrorCodes.INVALID_DELEGATE_NAME, exception.getMessage(), null);
      return;
    }

    @SuppressWarnings("unchecked")
    Map<String, Object> delegateSettings = (Map<String, Object>) settings.get("delegateSettings");
    videoDelegate.initialize(delegateSettings, textureRegistry);

    final SurfaceTexture surfaceTexture = videoDelegate.getPreviewSurfaceTexture();

    try {
      @SuppressWarnings("unchecked")
      final Map<String, Object> videoFormat = (Map<String, Object>) settings.get("videoFormat");
      setVideoFormat(surfaceTexture, videoFormat);
    } catch (Exception exception) {
      closeVideoDelegate();

      final String exceptionName = exception.getClass().getSimpleName();
      final String message = String.format("%s: %s", exceptionName, exception.getMessage());
      result.error(ErrorCodes.INVALID_SETTING, message, null);

      return;
    }

    videoSurface = new Surface(surfaceTexture);

    final CaptureRequest.Builder builder;
    try {
      builder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
    } catch (CameraAccessException exception) {
      closeVideoDelegate();
      handleCameraAccessException(exception, result);
      return;
    }

    builder.addTarget(videoSurface);
    videoCaptureRequest = builder.build();

    videoDelegate.onFinishSetup(result);
  }

  @Override
  public void stopRunning() {
    if (!cameraIsOpen()) return;

    if (session != null) {
      try {
        session.stopRepeating();
        session.abortCaptures();
      } catch (CameraAccessException exception) {
        // Do nothing
      }
    }
  }

  @Override
  public void close() {
    if (!cameraIsOpen()) return;

    stopRunning();
    closeVideoDelegate();
    closePhotoDelegate();

    session.close();
    session = null;

    cameraDevice.close();
    cameraDevice = null;
  }

  // Settings Methods
  private void setVideoFormat(SurfaceTexture texture, Map<String, Object> videoFormatData) {
    if (videoFormatData == null) return;

    final Double width = (Double) videoFormatData.get("width");
    final Double height = (Double) videoFormatData.get("height");

    texture.setDefaultBufferSize(width.intValue(), height.intValue());
  }

  // Helper Methods
  private void closeVideoDelegate() {
    if (videoDelegate == null) return;

    videoDelegate.close();
    videoDelegate = null;
  }

  private void closePhotoDelegate() {
    if (photoDelegate == null) return;

    photoDelegate.close();
    photoImageReader.close();
    photoDelegate = null;
  }

  private static void handleCameraAccessException(
      Exception exception, MethodChannel.Result result) {
    result.error("CameraAccess", exception.getMessage(), null);
  }

  private boolean cameraIsOpen() {
    return cameraDevice != null;
  }

  private boolean videoSettingsSet() {
    return videoDelegate != null;
  }

  private boolean photoSettingsSet() {
    return photoDelegate != null;
  }
}
