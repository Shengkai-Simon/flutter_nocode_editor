import 'package:flutter_editor/editor/components/core/component_definition.dart';

import '../definitions/align.dart';
import '../definitions/aspect_ratio.dart';
import '../definitions/backdrop_filter.dart';
import '../definitions/card.dart';
import '../definitions/center.dart';
import '../definitions/checkbox.dart';
import '../definitions/column.dart';
import '../definitions/container.dart';
import '../definitions/divider.dart';
import '../definitions/dropdown_button.dart';
import '../definitions/elevated_button.dart';
import '../definitions/expanded.dart';
import '../definitions/flexible.dart';
import '../definitions/icon.dart';
import '../definitions/image.dart';
import '../definitions/padding.dart';
import '../definitions/radio.dart';
import '../definitions/row.dart';
import '../definitions/slider.dart';
import '../definitions/spacer.dart';
import '../definitions/stack.dart';
import '../definitions/switch.dart';
import '../definitions/text.dart';
import '../definitions/textfield.dart';
import '../definitions/wrap.dart';


/// Registry: Component Type → Component Metadata
final Map<String, RegisteredComponent> registeredComponents = {
  textComponentDefinition.type: textComponentDefinition,
  containerComponentDefinition.type: containerComponentDefinition,
  columnComponentDefinition.type: columnComponentDefinition,
  rowComponentDefinition.type: rowComponentDefinition,
  paddingComponentDefinition.type: paddingComponentDefinition,
  elevatedButtonComponentDefinition.type: elevatedButtonComponentDefinition,
  centerComponentDefinition.type: centerComponentDefinition,
  iconComponentDefinition.type: iconComponentDefinition,
  imageComponentDefinition.type: imageComponentDefinition,
  stackComponentDefinition.type: stackComponentDefinition,
  dividerComponentDefinition.type: dividerComponentDefinition,
  cardComponentDefinition.type: cardComponentDefinition,
  alignComponentDefinition.type: alignComponentDefinition,
  spacerComponentDefinition.type: spacerComponentDefinition,
  aspectRatioComponentDefinition.type: aspectRatioComponentDefinition,
  expandedComponentDefinition.type: expandedComponentDefinition,
  flexibleComponentDefinition.type: flexibleComponentDefinition,
  wrapComponentDefinition.type: wrapComponentDefinition,
  switchComponentDefinition.type: switchComponentDefinition,
  checkboxComponentDefinition.type: checkboxComponentDefinition,
  textFieldComponentDefinition.type: textFieldComponentDefinition,
  dropdownButtonComponentDefinition.type: dropdownButtonComponentDefinition,
  sliderComponentDefinition.type: sliderComponentDefinition,
  radioComponentDefinition.type: radioComponentDefinition,
  backdropFilterComponentDefinition.type: backdropFilterComponentDefinition,
};


