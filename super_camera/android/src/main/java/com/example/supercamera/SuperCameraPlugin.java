package com.example.supercamera;

import java.util.ArrayList;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** SuperCameraPlugin */
public class SuperCameraPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "bmparr2450.plugins/super_camera");
    channel.setMethodCallHandler(new SuperCameraPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("Camera#availableCameras")) {
      result.success(new ArrayList<Map<String, Object>>());
    } else {
      result.notImplemented();
    }
  }
}
