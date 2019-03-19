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
      default:
        result.notImplemented();
    }
  }

  private void openController(MethodCall call, Result result) {
    final String cameraId = call.argument("cameraId");

    if (controllers.containsKey(cameraId)) {
      result.error("Already opened CameraController for this camera.", null, null);
      return;
    }

    final BaseCameraController controller = new CameraController(cameraId);
    controllers.put(cameraId, controller);

    result.success(null);
  }

  private void closeController(MethodCall call, Result result) {
    final String cameraId = call.argument("cameraId");

    if (!controllers.containsKey(cameraId)) {
      result.error("No CameraController for this camera", null, null);
      return;
    }

    final BaseCameraController controller = controllers.get(cameraId);
    controller.close();

    controllers.remove(cameraId);

    result.success(null);
  }
}
