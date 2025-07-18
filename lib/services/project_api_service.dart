import 'dart:convert';

import 'package:flutter_editor/constants/app_constants.dart';
import 'package:http/http.dart' as http;

import '../editor/components/core/widget_node.dart';
import '../editor/models/page_node.dart';
import '../state/editor_state.dart';
import '../state/view_mode_state.dart';

/// An exception thrown when the user's session is invalid or has expired.
class SessionExpiredException implements Exception {
  final String message;
  SessionExpiredException(this.message);

  @override
  String toString() => message;
}

class ProjectApiService {
  final String _baseUrl = 'http://localhost/api';

  Future<ProjectState> fetchProject(String projectId) async {
    final uri = Uri.parse('$_baseUrl/projects/$projectId');

    print('[API Request] ==> GET $uri');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 401) {
        final responseData = jsonDecode(response.body);
        if (responseData['message'] == "Authentication token is invalid or has expired.") {
          print('[API Auth Error] Session expired. Throwing SessionExpiredException.');
          throw SessionExpiredException('The session has expired, please log back in.');
        }
      }

      if (response.statusCode == 200) {
        print('[API Success] <== Status: ${response.statusCode} for $uri');
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        final projectData = apiResponse['data']?['projectData'];

        if (projectData is Map<String, dynamic> && projectData.isNotEmpty) {
          // New: Directly parse the project data into a ProjectState object.
          // This assumes the API returns a 'version' and 'project' structure.
          if (projectData.containsKey('version') && projectData.containsKey('project')) {
            return ProjectState.fromJson(projectData['project']);
          } else {
             // Fallback for old structure or incomplete data, treat as a single page.
            final WidgetNode tree = WidgetNode.fromJson(projectData);
            final defaultPage = PageNode(id: uuid.v4(), name: 'Main Page', tree: tree);
            return ProjectState(
              pages: [defaultPage],
              activePageId: defaultPage.id,
              initialPageId: defaultPage.id,
              view: MainView.overview,
            );
          }
        } else {
          // If projectData is missing or empty, create a default blank project.
          print('[API Info] Received empty projectData. Creating a new, empty project.');
          final defaultPage = PageNode(id: uuid.v4(), name: 'Main Page', tree: createDefaultCanvasTree());
          return ProjectState(
            pages: [defaultPage],
            activePageId: defaultPage.id,
            initialPageId: defaultPage.id,
            view: MainView.overview,
          );
        }
      } else {
        print('[API Error] <== Status: ${response.statusCode} for $uri');
        print('[API Error] Body: ${response.body}');
        throw Exception(
          'Failed to load project. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[API Exception] <== Error fetching from $uri: ${e.toString()}');
      rethrow;
    }
  }
}
