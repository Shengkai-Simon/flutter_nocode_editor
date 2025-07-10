import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../editor/components/core/widget_node.dart';
import '../services/iframe_communication_service.dart';
import '../services/issue_reporter_service.dart';
import '../state/editor_state.dart';

/// Provider that creates and manages the singleton instance of IframeCommunicationService.
final iframeCommunicationServiceProvider = Provider<IframeCommunicationService>((ref) {
  final service = IframeCommunicationService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider that exposes the incoming message stream from the communication service.
final incomingMessagesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final communicationService = ref.watch(iframeCommunicationServiceProvider);
  return communicationService.messages;
});

/// Central coordinator for handling incoming messages from the React shell.
/// This provider has a side effect (listening to a stream) and doesn't return a value (void).
final iframeMessageCoordinatorProvider = Provider<void>((ref) {
  final communicationService = ref.watch(iframeCommunicationServiceProvider);
  final sub = communicationService.messages.listen((message) {
    final type = message['type'] as String?;
    final payload = message['payload'];
    print('[Flutter Coordinator] Handling message: $type');

    switch (type) {
      case 'reactReady':
      // Handshake complete, can potentially update a state here if needed.
        break;
      case 'applyJsonPatch':
        ref.read(projectErrorsNotifierProvider.notifier).clearIssues();
        ref.read(projectWarningsNotifierProvider.notifier).clearIssues();
        try {
          // 2. Use a new helper function for deep transformation
          final Map<String, dynamic>? deepCastedPayload = _deepCastMap(payload as Map?);

          if (deepCastedPayload == null) {
            throw Exception("Payload was null or could not be deep-casted.");
          }

          // 3. It is now safe to use fromJson
          final WidgetNode canvasTree = createDefaultCanvasTree();
          canvasTree.children.add(WidgetNode.fromJson(deepCastedPayload));

          // 4. Update the status
          ref.read(historyManagerProvider.notifier).recordState(canvasTree);

          print('[Flutter Coordinator] Successfully applied new layout from applyJsonPatch.');

        } catch (e, s) {
          print('[Flutter Coordinator] Error parsing or applying widget tree from payload: $e');
          IssueReporterService().reportError(
            "Failed to apply patch from React",
            source: "CommunicationCoordinator",
            error: e,
            stackTrace: s,
          );
        }
        break;
      case 'GET_LAYOUT_REQUEST':
        final WidgetNode tree = ref.read(canvasTreeProvider);
        final Map<String, dynamic> treeNodeToJson = tree.toJsonWithoutIds();
        if(treeNodeToJson['children'].isNotEmpty && treeNodeToJson['children'][0].isNotEmpty){
          communicationService.sendLayout(message['requestId'], treeNodeToJson['children'][0]);
        }else{
          communicationService.sendLayout(message['requestId'], {});
        }
        break;
      default:
        print('[Flutter Coordinator] Received unknown message type: $type');
    }
  });

  ref.onDispose(() => sub.cancel());
});

// 1. A new helper function has been added for deep conversion Map
Map<String, dynamic>? _deepCastMap(Map<dynamic, dynamic>? data) {
  if (data == null) return null;

  final newMap = <String, dynamic>{};
  data.forEach((key, value) {
    if (key is String) {
      if (value is Map) {
        newMap[key] = _deepCastMap(value);
      } else if (value is List) {
        newMap[key] = _deepCastList(value);
      } else {
        newMap[key] = value;
      }
    }
  });
  return newMap;
}

// Helper function for deep transformations List
List<dynamic> _deepCastList(List<dynamic> list) {
  return list.map((item) {
    if (item is Map) {
      return _deepCastMap(item);
    } else if (item is List) {
      return _deepCastList(item);
    } else {
      return item;
    }
  }).toList();
}