package com.example.supercamera.base;

import java.util.Map;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public abstract class BaseCameraController implements MethodChannel.MethodCallHandler {
  public class ErrorCodes {
    static final public String CAMERA_CONTROLLER_NOT_OPEN = "CameraControllerNotOpen";
    static final public String INVALID_DELEGATE_NAME = "InvalidDelegateName";
    static final public String INVALID_SETTING = "InvalidSetting";
    static final public String UNKNOWN = "Unknown";
  }

  protected final String cameraId;
  protected final TextureRegistry textureRegistry;

  public BaseCameraController(final String cameraId, final TextureRegistry textureRegistry) {
    this.cameraId = cameraId;
    this.textureRegistry = textureRegistry;
  }

  public abstract void open(MethodChannel.Result result);

  public abstract void startRunning(MethodChannel.Result result);

  public abstract void takePhoto(Map<String, Object> settings, MethodChannel.Result result);

  public abstract void setVideoSettings(Map<String, Object> settings, MethodChannel.Result result);

  public abstract void stopRunning();

  public abstract void close();
}
