package com.example.supercamera.camera;

import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CaptureRequest;
import android.os.Build;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import com.example.supercamera.SuperCameraPlugin;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

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
      case "CameraDevice#createCaptureSession":
        createCaptureSession(call, result);
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

  private void createCaptureSession(final MethodCall call, final MethodChannel.Result result) {
    final List<Map<String, Object>> outputData = call.argument("outputs");
    final List<Surface> outputs = new ArrayList<>();

    TextureRegistry.SurfaceTextureEntry textureEntry = null;

    for (Map<String, Object> surfaceData : outputData) {
      final String surfaceType = (String) surfaceData.get("surfaceType");

      if (surfaceType.equals("PreviewTexture")) {
        //textureEntry = SuperCameraPlugin.createSurfaceTexture();
        outputs.add(new Surface(textureEntry.surfaceTexture()));
      }
    }

    final TextureRegistry.SurfaceTextureEntry sessionTexture = textureEntry;

    final BinaryMessenger messenger = SuperCameraPlugin.getMessenger();
    final String channelName = call.argument("stateCallbackChannelName");

    final EventChannel eventChannel = new EventChannel(messenger, channelName);
    eventChannel.setStreamHandler(
        new EventChannel.StreamHandler() {
          String CLASS_NAME = "CameraCaptureSessionState";

          @Override
          public void onListen(Object arguments, final EventChannel.EventSink sink) {

            try {
              device.createCaptureSession(outputs, new CameraCaptureSession.StateCallback() {
                @Override
                public void onConfigured(@NonNull CameraCaptureSession session) {
                  final Integer handle = call.argument("sessionHandle");
                  SuperCameraPlugin.addHandler(
                      handle, new FlutterCameraCaptureSession(session, sessionTexture, handle));

                  final Map<String, Object> stateData = new HashMap<>();
                  stateData.put(CLASS_NAME, CLASS_NAME + ".configured");

                  sink.success(stateData);
                }

                @Override
                public void onConfigureFailed(@NonNull CameraCaptureSession session) {

                }
              }, null);
            } catch (CameraAccessException e) {
              // Do Nothing
            }
          }

          @Override
          public void onCancel(Object arguments) {

          }
        });

    if (sessionTexture == null) {
      result.success(null);
    } else {
      result.success(sessionTexture.id());
    }
  }

  private void close(MethodChannel.Result result) {
    device.close();
    SuperCameraPlugin.removeHandler(handle);
    result.success(null);
  }
}
