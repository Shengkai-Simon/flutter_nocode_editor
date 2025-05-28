import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_meta.dart';

class SizingProps {
  static List<PropField> get fields => [
    PropField(
      name: 'width',
      label: 'Width',
      fieldType: FieldType.number,
      defaultValue: null,
      editorBuilder: kDefaultNumberInputEditor,
    ),
    PropField(
      name: 'height',
      label: 'Height',
      fieldType: FieldType.number,
      defaultValue: null,
      editorBuilder: kDefaultNumberInputEditor,
    ),
  ];

  static Map<String, dynamic> get defaults => {'width': null, 'height': null};
}

class MarginProps {
  static List<PropField> get fields => [
    PropField(
      name: 'margin',
      label: 'Margin',
      fieldType: FieldType.edgeInsets,
      defaultValue: 'all:0',
      editorBuilder: kDefaultEdgeInsetsEditor,
    ),
  ];

  static Map<String, dynamic> get defaults => {'margin': 'all:0'};
}

class PaddingProps {
  static List<PropField> get fields => [
    PropField(
      name: 'padding',
      label: 'Padding',
      fieldType: FieldType.edgeInsets,
      defaultValue: 'all:0',
      editorBuilder: kDefaultEdgeInsetsEditor,
    ),
  ];

  static Map<String, dynamic> get defaults => {'padding': 'all:0'};
}

class ChildAlignmentProps {
  static List<PropField> get fields => [
    PropField(
      name: 'alignment',
      label: 'Alignment (Child)',
      fieldType: FieldType.select,
      defaultValue: 'center',
      options: [
        {'id': 'topLeft', 'name': 'Top Left'},
        {'id': 'topCenter', 'name': 'Top Center'},
        {'id': 'topRight', 'name': 'Top Right'},
        {'id': 'centerLeft', 'name': 'Center Left'},
        {'id': 'center', 'name': 'Center'},
        {'id': 'centerRight', 'name': 'Center Right'},
        {'id': 'bottomLeft', 'name': 'Bottom Left'},
        {'id': 'bottomCenter', 'name': 'Bottom Center'},
        {'id': 'bottomRight', 'name': 'Bottom Right'},
      ],
      editorBuilder: kDefaultDropdownEditor,
    ),
  ];

  static Map<String, dynamic> get defaults => {'alignment': 'center'};
}

class BackgroundColorProp {
  static List<PropField> get fields => [
    PropField(
      name: 'backgroundColor',
      label: 'Background Color',
      fieldType: FieldType.color,
      defaultValue: null,
      editorBuilder: kDefaultColorPickerEditor,
    ),
  ];

  static Map<String, dynamic> get defaults => {'backgroundColor': null};
}

class FlexChildProps {
  static List<PropField> get fields => [
    PropField(
      name: 'flex',
      label: 'Flex Factor',
      fieldType: FieldType.number,
      defaultValue: 1,
      editorBuilder: kDefaultNumberInputEditor,
    ),
    PropField(
      name: 'fit',
      label: 'Fit',
      fieldType: FieldType.select,
      defaultValue: 'loose',
      options: [
        {'id': 'loose', 'name': 'Loose'},
        {'id': 'tight', 'name': 'Tight'},
      ],
      editorBuilder: kDefaultDropdownEditor,
    ),
  ];

  static Map<String, dynamic> get defaults => {
    'flex': 1,
  };
}

class MainAxisAlignmentProp {
  static List<PropField> get fields => [
    PropField(
      name: 'mainAxisAlignment',
      label: 'Main Axis Align',
      fieldType: FieldType.select,
      defaultValue: 'start',
      options: [
        {'id': 'start', 'name': 'Start'},
        {'id': 'end', 'name': 'End'},
        {'id': 'center', 'name': 'Center'},
        {'id': 'spaceBetween', 'name': 'Space Between'},
        {'id': 'spaceAround', 'name': 'Space Around'},
        {'id': 'spaceEvenly', 'name': 'Space Evenly'},
      ],
      editorBuilder: kDefaultDropdownEditor,
    ),
  ];

  static Map<String, dynamic> get defaults => {'mainAxisAlignment': 'start'};
}

