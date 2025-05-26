import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/component_registry.dart';
import '../../core/widget_node.dart';

BoxFit _parseBoxFit(String? fitString) {
  switch (fitString) {
    case 'fill': return BoxFit.fill;
    case 'contain': return BoxFit.contain;
    case 'cover': return BoxFit.cover;
    case 'fitWidth': return BoxFit.fitWidth;
    case 'fitHeight': return BoxFit.fitHeight;
    case 'none': return BoxFit.none;
    case 'scaleDown': return BoxFit.scaleDown;
    default: return BoxFit.contain;
  }
}

final RegisteredComponent imageComponentDefinition = RegisteredComponent(
  type: 'Image',
  displayName: 'Image',
  icon: Icons.image,
  defaultProps: {
    'src': 'https://picsum.photos/seed/flutter_editor/200/300',
    'imageType': 'network',
    'width': null,
    'height': null,
    'fit': 'contain',
    'semanticLabel': '',
  },
  propFields: [
    PropField(name: 'src', label: 'Source (URL or Asset Path)', fieldType: FieldType.string, defaultValue: 'https://picsum.photos/seed/flutter_editor/200/300'),
    PropField(
      name: 'imageType',
      label: 'Image Type',
      fieldType: FieldType.select,
      defaultValue: 'network',
      options: [
        {'id': 'network', 'name': 'Network URL'},
        {'id': 'asset', 'name': 'Asset Path (requires setup)'},
      ],
    ),
    PropField(name: 'width', label: 'Width', fieldType: FieldType.number, defaultValue: null),
    PropField(name: 'height', label: 'Height', fieldType: FieldType.number, defaultValue: null),
    PropField(
      name: 'fit',
      label: 'Box Fit',
      fieldType: FieldType.select,
      defaultValue: 'contain',
      options: [
        {'id': 'fill', 'name': 'Fill'},
        {'id': 'contain', 'name': 'Contain'},
        {'id': 'cover', 'name': 'Cover'},
        {'id': 'fitWidth', 'name': 'Fit Width'},
        {'id': 'fitHeight', 'name': 'Fit Height'},
        {'id': 'none', 'name': 'None'},
        {'id': 'scaleDown', 'name': 'Scale Down'},
      ],
    ),
    PropField(name: 'semanticLabel', label: 'Semantic Label', fieldType: FieldType.string, defaultValue: ''),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    final String src = props['src'] as String? ?? '';
    final String imageType = props['imageType'] as String? ?? 'network';
    final double? width = (props['width'] as num?)?.toDouble();
    final double? height = (props['height'] as num?)?.toDouble();
    final BoxFit fit = _parseBoxFit(props['fit'] as String?);
    final String? semanticLabel = props['semanticLabel'] as String?;

    if (src.isEmpty) {
      return Container(
        width: width ?? 50,
        height: height ?? 50,
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: Icon(Icons.broken_image, color: Colors.grey[600], size: (width ?? 50) / 2),
      );
    }

    ImageProvider? imageProvider;
    if (imageType == 'network') {
      if (Uri.tryParse(src)?.isAbsolute ?? false) {
        imageProvider = NetworkImage(src);
      }
    } else if (imageType == 'asset') {
      imageProvider = AssetImage(src);
    }

    if (imageProvider == null) {
      return Container(
        width: width ?? 50,
        height: height ?? 50,
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: Tooltip(
          message: 'Invalid image source or type: $src ($imageType)',
          child: Icon(Icons.error_outline, color: Colors.red[400], size: (width ?? 50) / 2),
        ),
      );
    }

    return Image(
      image: imageProvider,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return Container(
          width: width ?? 50,
          height: height ?? 50,
          color: Colors.grey[200],
          alignment: Alignment.center,
          child: Tooltip(
            message: 'Error loading image:\n$src\n$error',
            child: Icon(Icons.broken_image_outlined, color: Colors.grey[500], size: (width ?? 50) / 2),
          ),
        );
      },
    );
  },
);