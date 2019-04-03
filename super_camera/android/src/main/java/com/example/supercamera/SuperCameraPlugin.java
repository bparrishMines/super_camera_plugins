package com.example.supercamera;

import android.content.Context;
import android.hardware.camera2.CameraManager;
import android.os.Build;
import android.util.Pair;
import com.example.supercamera.base.BaseCameraController;
import com.example.supercamera.camera1.CameraController;
import com.example.supercamera.camera2.CameraController2;

import java.util.ArrayList;
import java.util.List;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** SuperCameraPlugin */
public class SuperCameraPlugin implements MethodCallHandler {
  private static final String PLUGIN_CHANNEL_NAME = "bmparr2450.plugins/super_camera";

  private final Registrar registrar;
  private final List<Pair<MethodChannel, BaseCameraController>> controllers = new ArrayList<>();

  private SuperCameraPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), PLUGIN_CHANNEL_NAME);
    channel.setMethodCallHandler(new SuperCameraPlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch(call.method) {
      case "Camera#availableCameras":
        availableCameras(result);
        break;
      case "Camera#createCameraController":
        createCameraController(call);
        result.success(null);
        break;
      case "Camera#releaseAllResources":
        releaseAllResources();
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }

  private void availableCameras(Result result) {
    if (android.os.Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      result.success(CameraController.availableCameras());
      return;
    }


    final CameraManager manager =
        (CameraManager) registrar.activity().getSystemService(Context.CAMERA_SERVICE);
    CameraController2.returnAvailableCameras(manager, result);
  }

  private void createCameraController(MethodCall call) {
    final String channelName = call.argument("channelName");
    final MethodChannel channel = new MethodChannel(registrar.messenger(), channelName);

    final String cameraId = call.argument("cameraId");
    final BaseCameraController controller = new CameraController(cameraId, registrar.textures());
    channel.setMethodCallHandler(controller);

    controllers.add(new Pair<>(channel, controller));
  }

  private void releaseAllResources() {
    for (Pair<MethodChannel, BaseCameraController> controllerPair : controllers) {
      controllerPair.second.close();
      controllerPair.first.setMethodCallHandler(null);
    }

    controllers.clear();
  }
}
