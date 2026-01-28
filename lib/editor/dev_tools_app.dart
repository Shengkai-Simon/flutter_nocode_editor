import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_editor/constants/app_constants.dart';
import 'package:flutter_editor/editor/components/core/component_registry.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'components/core/component_definition.dart';
import 'components/core/widget_node.dart';

void main() {
  runApp(const DevToolsApp());
}

class DevToolsApp extends StatelessWidget {
  const DevToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Developer Tools',
      theme: ThemeData.dark(),
      home: const DefaultTabController(
        length: 2,
        child: DevToolsPage(),
      ),
    );
  }
}

/// The page used to display schemas and examples
class DevToolsPage extends StatefulWidget {
  const DevToolsPage({super.key});

  @override
  State<DevToolsPage> createState() => _DevToolsPageState();
}

class _DevToolsPageState extends State<DevToolsPage> {
  String? _schemaJson;
  String? _exampleJson;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllContent();
  }

  Future<void> _loadAllContent() async {
    final results = await Future.wait([
      _generateSchemaJson(),
      _generateExampleProjectJson(),
    ]);

    if (mounted) {
      setState(() {
        _schemaJson = results[0];
        _exampleJson = results[1];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Developer Tools',
          style: TextStyle(color: Color(0xFF9CDCFE), fontSize: 18),
        ),
        bottom: const TabBar(
          indicatorColor: Colors.blueAccent,
          tabs: [
            Tab(text: 'Project Schema'),
            Tab(text: 'Example Project'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        children: [
          _JsonDisplayView(
            key: const ValueKey('schema'),
            jsonString: _schemaJson!,
            fileName: 'project_schema_v$kCurrentProjectSchemaVersion.json',
          ),
          _JsonDisplayView(
            key: const ValueKey('example'),
            jsonString: _exampleJson!,
            fileName: 'example_project_v$kCurrentProjectSchemaVersion.json',
          ),
        ],
      ),
    );
  }
}

/// A reusable widget that displays JSON content and provides copy and download functionality
class _JsonDisplayView extends StatefulWidget {
  final String jsonString;
  final String fileName;

  const _JsonDisplayView({super.key, required this.jsonString, required this.fileName});

  @override
  State<_JsonDisplayView> createState() => _JsonDisplayViewState();
}

class _JsonDisplayViewState extends State<_JsonDisplayView> with AutomaticKeepAliveClientMixin {
  Widget? _cachedSyntaxView;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _precacheSyntaxView();
  }

  Future<void> _precacheSyntaxView() async {
    // Put the heavyweight widget building process into a microtask in the background
    await Future.microtask(() {
      final view = SyntaxView(
        code: widget.jsonString,
        syntax: Syntax.DART,
        syntaxTheme: SyntaxTheme.vscodeDark(),
        withZoom: true,
        withLinesCount: true,
        expanded: true,
      );
      // Once the build is complete, update the status to cache the widget
      if (mounted) {
        setState(() {
          _cachedSyntaxView = view;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        Container(
          color: const Color(0xFF2D2D2D),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Tooltip(
                message: 'Copy to Clipboard',
                child: IconButton(
                  icon: const Icon(Icons.copy_all_outlined, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.jsonString));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard!')),
                    );
                  },
                ),
              ),
              Tooltip(
                message: 'Download File',
                child: IconButton(
                  icon: const Icon(Icons.download_outlined, size: 20),
                  onPressed: () => _downloadJsonFile(widget.jsonString, widget.fileName, context),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _cachedSyntaxView == null
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : _cachedSyntaxView!,
        ),
      ],
    );
  }
}

Future<String> _generateSchemaJson() async {
  return compute((_) {
    final Map<String, dynamic> schema = {
      'schemaVersion': kCurrentProjectSchemaVersion,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'components': <String, dynamic>{},
    };
    final componentsMap = schema['components'] as Map<String, dynamic>;
    for (final component in registeredComponents.values) {
      final propertiesMap = <String, dynamic>{};
      for (final propField in component.propFields) {
        propertiesMap[propField.name] = {
          'type': propField.fieldType.name,
          'defaultValue': _toJsonEncodable(propField.defaultValue),
          'category': propField.propertyCategory.name,
        };
      }
      final encodableDefaultProps = component.defaultProps.map(
            (key, value) => MapEntry(key, _toJsonEncodable(value)),
      );
      componentsMap[component.type] = {
        'type': component.type,
        'childPolicy': component.childPolicy.name,
        'category': component.category.name,
        'defaultProps': encodableDefaultProps,
        'properties': propertiesMap,
      };
    }
    const jsonEncoder = JsonEncoder.withIndent('  ');
    return jsonEncoder.convert(schema);
  }, null);
}

Future<String> _generateExampleProjectJson() async {
  return compute((_) {
    final List<WidgetNode> allComponentNodes = [];

    for (final rc in registeredComponents.values) {
      if (rc.type == 'Container') continue;
      final Map<String, dynamic> props = Map.from(rc.defaultProps);
      final List<WidgetNode> children = [];
      if (rc.childPolicy == ChildAcceptancePolicy.single || rc.childPolicy == ChildAcceptancePolicy.multiple) {
        children.add(WidgetNode(
          id: uuid.v4(),
          type: 'Text',
          props: {'text': rc.displayName, 'fontSize': 10.0, 'textColor': '#FF9E9E9E'},
        ));
      }
      allComponentNodes.add(
          WidgetNode(
            id: uuid.v4(),
            type: 'Padding',
            props: {'padding': 'all:8'},
            children: [
              WidgetNode(
                id: uuid.v4(),
                type: rc.type,
                props: props,
                children: children,
              ),
            ],
          )
      );
    }

    final WidgetNode exampleTree = WidgetNode(
      id: uuid.v4(),
      type: 'Container',
      props: {
        'width': kRendererWidth,
        'height': kRendererHeight,
        'backgroundColor': '#FFF5F5F5',
      },
      children: [
        WidgetNode(
          id: uuid.v4(),
          type: 'Column',
          props: { 'mainAxisAlignment': 'start', 'crossAxisAlignment': 'stretch' },
          children: allComponentNodes,
        )
      ],
    );

    final versionedProject = {
      ProjectSchemaKeys.schemaVersion: kCurrentProjectSchemaVersion,
      ProjectSchemaKeys.projectData: exampleTree.toJson(),
    };

    const jsonEncoder = JsonEncoder.withIndent('  ');
    return jsonEncoder.convert(versionedProject);
  }, null);
}

void _downloadJsonFile(String content, String fileName, BuildContext context) {
  try {
    final blob = web.Blob([content.toJS].toJS, web.BlobPropertyBag(type: 'application/json'));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = fileName;
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error downloading file: $e"), backgroundColor: Colors.red),
    );
  }
}

dynamic _toJsonEncodable(dynamic value) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }
  if (value is Color) {
    return '#${value.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
  if (value is Offset) {
    return {'dx': value.dx, 'dy': value.dy};
  }
  if (value is Rect) {
    return {'left': value.left, 'top': value.top, 'right': value.right, 'bottom': value.bottom};
  }
  if (value is Radius) {
    return {'x': value.x, 'y': value.y};
  }
  return value.toString();
}
