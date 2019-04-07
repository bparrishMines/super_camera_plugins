package com.example.supercamera.camera2;

import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.os.Build;
import android.util.Size;
import android.view.Surface;
import com.example.supercamera.base.BaseCameraController;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
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
      final String exceptionName = exception.getClass().getSimpleName();
      final String message = String.format("%s: %s", exceptionName, exception.getMessage());

      result.error(ErrorCodes.UNKNOWN, message, null);
      return;
    }

    result.success(allCameraData);
  }

  private CameraManager cameraManager;
  private CameraDevice cameraDevice;
  private CameraCaptureSession session;
  private final List<Surface> videoSurfaces = new ArrayList<>();
  private CaptureRequest videoCaptureRequest;

  public CameraController2(
      String cameraId, TextureRegistry textureRegistry, CameraManager manager) {
    super(cameraId, textureRegistry);
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

  // TODO(maurice): remove camera permission from manifest
  @Override
  public void open(final MethodChannel.Result result) {
    if (cameraIsOpen()) {
      result.error(ErrorCodes.CAMERA_CONTROLLER_ALREADY_OPEN, "CameraController is already open.", null);
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
              // Do nothing for now
            }

            @Override
            public void onError(@NonNull CameraDevice camera, int error) {
              // TODO: Add ErrorCallback for camera1 and iOS
            }
          }, null
      );
    } catch(CameraAccessException exception) {
      final String exceptionName = exception.getClass().getSimpleName();
      final String message = String.format("%s: %s", exceptionName, exception.getMessage());

      result.error(ErrorCodes.UNKNOWN, message, null);
    }
  }

  @Override
  public void startRunning(final MethodChannel.Result result) {
    try {
      cameraDevice.createCaptureSession(
          videoSurfaces,
          new CameraCaptureSession.StateCallback() {

            @Override
            public void onConfigured(@NonNull CameraCaptureSession captureSession) {
              session = captureSession;

              try {
                if (videoCaptureRequest == null) {
                  final CaptureRequest.Builder builder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
                  session.setRepeatingRequest(builder.build(), null, null);
                  return;
                }

                session.setRepeatingRequest(videoCaptureRequest, null, null);
              } catch (CameraAccessException
                  | IllegalStateException
                  | IllegalArgumentException exception) {
                final String exceptionName = exception.getClass().getSimpleName();
                final String message = String.format("%s: %s", exceptionName, exception.getMessage());

                result.error(ErrorCodes.UNKNOWN, message, null);
              }
            }

            @Override
            public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession) {
              final String message = "ConfigurationFailed";
              result.error(ErrorCodes.UNKNOWN, message, null);
            }
          },
          null);
    } catch (CameraAccessException exception) {
      final String exceptionName = exception.getClass().getSimpleName();
      final String message = String.format("%s: %s", exceptionName, exception.getMessage());

      result.error(ErrorCodes.UNKNOWN, message, null);
    }
  }

  @Override
  public void takePhoto(Map<String, Object> settings, MethodChannel.Result result) {

  }

  @Override
  public void setVideoSettings(Map<String, Object> settings, MethodChannel.Result result) {
    try {
      final CaptureRequest.Builder builder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
      videoCaptureRequest = builder.build();

      result.success(15);
    } catch (CameraAccessException exception) {
      final String exceptionName = exception.getClass().getSimpleName();
      final String message = String.format("%s: %s", exceptionName, exception.getMessage());

      result.error(ErrorCodes.UNKNOWN, message, null);
    }
  }

  @Override
  public void stopRunning() {

  }

  @Override
  public void close() {
    if (!cameraIsOpen()) return;

    stopRunning();

    cameraDevice.close();
    cameraDevice = null;
  }

  // Helper Methods
  private boolean cameraIsOpen() {
    return cameraDevice != null;
  }
}
