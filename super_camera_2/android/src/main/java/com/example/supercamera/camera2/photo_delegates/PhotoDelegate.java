package com.example.supercamera.camera2.photo_delegates;

import android.media.ImageReader;
import android.os.Build;
import java.util.Map;
import androidx.annotation.RequiresApi;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public interface PhotoDelegate {
  void initialize(
      Map<String, Object> settings, TextureRegistry textureRegistry, BinaryMessenger messenger);

  ImageReader.OnImageAvailableListener getOnImageAvailableListener();

  void onFinishSetup(MethodChannel.Result result);

  void close();
}
