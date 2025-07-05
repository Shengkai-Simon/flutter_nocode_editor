import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../editor/components/core/widget_node.dart';

// Panel Dimensions
const double kLeftPanelWidth = 356.0;
const double kRightPanelWidth = 300.0;

// WidgetRenderer Visuals
const Color kRendererSelectedBorderColor = Colors.blue;
const Color kRendererUnselectedBorderColor = Color(0x4D9E9E9E);
const Color kRendererTagBackgroundColor = Colors.blue;
const Color kRendererTagTextColor = Colors.white;
const double kRendererWidth = 430.0;
const double kRendererHeight = 932.0;
const double kRendererMinVisibleWidth = 30.0;
const double kRendererMinInteractiveHeight = 15.0;
const double kRendererWrapperMargin = 6.0;
const double kRendererTagFontSize = 10.0;
const double kRendererTagBorderRadius = 3.0;
const EdgeInsets kRendererTagPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 2);

// Define color constants
const Color hoverBorderColor = Colors.orangeAccent; // Hover border color
const Color hoverTagBackgroundColor = Colors.orangeAccent; // Hover over the label background
const Color hoverTagTextColor = Colors.black87; // Hover the label text

const Color selectedBorderColor = kRendererSelectedBorderColor; // The color of the border has been selected
const Color selectedTagBackgroundColor = kRendererTagBackgroundColor; // Selected label background
const Color selectedTagTextColor = kRendererTagTextColor; // Label text selected

const Color layoutBoundBorderColor = kRendererUnselectedBorderColor; // Layout boundary color

const Color kRendererHoverBorderColor = Colors.orangeAccent; // Hover border color
const Color kRendererHoverTagBackgroundColor = Colors.orangeAccent; // Hover over the label background
const Color kRendererHoverTagTextColor = Colors.black87; // Hover the label text

/// The current version of the project JSON schema.
/// Increment this number whenever a breaking change is made to the project data structure.
const int kCurrentProjectSchemaVersion = 1;

/// Defines the keys used in the project's JSON schema as static constants
/// to prevent typos and ensure consistency across the application.
class ProjectSchemaKeys {
  static const String schemaVersion = 'schemaVersion';
  static const String projectData = 'projectData';
}

final uuid = Uuid();

/// Creates and returns a new instance of a default, empty canvas tree.
WidgetNode createDefaultCanvasTree() {
  return WidgetNode(
    id: uuid.v4(),
    type: 'Container',
    props: {
      'width': kRendererWidth,
      'height': kRendererHeight,
      'backgroundColor': '#ffffff',
      'shadowColor': '#999999',
      'shadowOffsetX': 0.0,
      'shadowOffsetY': 2.0,
      'shadowBlurRadius': 4.0,
      'shadowSpreadRadius': 0.0
    },
    children: [],
  );
}