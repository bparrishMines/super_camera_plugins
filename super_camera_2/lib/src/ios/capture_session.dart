part of super_camera;

class CaptureSession with _NativeMethodCallHandler, _CameraMappable {
  CaptureSession();

  List<CaptureInput> _inputs;
  List<CaptureOutput> _outputs;

  List<CaptureInput> get inputs => List<CaptureInput>.unmodifiable(_inputs);
  List<CaptureOutput> get outputs => List<CaptureOutput>.unmodifiable(_outputs);

  Future<void> addOutput(CaptureOutput output) {
    assert(output != null);

    _outputs.add(output);
    return running
      ..then((bool isRunning) {
        if (isRunning) {
          Camera.channel.invokeMethod<void>(
            '$CaptureSession#addOutput',
            <String, dynamic>{'handle': _handle},
          );
        }
      }).catchError(() => _outputs.remove(output));
  }

  Future<void> removeOutput(CaptureOutput output) {
    _outputs.remove(output);
    return running
      ..then((bool isRunning) {
        if (isRunning) {
          Camera.channel.invokeMethod<void>(
            '$CaptureSession#removeOutput',
            <String, dynamic>{'handle': _handle},
          );
        }
      });
  }

  Future<void> addInput(CaptureInput input) {
    assert(input != null);

    _inputs.add(input);
    return running
      ..then((bool isRunning) {
        if (isRunning) {
          Camera.channel.invokeMethod<void>(
            '$CaptureSession#addInput',
            <String, dynamic>{'handle': _handle},
          );
        }
      }).catchError(() => _inputs.remove(input));
  }

  Future<void> removeInput(CaptureInput input) {
    _inputs.remove(input);
    return running
      ..then((bool isRunning) {
        if (isRunning) {
          Camera.channel.invokeMethod<void>(
            '$CaptureSession#removeInput',
            <String, dynamic>{'handle': _handle},
          );
        }
      });
  }

  Future<void> startRunning() {
    assert(inputs.length > 0);
    assert(outputs.length > 0);

    return Camera.channel.invokeMethod<void>(
      '$CaptureSession#startRunning',
      <String, dynamic>{'handle': _handle, ...asMap()},
    );
  }

  Future<void> stopRunning() {
    return Camera.channel.invokeMethod<void>(
      '$CaptureSession#stopRunning',
      <String, dynamic>{'handle': _handle},
    );
  }

  Future<bool> get running {
    return Camera.channel.invokeMethod<bool>(
      '$CaptureSession#running',
      <String, dynamic>{'handle': _handle},
    );
  }

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'inputs': inputs
          .map<Map<String, dynamic>>((CaptureInput input) => input.asMap())
          .toList(),
      'outputs': outputs
          .map<Map<String, dynamic>>((CaptureOutput output) => output.asMap())
          .toList(),
    };
  }
}
