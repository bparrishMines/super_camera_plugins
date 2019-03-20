package com.example.supercamera;

import com.example.supercamera.base.BaseCameraController;
import com.example.supercamera.camera1.CameraController;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** SuperCameraPlugin */
public class SuperCameraPlugin implements MethodCallHandler {
  private final Registrar registrar;
  private final Map<String, BaseCameraController> controllers = new HashMap<>();

  private SuperCameraPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "bmparr2450.plugins/super_camera");
    channel.setMethodCallHandler(new SuperCameraPlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch(call.method) {
      case "Camera#availableCameras":
        result.success(CameraController.availableCameras());
        break;
      case "CameraController#open":
        openController(call, result);
        break;
      case "CameraController#close":
        closeController(call, result);
        break;
      case "CameraController#putRepeatingCaptureRequest":
        putRepeatingCaptureRequest(call, result);
        break;
      case "CameraController#stopRepeatingCaptureRequest":
        stopRepeatingCaptureRequest(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void openController(MethodCall call, Result result) {
    final String cameraId = call.argument("cameraId");

    if (controllers.containsKey(cameraId)) {
      result.error(
          "CameraAlreadyOpenException","CameraController has already been opened.", null);
      return;
    }

    final BaseCameraController controller = new CameraController(cameraId, registrar.textures());
    controllers.put(cameraId, controller);

    controller.open(result);
  }

  private void closeController(MethodCall call, Result result) {
    final String cameraId = call.argument("cameraId");

    final BaseCameraController controller = controllers.get(cameraId);

    if (controller == null) {
      result.success(null);
      return;
    }

    controllers.remove(cameraId);
    controller.close(result);
  }

  private void putRepeatingCaptureRequest(MethodCall call, Result result) {
    final String cameraId = call.argument("cameraId");

    final BaseCameraController controller = controllers.get(cameraId);

    if (controller == null) {
      result.error("CameraNotOpenException", "Camera is not open.", null);
      return;
    }

    Map<String, Object> settings = call.argument("settings");
    controller.putRepeatingCaptureRequest(settings, result);
  }

  private void stopRepeatingCaptureRequest(MethodCall call, Result result) {
    final String cameraId = call.argument("cameraId");

    final BaseCameraController controller = controllers.get(cameraId);

    if (controller == null) {
      result.success(null);
      return;
    }

    controller.stopRepeatingCaptureRequest(result);
  }
}