class CrossAxisAlignmentProp {
  static List<PropField> get fields => [
    PropField(
      name: 'crossAxisAlignment',
      label: 'Cross Axis Align',
      fieldType: FieldType.select,
      defaultValue: 'center',
      options: [
        {'id': 'start', 'name': 'Start'},
        {'id': 'end', 'name': 'End'},
        {'id': 'center', 'name': 'Center'},
        {'id': 'stretch', 'name': 'Stretch'},
        {'id': 'baseline', 'name': 'Baseline (req. textBaseline)'},
      ],
      editorBuilder: kDefaultDropdownEditor,
    ),
  ];

  static Map<String, dynamic> get defaults => {'crossAxisAlignment': 'center'};
}

class MainAxisSizeProp {
  static List<PropField> get fields => [
    PropField(
      name: 'mainAxisSize',
      label: 'Main Axis Size',
      fieldType: FieldType.select,
      defaultValue: 'max',
      options: [
        {'id': 'min', 'name': 'Min'},
        {'id': 'max', 'name': 'Max'},
      ],
      editorBuilder: kDefaultDropdownEditor,
    ),
  ];

  static Map<String, dynamic> get defaults => {'mainAxisSize': 'max'};
}

class BasicTextStyleProps {
  static List<PropField> get fields => [
    PropField(
      name: 'fontSize',
      label: 'Font Size',
      fieldType: FieldType.number,
      defaultValue: 16.0,
      editorBuilder: kDefaultNumberInputEditor,
    ),
    PropField(
      name: 'textColor',
      label: 'Text Color',
      fieldType: FieldType.color,
      defaultValue: '#000000',
      editorBuilder: kDefaultColorPickerEditor,
    ),
    PropField(
      name: 'fontWeight',
      label: 'Font Weight',
      fieldType: FieldType.select,
      defaultValue: 'normal',
      options: [
        {'id': 'normal', 'name': 'Normal (w400)'},
        {'id': 'bold', 'name': 'Bold (w700)'},
        {'id': 'w100', 'name': 'Thin (w100)'},
        {'id': 'w200', 'name': 'Extra-Light (w200)'},
        {'id': 'w300', 'name': 'Light (w300)'},
        {'id': 'w500', 'name': 'Medium (w500)'},
        {'id': 'w600', 'name': 'Semi-Bold (w600)'},
        {'id': 'w800', 'name': 'Extra-Bold (w800)'},
        {'id': 'w900', 'name': 'Black (w900)'},
      ],
      editorBuilder: kDefaultDropdownEditor,
    ),
    PropField(
      name: 'fontStyle',
      label: 'Font Style',
      fieldType: FieldType.select,
      defaultValue: 'normal',
      options: [
        {'id': 'normal', 'name': 'Normal'},
        {'id': 'italic', 'name': 'Italic'},
      ],
      editorBuilder: kDefaultDropdownEditor,
    ),
    PropField(
      name: 'textAlign',
      label: 'Text Align',
      fieldType: FieldType.select,
      defaultValue: 'start',
      options: [
        {'id': 'left', 'name': 'Left'},
        {'id': 'right', 'name': 'Right'},
        {'id': 'center', 'name': 'Center'},
        {'id': 'justify', 'name': 'Justify'},
        {'id': 'start', 'name': 'Start (Locale Specific)'},
        {'id': 'end', 'name': 'End (Locale Specific)'},
      ],
      editorBuilder: kDefaultDropdownEditor,
    ),
  ];

  static Map<String, dynamic> get defaults => {
    'fontSize': 16.0,
    'textColor': '#000000',
    'fontWeight': 'normal',
    'fontStyle': 'normal',
    'textAlign': 'start',
  };
}

class CommonPropsCombiner {
  final List<List<PropField>> fieldSets;
  final List<Map<String, dynamic>> defaultSets;

  CommonPropsCombiner({required this.fieldSets, required this.defaultSets});

  List<PropField> get combinedFields {
    final List<PropField> combined = [];
    for (var set in fieldSets) {
      combined.addAll(set);
    }
    return combined;
  }

  Map<String, dynamic> get combinedDefaults {
    final Map<String, dynamic> combined = {};
    for (var set in defaultSets) {
      combined.addAll(set);
    }
    return combined;
  }
}
