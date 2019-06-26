part of super_camera;

enum _CaptureInputClass { captureDeviceInput }

abstract class CaptureInput with _NativeMethodCallHandler, _CameraMappable {
  List<CaptureInputPort> get ports;
}

class CaptureInputPort with _NativeMethodCallHandler, _CameraMappable {
  CaptureInputPort._(this.input);

  final CaptureInput input;

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{'handle': _handle, 'inputHandle': input._handle};
  }
}

class CaptureDeviceInput extends CaptureInput {
  CaptureDeviceInput({@required this.device}) : assert(device != null) {
    _ports = <CaptureInputPort>[CaptureInputPort._(this)];
  }

  static const _CaptureInputClass _inputClass =
      _CaptureInputClass.captureDeviceInput;

  final CaptureDevice device;
  List<CaptureInputPort> _ports;

  @override
  List<CaptureInputPort> get ports {
    return List<CaptureInputPort>.unmodifiable(_ports);
  }

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'handle': _handle,
      'class': _inputClass.toString(),
      'device': device.asMap(),
      'ports': ports.map<Map<String, dynamic>>(
        (CaptureInputPort port) => port.asMap(),
      ).toList(),
    };
  }
}
