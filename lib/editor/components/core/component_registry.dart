import '../../properties/core/property_meta.dart';
import '../definitions/align.dart';
import '../definitions/aspect_ratio.dart';
import '../definitions/card.dart';
import '../definitions/center.dart';
import '../definitions/column.dart';
import '../definitions/container.dart';
import '../definitions/divider.dart';
import '../definitions/elevated_button.dart';
import '../definitions/icon.dart';
import '../definitions/image.dart';
import '../definitions/padding.dart';
import '../definitions/row.dart';
import '../definitions/spacer.dart';
import '../definitions/stack.dart';
import '../definitions/text.dart';


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
};


