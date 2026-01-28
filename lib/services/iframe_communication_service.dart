import 'dart:async';

import 'dart:js_interop';

// 1. Defines the static interop type of the Window object
@JS('window')
@staticInterop
class WindowInterop {}

// 2. Define the desired extension method on this type
extension WindowExtension on WindowInterop {
  external WindowInterop? get parent;

  external void postMessage(JSAny message, JSString targetOrigin);
  external void addEventListener(JSString type, JSFunction listener);
  external void removeEventListener(JSString type, JSFunction listener);
}

@JS('window')
external WindowInterop get window;

@JS()
@anonymous
extension type MessageEvent(JSObject o) implements JSObject {
  external JSAny get data;
  external JSString get origin;
}

/// A service class that handles all communication with the parent window
class IframeCommunicationService {
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  late final JSFunction _messageListener;

  IframeCommunicationService() {
    _setupMessageListener();
  }

  void _setupMessageListener() {
    _messageListener = ((JSObject event) {
      final messageEvent = MessageEvent(event);
      final data = messageEvent.data;

      if (data is JSObject) {
        try {
          final dartMap = (data.dartify() as Map).cast<String, dynamic>();
          print('[Flutter] Received message from parent: $dartMap');
          _messageController.add(dartMap);
        } catch (e) {
          print('[Flutter] Could not parse received message: $e');
        }
      }
    }).toJS;
    window.addEventListener('message'.toJS, _messageListener);
  }

  void dispose() {
    print('[Flutter] Disposing communication service.');
    window.removeEventListener('message'.toJS, _messageListener);
    _messageController.close();
  }

  void _postMessageToParent(Map<String, dynamic> messageData) {
    try {
      final parentWindow = window.parent;
      if (parentWindow == null) {
        print('[Flutter] Error: parent window is not accessible.');
        return;
      }

      final message = messageData.jsify();
      parentWindow.postMessage(message!, '*'.toJS);
    } catch (e) {
      print('[Flutter] Error sending postMessage: $e');
    }
  }

  void sendFlutterReady() {
    print('[Flutter] Sending "flutterReady" message to parent shell.');
    _postMessageToParent({'type': 'flutterReady', 'payload': true});
  }

  void sendLayout(String requestId, Map<String, dynamic> layoutJson) {
    print('[Flutter] Sending "sendLayout" message to parent shell.');
    _postMessageToParent({
      'type': 'GET_LAYOUT_RESPONSE',
      'requestId': requestId,
      'payload': layoutJson
    });
  }

  void sendProjectUpdate(String jsonData) {
    print('[Flutter] Sending "projectUpdate" message to parent shell.');
    _postMessageToParent({'type': 'projectUpdate', 'payload': jsonData});
  }

  void sendSelectionChanged(Map<String, String>? selection) {
    print('[Flutter] Sending "selectionChanged" message to parent shell.');
    _postMessageToParent({'type': 'selectionChanged', 'payload': selection});
  }
}
