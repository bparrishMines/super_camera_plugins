package com.example.supercamera.camera;

import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraDevice;
import android.os.Build;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import com.example.supercamera.SuperCameraPlugin;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class FlutterCameraDevice implements MethodChannel.MethodCallHandler {
  final CameraDevice device;
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
      case "CameraDevice#createCaptureSession":
        createCaptureSession(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void createCaptureRequest(MethodCall call, MethodChannel.Result result) {
    /*
    final String template = call.argument("Template");

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
    */
  }

  private void createCaptureSession(final MethodCall call, final MethodChannel.Result result) {
    final Integer sessionHandle = call.argument("sessionHandle");
    final List<Map<String, Object>> outputData = call.argument("outputs");
    final List<Surface> outputs = Parsers.parseSurfaces(outputData);

    final String stateClassName = "CameraCaptureSessionState";
    try {
      device.createCaptureSession(outputs, new CameraCaptureSession.StateCallback() {
        @Override
        public void onConfigured(@NonNull CameraCaptureSession session) {
          SuperCameraPlugin.addHandler(
              sessionHandle, new FlutterCameraCaptureSession(session, sessionHandle));

          final Map<String, Object> stateData = new HashMap<>();
          stateData.put("handle", sessionHandle);
          stateData.put(stateClassName, stateClassName + ".configured");

          SuperCameraPlugin.sendCallback(stateData);
        }

        @Override
        public void onConfigureFailed(@NonNull CameraCaptureSession session) {

        }
      }, null);
    } catch (CameraAccessException e) {
      // Do Nothing
    }

    result.success(null);
  }

  private void close(MethodChannel.Result result) {
    device.close();
    SuperCameraPlugin.removeHandler(handle);
    result.success(null);
  }
}
