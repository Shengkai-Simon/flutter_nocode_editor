import '../constants/app_constants.dart';
import '../editor/components/core/widget_node.dart';

/// A service to handle project data migrations between different schema versions.
class ProjectMigratorService {

  /// Migrates a project JSON object to the latest schema version and returns a WidgetNode.
  WidgetNode migrate(Map<String, dynamic> projectJson) {
    // If there is no version number in the JSON, we assume that it is in the old format (version 0) and that the data is the root node itself
    int version = projectJson[ProjectSchemaKeys.schemaVersion] as int? ?? 0;
    Map<String, dynamic> data = (version == 0)
        ? projectJson
        : projectJson[ProjectSchemaKeys.projectData] as Map<String, dynamic>;

    // Use the switch-case structure to handle the step-by-step migration from the old version to the new version
    switch (version) {
    // Case: Migrating from version 0 (old data without version number).
      case 0:
      // Add the modification logic to the old data here
      // data = _migrateV0toV1(data);
      // "fall-through" to the next version

      case 1:
      // Let's say a new property is added in future version 2, and we can do compatibility here
      // data = _migrateV1toV2(data);

      // The current version, no migration is required
      case kCurrentProjectSchemaVersion:
        print('Project data is up-to-date (version $kCurrentProjectSchemaVersion). Parsing...');
        return WidgetNode.fromJson(data);

      default:
      // An error is thrown because we can't handle an unknown future version
        throw Exception('Unsupported project schema version: $version. This tool supports up to version $kCurrentProjectSchemaVersion.');
    }
  }
}
