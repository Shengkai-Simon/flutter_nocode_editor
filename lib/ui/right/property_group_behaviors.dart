import 'package:flutter_editor/utils/parsing_util.dart';

/// An abstract class defining the behavior for a property group
/// that can be enabled or disabled with a switch in the UI.
abstract class SwitchablePropertyGroup {
  /// Determines if the property group is currently considered active
  /// based on the widget's properties.
  bool isEffectivelyEnabled(Map<String, dynamic> props);

  /// Returns a map of the default properties to apply when the group is
  /// enabled by the user.
  Map<String, dynamic> getEnableDefaults(Map<String, dynamic> currentProps);

  /// Returns a map of the properties to reset or nullify when the group
  /// is disabled by the user.
  Map<String, dynamic> getDisableDefaults(Map<String, dynamic> currentProps);
}

/// Behavior implementation for the 'Background' property group.
class BackgroundPropertyGroup implements SwitchablePropertyGroup {
  @override
  bool isEffectivelyEnabled(Map<String, dynamic> props) {
    final String? bgColor = props['backgroundColor'] as String?;
    final bool hasBgColor = bgColor != null && bgColor.isNotEmpty && ParsingUtil.parseColor(bgColor).alpha != 0;
    final String? gradientType = props['gradientType'] as String?;
    final bool hasGradient = gradientType != null && gradientType != 'none';
    return hasBgColor || hasGradient;
  }

  @override
  Map<String, dynamic> getEnableDefaults(Map<String, dynamic> currentProps) {
    final newProps = Map<String, dynamic>.from(currentProps);
    if (!isEffectivelyEnabled(newProps)) {
      newProps['backgroundColor'] = '#FFF0F0F0'; // Default to a light grey
      newProps['gradientType'] = 'none';
    } else {
      // If it's already "enabled" but has no color (e.g., transparent), give it one.
      if (newProps['backgroundColor'] == null && (newProps['gradientType'] == null || newProps['gradientType'] == 'none')) {
        newProps['backgroundColor'] = '#FFF0F0F0';
      }
    }
    return newProps;
  }

  @override
  Map<String, dynamic> getDisableDefaults(Map<String, dynamic> currentProps) {
    final newProps = Map<String, dynamic>.from(currentProps);
    newProps['backgroundColor'] = null;
    newProps['gradientType'] = 'none';
    // Also clear gradient-specific properties
    newProps.remove('gradientColor1');
    newProps.remove('gradientColor2');
    newProps.remove('gradientBeginAlignment');
    newProps.remove('gradientEndAlignment');
    return newProps;
  }
}

/// Behavior implementation for the 'Border' property group.
class BorderPropertyGroup implements SwitchablePropertyGroup {
  @override
  bool isEffectivelyEnabled(Map<String, dynamic> props) {
    return (props['borderWidth'] as num? ?? 0) > 0;
  }

  @override
  Map<String, dynamic> getEnableDefaults(Map<String, dynamic> currentProps) {
    final newProps = Map<String, dynamic>.from(currentProps);
    if (!isEffectivelyEnabled(newProps)) {
      newProps['borderWidth'] = 1.0;
      newProps['borderColor'] = '#FF000000'; // Default to black
    } else {
      // If it's enabled but somehow has 0 width, fix it.
      if ((newProps['borderWidth'] as num? ?? 0) <= 0) {
        newProps['borderWidth'] = 1.0;
      }
      // Ensure a color is set if border is enabled.
      newProps['borderColor'] ??= '#FF000000';
    }
    return newProps;
  }

  @override
  Map<String, dynamic> getDisableDefaults(Map<String, dynamic> currentProps) {
    final newProps = Map<String, dynamic>.from(currentProps);
    newProps['borderWidth'] = 0.0;
    // We can leave borderColor as is, since width=0 makes it invisible.
    return newProps;
  }
}

/// Behavior implementation for the 'Shadow' property group.
class ShadowPropertyGroup implements SwitchablePropertyGroup {
  @override
  bool isEffectivelyEnabled(Map<String, dynamic> props) {
    final String? shadowColor = props['shadowColor'] as String?;
    return shadowColor != null && shadowColor.isNotEmpty && ParsingUtil.parseColor(shadowColor).alpha != 0;
  }

  @override
  Map<String, dynamic> getEnableDefaults(Map<String, dynamic> currentProps) {
    final newProps = Map<String, dynamic>.from(currentProps);
    if (!isEffectivelyEnabled(newProps)) {
      // Set a default shadow if enabling from scratch
      newProps['shadowColor'] = '#8A000000'; // Default black with some transparency
      newProps['shadowOffsetX'] ??= 0.0;
      newProps['shadowOffsetY'] ??= 2.0;
      newProps['shadowBlurRadius'] ??= 4.0;
      newProps['shadowSpreadRadius'] ??= 0.0;
    } else {
      // If it's already "enabled" but has no color (e.g., transparent), give it one.
      newProps['shadowColor'] ??= '#8A000000';
    }
    return newProps;
  }

  @override
  Map<String, dynamic> getDisableDefaults(Map<String, dynamic> currentProps) {
    final newProps = Map<String, dynamic>.from(currentProps);
    newProps['shadowColor'] = null;
    // We can leave the other shadow properties as they are,
    // since a null color makes the shadow invisible.
    return newProps;
  }
}
