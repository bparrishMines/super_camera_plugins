package com.example.supercamera.camera;

import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CaptureRequest;
import android.os.Build;
import androidx.annotation.RequiresApi;
import com.example.supercamera.SuperCameraPlugin;
import java.util.Map;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class FlutterCameraCaptureSession implements MethodChannel.MethodCallHandler {
  private final CameraCaptureSession session;
  private final Integer handle;

  FlutterCameraCaptureSession(CameraCaptureSession session, Integer handle) {
    this.session = session;
    this.handle = handle;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch(call.method) {
      case "CameraCaptureSession#setRepeatingRequest":
        setRepeatingRequest(call, result);
        break;
      case "CameraCaptureSession#close":
        close(result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void setRepeatingRequest(MethodCall call, MethodChannel.Result result) {
    final Integer cameraDeviceHandle = call.argument("cameraDeviceHandle");
    final Map<String, Object> requestData = call.argument("captureRequest");

    try {
      final CaptureRequest request = Parser.parseCaptureRequest(cameraDeviceHandle, requestData);
      session.setRepeatingRequest(request, null, null);

      result.success(null);
    } catch (CameraAccessException e) {
      result.error(e.getClass().getSimpleName(), e.getLocalizedMessage(), null);
    }
  }

  private void close(MethodChannel.Result result) {
    session.close();
    SuperCameraPlugin.removeHandler(handle);
    result.success(null);
  }
}
