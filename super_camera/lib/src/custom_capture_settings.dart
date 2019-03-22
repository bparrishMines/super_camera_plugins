part of super_camera;

class TextureSettings extends CaptureDelegateSettings {
  TextureSettings({
    @required Function(Texture texture) onTextureReady,
    Function(CameraException exception) onFailure,
  }) : super(
          androidDelegateName:
              'com.example.supercamera.camera1.TextureDelegate',
          iOSDelegateName: 'TextureDelegate',
          onSuccess: (dynamic result) {
            onTextureReady(Texture(textureId: result));
          },
          onFailure: onFailure,
        );
}
