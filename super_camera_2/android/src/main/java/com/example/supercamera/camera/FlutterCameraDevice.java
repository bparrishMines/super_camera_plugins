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

  private void createCaptureSession(final MethodCall call, final MethodChannel.Result result) {
    final Integer sessionHandle = call.argument("sessionHandle");
    final List<Map<String, Object>> outputData = call.argument("outputs");
    final List<Surface> outputs = Parsers.parseSurfaces(outputData);

    final String stateClassName = "CameraCaptureSessionState";
    try {
      device.createCaptureSession(outputs, new CameraCaptureSession.StateCallback() {
        @Override
        public void onConfigured(@NonNull CameraCaptureSession session) {
          addHandler(session);

          final Map<String, Object> stateData = new HashMap<>();
          stateData.put("handle", sessionHandle);
          stateData.put(stateClassName, stateClassName + ".configured");

          SuperCameraPlugin.sendCallback(stateData);
        }

        @Override
        public void onConfigureFailed(@NonNull CameraCaptureSession session) {
          addHandler(session);

          final Map<String, Object> stateData = new HashMap<>();
          stateData.put("handle", sessionHandle);
          stateData.put(stateClassName, stateClassName + ".configureFailed");

          SuperCameraPlugin.sendCallback(stateData);
        }

        @Override
        public void onClosed(@NonNull CameraCaptureSession session) {
          addHandler(session);

          final Map<String, Object> stateData = new HashMap<>();
          stateData.put("handle", sessionHandle);
          stateData.put(stateClassName, stateClassName + ".closed");

          SuperCameraPlugin.sendCallback(stateData);
        }

        private void addHandler(@NonNull CameraCaptureSession session) {
          if (SuperCameraPlugin.getHandler(sessionHandle) == null) {
            SuperCameraPlugin.addHandler(
                sessionHandle, new FlutterCameraCaptureSession(session, sessionHandle));
          }
        }
      }, null);

      result.success(null);
    } catch (CameraAccessException e) {
      result.error(e.getClass().getSimpleName(), e.getLocalizedMessage(), null);
    }
  }

  private void close(MethodChannel.Result result) {
    device.close();
    SuperCameraPlugin.removeHandler(handle);
    result.success(null);
  }
}
