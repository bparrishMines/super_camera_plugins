part of super_camera;

class CaptureSession with _NativeMethodCallHandler, _CameraMappable {
  CaptureSession();

  final List<CaptureInput> _inputs = <CaptureInput>[];
  final List<CaptureOutput> _outputs = <CaptureOutput>[];

  void addOutput(CaptureOutput output) {
    assert(output != null);

    _outputs.add(output);
  }

  void removeOutput(CaptureOutput output) {
    _outputs.remove(output);
  }

  void addInput(CaptureInput input) {
    assert(input != null);

    _inputs.add(input);
  }

  void removeInput(CaptureInput input) {
    _inputs.remove(input);
  }

  Future<void> startRunning() {}

  Future<void> stopRunning() {}

  Future<bool> get running {}

  @override
  Map<String, dynamic> asMap() {
    return null;
  }
}
