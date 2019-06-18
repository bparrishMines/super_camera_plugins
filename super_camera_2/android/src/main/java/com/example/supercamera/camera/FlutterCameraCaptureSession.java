package com.example.supercamera.camera;

import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.os.Build;
import androidx.annotation.RequiresApi;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class FlutterCameraCaptureSession implements MethodChannel.MethodCallHandler {
  private final CameraCaptureSession session;
  private final TextureRegistry.SurfaceTextureEntry textureEntry;
  private final Integer handle;

  FlutterCameraCaptureSession(
      CameraCaptureSession session,
      TextureRegistry.SurfaceTextureEntry textureEntry,
      Integer handle) {
    this.session = session;
    this.textureEntry = textureEntry;
    this.handle = handle;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch(call.method) {
      case "CameraCaptureSession#setRepeatingRequest":
        setRepeatingRequest(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void setRepeatingRequest(MethodCall call, MethodChannel.Result result) {
    try {
      session.setRepeatingRequest(null, null, null);
    } catch (CameraAccessException e) {
      e.printStackTrace();
    }
  }
}
