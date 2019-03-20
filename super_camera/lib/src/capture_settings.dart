part of super_camera;

abstract class SingleCaptureSettings {
  const SingleCaptureSettings({this.onSuccess, this.onFailure});

  final Function(dynamic result) onSuccess;
  final Function(CameraException exception) onFailure;

  Map<String, dynamic> serialize();
}

abstract class RepeatingCaptureSettings {
  const RepeatingCaptureSettings({this.onSuccess, this.onFailure});

  final Function(dynamic result) onSuccess;
  final Function(CameraException exception) onFailure;

  Map<String, dynamic> serialize();
}

typedef TextureReadyCallback = Function(Texture texture);

class TextureCaptureSettings extends RepeatingCaptureSettings {
  TextureCaptureSettings._({Function onSuccess, Function onFailure})
      : super(onSuccess: onSuccess, onFailure: onFailure);

  factory TextureCaptureSettings({
    TextureReadyCallback onTextureReady,
    Function(CameraException exception) onFailure,
  }) {
    final Function(dynamic result) onSuccess = (dynamic textureId) {
      onTextureReady(Texture(textureId: textureId));
    };

    return TextureCaptureSettings._(onSuccess: onSuccess, onFailure: onFailure);
  }

  @override
  Map<String, int> serialize() => null;
}
