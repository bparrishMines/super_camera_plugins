package com.example.supercamera.camera;

import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
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

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
class Parsers {
  private Parsers() {}

  static CaptureRequest parseCaptureRequest(int deviceHandle, Map<String, Object> data) throws CameraAccessException {
    final FlutterCameraDevice device =
        (FlutterCameraDevice) SuperCameraPlugin.getHandler(deviceHandle);

    final int requestTemplate;
    switch ((String) data.get("Template")) {
      case "Template.preview":
        requestTemplate = CameraDevice.TEMPLATE_PREVIEW;
        break;
      default:
        throw new IllegalArgumentException();
    }

    CaptureRequest.Builder builder = device.device.createCaptureRequest(requestTemplate);

    final List<Map<String, Object>> targetData = (List<Map<String, Object>>) data.get("targets");
    for(Surface target : parseSurfaces(targetData)) {
      builder.addTarget(target);
    }

    return builder.build();
  }

  static List<Surface> parseSurfaces(List<Map<String, Object>> data) {
    final List<Surface> outputs = new ArrayList<>();

    for (Map<String, Object> outputData : data) {
      final String surfaceClass = (String) outputData.get("surfaceClass");

      if (surfaceClass.equals("PreviewTexture")) {
        final Integer textureHandle = (Integer) outputData.get("textureHandle");
        final PlatformTexture texture = (PlatformTexture) SuperCameraPlugin.getHandler(textureHandle);

        final Map<String, Object> surfaceTextureData =
            (Map<String, Object>) outputData.get("SurfaceTexture");
        final Double width = (Double) surfaceTextureData.get("width");
        final Double height = (Double) surfaceTextureData.get("height");

        final SurfaceTexture surfaceTexture = texture.textureEntry.surfaceTexture();

        if (width != null) {
          surfaceTexture.setDefaultBufferSize(width.intValue(), height.intValue());
        }

        outputs.add(new Surface(surfaceTexture));
      }
    }

    return outputs;
  }
}
