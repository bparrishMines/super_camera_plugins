package com.example.supercamera.camera;

import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CaptureRequest;
import android.os.Build;
import android.view.Surface;
import androidx.annotation.RequiresApi;
import com.example.supercamera.SuperCameraPlugin;
import com.example.supercamera.common.PlatformTexture;
import java.util.ArrayList;
import java.util.List;
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
    final Map<String, Object> requestData = call.argument("CaptureRequest");

    try {
      final CaptureRequest request = parseCaptureRequest(cameraDeviceHandle, requestData);
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

  private CaptureRequest parseCaptureRequest(
      Integer cameraDeviceHandle, Map<String, Object> requestData) throws CameraAccessException {
    final FlutterCameraDevice device =
        (FlutterCameraDevice) SuperCameraPlugin.getHandler(cameraDeviceHandle);

    final int requestTemplate;
    switch ((String) requestData.get("Template")) {
      case "Template.preview":
        requestTemplate = CameraDevice.TEMPLATE_PREVIEW;
        break;
      default:
        throw new IllegalArgumentException();
    }

    CaptureRequest.Builder builder = device.device.createCaptureRequest(requestTemplate);

    final List<Map<String, Object>> targetData = (List<Map<String, Object>>) requestData.get("targets");
    for(Surface target : parseOutputs(targetData)) {
      builder.addTarget(target);
    }

    return builder.build();
  }

  private List<Surface> parseOutputs(List<Map<String, Object>> allOutputData) {
    final List<Surface> outputs = new ArrayList<>();

    for (Map<String, Object> outputData : allOutputData) {
      final String surfaceClass = (String) outputData.get("surfaceClass");

      if (surfaceClass.equals("PreviewTexture")) {
        final Integer textureHandle = (Integer) outputData.get("textureHandle");
        final PlatformTexture texture = (PlatformTexture) SuperCameraPlugin.getHandler(textureHandle);

        outputs.add(new Surface(texture.textureEntry.surfaceTexture()));
      }
    }

    return outputs;
  }
}
