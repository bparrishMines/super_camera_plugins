package com.example.supercamera.camera;

import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CaptureRequest;
import android.os.Build;

import androidx.annotation.RequiresApi;

import com.example.supercamera.SuperCameraPlugin;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class FlutterCameraDevice implements MethodChannel.MethodCallHandler {
  private final CameraDevice device;
  private final Integer handle;

  FlutterCameraDevice(CameraDevice device, Integer handle) {
    this.device = device;
    this.handle = handle;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch(call.method) {
      case "CameraDevice#createCaptureRequest":
        createCaptureRequest(call, result);
        break;
      case "CameraDevice#close":
        close(result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void createCaptureRequest(MethodCall call, MethodChannel.Result result) {
    final String template = call.argument("template");

    final int requestTemplate;
    if (template.equals("Template.preview")) {
      requestTemplate = CameraDevice.TEMPLATE_PREVIEW;
    } else {
      throw new IllegalStateException();
    }

    final CaptureRequest.Builder requestBuilder;
    try {
      requestBuilder = device.createCaptureRequest(requestTemplate);
    } catch (CameraAccessException e) {
      result.error(e.getClass().getSimpleName(), e.getLocalizedMessage(), null);
      return;
    }

    final Byte jpegQuality = requestBuilder.get(CaptureRequest.JPEG_QUALITY);

    final Map<String, Object> data = new HashMap<>();
    data.put("jpegQuality", jpegQuality.intValue());

    result.success(data);
  }

  private void close(MethodChannel.Result result) {
    device.close();
    SuperCameraPlugin.removeHandler(handle);
  }
}
