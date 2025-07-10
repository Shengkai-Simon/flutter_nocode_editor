import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../editor/components/core/widget_node.dart';
import '../services/project_api_service.dart';

/// Provider that creates and exposes a single instance of ProjectApiService.
final projectApiServiceProvider = Provider<ProjectApiService>((ref) {
  return ProjectApiService();
});

/// A family provider that fetches project data using the ProjectApiService.
/// It takes a projectId as a parameter and returns the corresponding WidgetNode.
final projectProvider = FutureProvider.family<WidgetNode, String>((ref, projectId) async {
  final apiService = ref.watch(projectApiServiceProvider);
  return apiService.fetchProject(projectId);
});