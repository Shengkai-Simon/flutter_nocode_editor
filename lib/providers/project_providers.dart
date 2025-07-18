import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/project_api_service.dart';
import '../state/editor_state.dart';

/// Provider that creates and exposes a single instance of ProjectApiService.
final projectApiServiceProvider = Provider<ProjectApiService>((ref) {
  return ProjectApiService();
});

/// A family provider that fetches project data using the ProjectApiService.
/// It takes a projectId as a parameter and returns the corresponding ProjectState.
final projectDataFutureProvider = FutureProvider.family<ProjectState, String>((ref, projectId) async {
  final apiService = ref.watch(projectApiServiceProvider);
  return apiService.fetchProject(projectId);
});