package com.example.supercamera.camera;

import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.os.Build;
import androidx.annotation.RequiresApi;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class FlutterCameraManager implements MethodChannel.MethodCallHandler {
  private final CameraManager manager;

  public FlutterCameraManager(CameraManager manager) {
    this.manager = manager;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch(call.method) {
      case "CameraManager#getCameraCharacteristics":
        getCameraCharacteristics(call, result);
        break;
      case "CameraManager#getCameraIdList":
        getCameraIdList(result);
        break;
      case "CameraManager#openCamera":
        openCamera(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void getCameraCharacteristics(MethodCall call, MethodChannel.Result result) {
    final String cameraId = call.argument("cameraId");

    final CameraCharacteristics characteristics;
    try {
      characteristics = manager.getCameraCharacteristics(cameraId);
    } catch (CameraAccessException e) {
      result.error(e.getClass().getSimpleName(), e.getLocalizedMessage(), null);
      return;
    }

    final Map<String, Object> data = new HashMap<>();
    data.put("id", cameraId);
    data.put("sensorOrientation", characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION));

    switch(characteristics.get(CameraCharacteristics.LENS_FACING)) {
      case CameraCharacteristics.LENS_FACING_FRONT:
        data.put("LensFacing", "LensFacing.front");
        break;
      case CameraCharacteristics.LENS_FACING_BACK:
        data.put("LensFacing", "LensFacing.back");
        break;
      case CameraCharacteristics.LENS_FACING_EXTERNAL:
        data.put("LensFacing", "LensFacing.external");
        break;
    }

    result.success(data);
  }

  private void getCameraIdList(MethodChannel.Result result) {
    try {
      result.success(Arrays.asList(manager.getCameraIdList()));
    } catch (CameraAccessException e) {
      result.error(e.getClass().getSimpleName(), e.getLocalizedMessage(), null);
    }
  }

  private void openCamera(MethodCall call, MethodChannel.Result result) {

  }
}
