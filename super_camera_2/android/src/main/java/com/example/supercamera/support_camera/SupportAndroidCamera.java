package com.example.supercamera.support_camera;

import android.hardware.Camera;
import com.example.supercamera.SuperCameraPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class SupportAndroidCamera implements MethodChannel.MethodCallHandler {
  private final Camera camera;
  private TextureRegistry.SurfaceTextureEntry textureEntry;
  private final Integer handle;

  private SupportAndroidCamera(Camera camera, Integer handle) {
    this.camera = camera;
    this.handle = handle;
  }

  public static int getNumberOfCameras() {
    return Camera.getNumberOfCameras();
  }

  public static SupportAndroidCamera open(MethodCall call) {
    final Integer cameraId = call.argument("cameraId");
    final Integer handle = call.argument("handle");
    return new SupportAndroidCamera(Camera.open(cameraId), handle);
  }

  public static Map<String, Object> getCameraInfo(MethodCall call) {
    final Integer cameraId = call.argument("cameraId");
    final Camera.CameraInfo info = new Camera.CameraInfo();
    Camera.getCameraInfo(cameraId, info);

    final Map<String, Object> data = new HashMap<>();

    switch(info.facing) {
      case Camera.CameraInfo.CAMERA_FACING_FRONT:
        data.put("Facing", "Facing.front");
        break;
      case Camera.CameraInfo.CAMERA_FACING_BACK:
        data.put("Facing", "Facing.back");
        break;
    }

    data.put("orientation", info.orientation);
    data.put("id", cameraId);

    return data;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch(call.method) {
      case "SupportAndroidCamera#createPreviewTexture":
        createPreviewTexture(result);
        break;
      case "SupportAndroidCamera#startPreview":
        startPreview(result);
        break;
      case "SupportAndroidCamera#stopPreview":
        stopPreview(result);
        break;
      case "SupportAndroidCamera#release":
        release(result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void createPreviewTexture(MethodChannel.Result result) {
    textureEntry = SuperCameraPlugin.createSurfaceTexture();

    try {
      camera.setPreviewTexture(textureEntry.surfaceTexture());
    } catch (IOException e) {
      result.error(e.getClass().getSimpleName(), e.getLocalizedMessage(), null);
      return;
    }

    result.success(textureEntry.id());
  }

  private void startPreview(MethodChannel.Result result) {
    camera.startPreview();
    result.success(null);
  }

  private void stopPreview(MethodChannel.Result result) {
    camera.stopPreview();
    result.success(null);
  }

  private void release(MethodChannel.Result result) {
    camera.release();
    if (textureEntry != null) textureEntry.release();

    SuperCameraPlugin.removeHandler(handle);

    result.success(null);
  }
}
