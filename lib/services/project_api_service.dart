import 'dart:convert';

import 'package:flutter_editor/constants/app_constants.dart';
import 'package:http/http.dart' as http;

import '../editor/components/core/widget_node.dart';

class ProjectApiService {
  final String _baseUrl = 'http://localhost/api';

  Future<WidgetNode> fetchProject(String projectId) async {
    final uri = Uri.parse('$_baseUrl/projects/$projectId');

    print('[API Request] ==> GET $uri');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print('[API Success] <== Status: ${response.statusCode} for $uri');
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        final projectData = apiResponse['data']?['projectData'];

        if (projectData is Map<String, dynamic>) {
          // Check if projectData is empty
          if (projectData.isEmpty) {
            // If it is empty, it means that it is a new project and returns a default blank canvas structure
            print('[API Info] Received empty projectData for $uri. Creating a new, empty canvas.');
            return createDefaultCanvasTree();
          } else {
            // If it is not empty, the existing project data is parsed normally
            return WidgetNode.fromJson(projectData);
          }
        } else {
          // If projectData doesn't exist or is not formatted correctly, an exception is thrown
          throw Exception('API Error: Project data is missing or has an incorrect format.');
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
      throw Exception(
        'An error occurred while fetching the project: ${e.toString()}',
      );
    }
  }
}
