import 'package:flutter/material.dart';

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