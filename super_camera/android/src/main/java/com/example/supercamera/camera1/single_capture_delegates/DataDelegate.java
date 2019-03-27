package com.example.supercamera.camera1.single_capture_delegates;

import android.hardware.Camera;
import java.util.Map;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class DataDelegate implements SingleCaptureDelegate {
  private MethodChannel.Result result;

  @Override
  public void initialize(
      Map<String, Object> settings, TextureRegistry textureRegistry, MethodChannel.Result result) {
    this.result = result;
  }

  @Override
  public Camera.ShutterCallback getShutterCallback() {
    return null;
  }

  @Override
  public Camera.PictureCallback getRawCallback() {
    return null;
  }

  @Override
  public Camera.PictureCallback getPostViewCallback() {
    return null;
  }

  @Override
  public Camera.PictureCallback getJpegCallback() {
    return new Camera.PictureCallback() {
      @Override
      public void onPictureTaken(byte[] data, Camera camera) {
        result.success(data);
      }
    };
  }
}
