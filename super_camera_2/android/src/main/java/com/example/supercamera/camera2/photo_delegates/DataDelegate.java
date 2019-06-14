package com.example.supercamera.camera2.photo_delegates;

import android.media.Image;
import android.media.ImageReader;
import android.os.Build;
import java.nio.ByteBuffer;
import java.util.Map;
import androidx.annotation.RequiresApi;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class DataDelegate implements PhotoDelegate {
  private EventChannel.EventSink eventSink;

  @Override
  public void initialize(
      Map<String, Object> settings, TextureRegistry textureRegistry, BinaryMessenger messenger) {
    final String channelName = (String) settings.get("channelName");
    final EventChannel eventChannel = new EventChannel(messenger, channelName);

    eventChannel.setStreamHandler(
        new EventChannel.StreamHandler() {
          @Override
          public void onListen(Object arguments, EventChannel.EventSink sink) {
            eventSink = sink;
          }

          @Override
          public void onCancel(Object arguments) {}
        });
  }

  @Override
  public ImageReader.OnImageAvailableListener getOnImageAvailableListener() {
    return new ImageReader.OnImageAvailableListener() {
      @Override
      public void onImageAvailable(ImageReader reader) {
        final Image image = reader.acquireLatestImage();
        final ByteBuffer buffer = image.getPlanes()[0].getBuffer();

        byte[] bytes = new byte[buffer.remaining()];
        buffer.get(bytes, 0, bytes.length);
        eventSink.success(bytes);

        image.close();
      }
    };
  }

  @Override
  public void onFinishSetup(MethodChannel.Result result) {
    result.success(null);
  }

  @Override
  public void close() {
    eventSink.endOfStream();
  }
}
