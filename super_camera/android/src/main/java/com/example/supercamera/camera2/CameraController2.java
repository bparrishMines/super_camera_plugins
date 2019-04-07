package com.example.supercamera.camera2;

import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.os.Build;
import android.util.Size;
import com.example.supercamera.base.BaseCameraController;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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

  public CameraController2(
      String cameraId, TextureRegistry textureRegistry, CameraManager manager) {
    super(cameraId, textureRegistry);
    cameraManager = manager;
  }

  @Override
  public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

  }

  @Override
  public void open(MethodChannel.Result result) {

  }

  @Override
  public void startRunning(MethodChannel.Result result) {

  }

  @Override
  public void takePhoto(Map<String, Object> settings, MethodChannel.Result result) {

  }

  @Override
  public void setVideoSettings(Map<String, Object> settings, MethodChannel.Result result) {

  }

  @Override
  public void stopRunning() {

  }

  @Override
  public void close() {

  }
}
