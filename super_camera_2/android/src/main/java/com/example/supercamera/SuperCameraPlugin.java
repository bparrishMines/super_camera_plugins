package com.example.supercamera;

import android.content.Context;
import android.hardware.camera2.CameraManager;
import android.os.Build;
import android.util.SparseArray;
import com.example.supercamera.camera.FlutterCameraManager;
import com.example.supercamera.support_camera.SupportAndroidCamera;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;

/** SuperCameraPlugin */
public class SuperCameraPlugin implements MethodCallHandler {
  private static final String PLUGIN_CHANNEL_NAME = "dev.plugins/super_camera";

  private static final SparseArray<MethodChannel.MethodCallHandler> handlers = new SparseArray<>();

  private static Registrar registrar;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    SuperCameraPlugin.registrar = registrar;
    final MethodChannel channel = new MethodChannel(registrar.messenger(), PLUGIN_CHANNEL_NAME);

    if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      final CameraManager manager =
          (CameraManager) registrar.activity().getSystemService(Context.CAMERA_SERVICE);
      addHandler(-1, new FlutterCameraManager(manager));
    }

    channel.setMethodCallHandler(new SuperCameraPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch(call.method) {
      case "SupportAndroidCamera#getNumberOfCameras":
        result.success(SupportAndroidCamera.getNumberOfCameras());
        return;
      case "SupportAndroidCamera#getCameraInfo":
        result.success(SupportAndroidCamera.getCameraInfo(call));
        return;
      case "SupportAndroidCamera#open":
        final Integer handle = call.argument("handle");
        addHandler(handle, SupportAndroidCamera.open(call));
        result.success(null);
        return;
      default:
        final MethodChannel.MethodCallHandler handler = getHandler(call);

        if (handler == null) {
          result.notImplemented();
          return;
        }

        handler.onMethodCall(call, result);
    }
  }

  private static void addHandler(final int handle, final MethodChannel.MethodCallHandler handler) {
    if (handlers.get(handle) != null) {
      final String message = String.format("Object for handle already exists: %s", handle);
      throw new IllegalArgumentException(message);
    }

    handlers.put(handle, handler);
  }

  public static void removeHandler(final int handle) {
    handlers.remove(handle);
  }

  private static MethodChannel.MethodCallHandler getHandler(final MethodCall call) {
    final Integer handle = call.argument("handle");

    if (handle == null) return null;
    return handlers.get(handle);
  }

  public static TextureRegistry.SurfaceTextureEntry createSurfaceTexture() {
    return registrar.textures().createSurfaceTexture();
  }
}
