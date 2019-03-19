part of super_camera;

abstract class SingleCaptureSettings {
  const SingleCaptureSettings({this.onSuccess, this.onFailure});

  final Function onSuccess;
  final Function onFailure;
}

abstract class RepeatingCaptureSettings {
  const RepeatingCaptureSettings({this.onSuccess, this.onFailure});

  final Function onSuccess;
  final Function onFailure;
}

typedef TextureReadyCallback = Function(Texture texture);

class TextureCaptureSettings extends SingleCaptureSettings {
  TextureCaptureSettings(
    TextureReadyCallback onTextureReady,
    Function() onFailure,
  ) : super(
          onSuccess: (dynamic id) => onTextureReady(Texture(textureId: id)),
          onFailure: onFailure,
        );
}
