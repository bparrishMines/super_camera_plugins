package com.example.supercamera;

import android.content.Context;
import android.hardware.camera2.CameraManager;
import android.os.Build;
import android.util.SparseArray;
import com.example.supercamera.camera.FlutterCameraManager;
import com.example.supercamera.common.PlatformTexture;
import com.example.supercamera.support_camera.SupportAndroidCamera;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;
import java.util.Locale;
import java.util.Map;

/** SuperCameraPlugin */
public class SuperCameraPlugin implements MethodCallHandler {
  private static final String CHANNEL_NAME = "dev.plugins/super_camera";
  private static final SparseArray<MethodChannel.MethodCallHandler> handlers = new SparseArray<>();

  private static Registrar registrar;
  private static MethodChannel channel;

  private static MethodChannel.MethodCallHandler getHandler(final MethodCall call) {
    final Integer handle = call.argument("handle");

    if (handle == null) return null;
    return handlers.get(handle);
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    SuperCameraPlugin.registrar = registrar;
    channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(new SuperCameraPlugin());
  }

  public static void addHandler(final int handle, final MethodChannel.MethodCallHandler handler) {
    if (handlers.get(handle) != null) {
      final String message = String.format("Object for handle already exists: %s", handle);
      throw new IllegalArgumentException(message);
    }

    handlers.put(handle, handler);
  }

  public static void removeHandler(final int handle) {
    handlers.remove(handle);
  }

  public static MethodChannel.MethodCallHandler getHandler(final int handle) {
    return handlers.get(handle);
  }

  public static void sendCallback(Map<String, Object> callbackData) {
    channel.invokeMethod("handleCallback", callbackData);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch(call.method) {
      case "Camera#createPlatformTexture":
        createPlatformTexture(call, result);
        break;
      case "SupportAndroidCamera#getNumberOfCameras":
        result.success(SupportAndroidCamera.getNumberOfCameras());
        break;
      case "SupportAndroidCamera#getCameraInfo":
        result.success(SupportAndroidCamera.getCameraInfo(call));
        break;
      case "SupportAndroidCamera#open":
        final Integer cameraHandle = call.argument("cameraHandle");
        addHandler(cameraHandle, SupportAndroidCamera.open(call));
        result.success(null);
        break;
      case "CameraManager()":
        createCameraManager(call, result);
        break;
      default:
        final MethodChannel.MethodCallHandler handler = getHandler(call);

        if (handler == null) {
          result.notImplemented();
          break;
        }

        handler.onMethodCall(call, result);
    }
  }

  private void createCameraManager(MethodCall call, Result result) {
    final int buildVersion = android.os.Build.VERSION.SDK_INT;

    if (buildVersion >= Build.VERSION_CODES.LOLLIPOP) {
      final Integer managerHandle = call.argument("managerHandle");
      final CameraManager manager =
          (CameraManager) registrar.activity().getSystemService(Context.CAMERA_SERVICE);

      addHandler(managerHandle, new FlutterCameraManager(manager));
      result.success(null);
    } else {
      final String message = String.format(
          Locale.getDefault(),
          "Can't use CameraManager for android version: %d",
          buildVersion);
      throw new IllegalAccessError(message);
    }
  }

  private void createPlatformTexture(MethodCall call, Result result) {
    final TextureRegistry.SurfaceTextureEntry entry = registrar.textures().createSurfaceTexture();
    final Integer textureHandle = call.argument("textureHandle");
    addHandler(textureHandle, new PlatformTexture(entry, textureHandle));

    result.success(entry.id());
  }
}
