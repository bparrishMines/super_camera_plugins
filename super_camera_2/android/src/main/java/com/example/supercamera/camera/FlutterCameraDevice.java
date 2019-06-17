package com.example.supercamera.camera;

import android.hardware.camera2.CameraDevice;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterCameraDevice implements MethodChannel.MethodCallHandler {
  private final CameraDevice device;

  FlutterCameraDevice(CameraDevice device) {
    this.device = device;
  }

  @Override
  public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

  }
}
