part of super_camera;

class CameraPreview extends StatefulWidget {
  CameraPreview(this.controller);

  final CameraController controller;

  @override
  State<StatefulWidget> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {
  Texture _buildPreviewWidget(int textureId) {
    return Texture(textureId: textureId);
  }

  @override
  Widget build(BuildContext context) {
    final CameraConfigurator config = widget.controller.config;

    if (config.previewTextureId != null) {
      _buildPreviewWidget(config.previewTextureId);
    }

    return FutureBuilder<void>(
      future: config.createPreviewTexture(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Container();
          case ConnectionState.done:
            return _buildPreviewWidget(config.previewTextureId);
        }
        return null; // unreachable
      },
    );
  }
}
