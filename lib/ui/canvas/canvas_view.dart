import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../../state/editor_state.dart';
import '../../state/view_mode_state.dart';
import 'widget_renderer.dart';

class CanvasView extends ConsumerStatefulWidget {
  const CanvasView({super.key});

  @override
  ConsumerState<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends ConsumerState<CanvasView> {
  final TransformationController _transformationController = TransformationController();
  final FocusNode _focusNode = FocusNode();
  bool _isInitialFitPerformed = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();

    // Listen for changes to selectedNodeIdProvider
    ref.listenManual<String?>(selectedNodeIdProvider, (previous, next) {
      // Whether the right_view pops or retracts, wait for the animation to end and readjust to the screen
      Future.delayed(const Duration(milliseconds: 260), () {
        if (mounted) {
          _fitToScreen();
        }
      });
    });

    ref.listenManual<MainView>(mainViewProvider, (previous, next) {
      if (next == MainView.editor && previous == MainView.overview) {
        _isInitialFitPerformed = false;
      }
    });

    ref.listenManual<double>(canvasScaleProvider, (prev, next) {
      final currentMatrixScale = _transformationController.value.getMaxScaleOnAxis();
      if ((next - currentMatrixScale).abs() > 0.001) {
        if (next == 0.0) {
          _fitToScreen();
        } else {
          _programmaticZoom(next);
        }
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _fitToScreen() {
    if (!mounted || context.size == null || context.size!.isEmpty) return;

    final viewSize = context.size!;
    final tree = ref.read(activeCanvasTreeProvider);
    final canvasWidth = (tree.props['width'] as num?)?.toDouble() ?? 1.0;
    final canvasHeight = (tree.props['height'] as num?)?.toDouble() ?? 1.0;

    final paddingFactor = 0.90;
    final scaleX = (viewSize.width * paddingFactor) / canvasWidth;
    final scaleY = (viewSize.height * paddingFactor) / canvasHeight;
    final targetScale = min(scaleX, scaleY).clamp(0.1, 4.0);

    final newMatrix = Matrix4.identity()
      ..translate(viewSize.width / 2 - (canvasWidth * targetScale) / 2, viewSize.height / 2 - (canvasHeight * targetScale) / 2)
      ..scale(targetScale);

    _transformationController.value = newMatrix;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(canvasScaleProvider.notifier).state = targetScale;
      }
    });
  }

  void _programmaticZoom(double newScale, {Offset? focalPoint}) {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final targetScale = newScale.clamp(0.1, 4.0);

    if ((targetScale - currentScale).abs() < 0.001) return;

    final viewSize = context.size ?? const Size(1, 1);
    final sceneFocalPoint = focalPoint != null
        ? _transformationController.toScene(focalPoint)
        : _transformationController.toScene(Offset(viewSize.width / 2, viewSize.height / 2));

    final scaleChange = targetScale / currentScale;

    final newMatrix = Matrix4.identity()
      ..translate(sceneFocalPoint.dx, sceneFocalPoint.dy)
      ..scale(scaleChange)
      ..translate(-sceneFocalPoint.dx, -sceneFocalPoint.dy)
      ..multiply(_transformationController.value);

    _transformationController.value = newMatrix;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialFitPerformed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fitToScreen();
          _isInitialFitPerformed = true;
        }
      });
    }

    final tree = ref.watch(activeCanvasTreeProvider);
    final pointerMode = ref.watch(canvasPointerModeProvider);
    final currentScale = ref.watch(canvasScaleProvider);
    final isPanMode = pointerMode == CanvasPointerMode.pan;
    final isCtrlPressed = ref.watch(isCtrlPressedProvider);
    final activePageName = ref.watch(projectStateProvider.select((p) => p.activePage.name));

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.space) {
          if (event is KeyDownEvent) {
            ref.read(canvasPointerModeProvider.notifier).state = CanvasPointerMode.pan;
          } else if (event is KeyUpEvent) {
            ref.read(canvasPointerModeProvider.notifier).state = CanvasPointerMode.select;
          }
          return KeyEventResult.handled;
        }

        if (event.logicalKey == LogicalKeyboardKey.controlLeft || event.logicalKey == LogicalKeyboardKey.controlRight) {
          if (event is KeyDownEvent) {
            ref.read(isCtrlPressedProvider.notifier).state = true;
          } else if (event is KeyUpEvent) {
            ref.read(isCtrlPressedProvider.notifier).state = false;
          }
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          InteractiveViewer.builder(
            transformationController: _transformationController,
            panEnabled: isPanMode,
            scaleEnabled: isCtrlPressed,
            scaleFactor: 800,
            onInteractionEnd: (details) {
              final newScale = _transformationController.value.getMaxScaleOnAxis();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && (newScale - ref.read(canvasScaleProvider)).abs() > 0.001) {
                  ref.read(canvasScaleProvider.notifier).state = newScale;
                }
              });
            },
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 4.0,
            builder: (BuildContext context, viewport) {
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  WidgetRenderer(node: tree),
                  Positioned(
                    top: -32,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        activePageName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildFloatingControls(isPanMode, currentScale),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingControls(bool isPanMode, double currentScale) {
    return Card(
      elevation: 4.0,
      child: Row(
        children: [
          IconButton(
            icon: Icon(isPanMode ? Icons.pan_tool : Icons.mouse),
            tooltip: isPanMode ? 'Switch to Select Tool' : 'Switch to Pan Tool',
            isSelected: isPanMode,
            onPressed: () => ref.read(canvasPointerModeProvider.notifier).update((state) => state == CanvasPointerMode.pan ? CanvasPointerMode.select : CanvasPointerMode.pan),
          ),
          const SizedBox(height: 24, child: VerticalDivider()),
          IconButton(
            icon: const Icon(Icons.remove),
            tooltip: 'Zoom Out (Ctrl + Scroll)',
            onPressed: () => ref.read(canvasScaleProvider.notifier).update((scale) => (scale / 1.2).clamp(0.1, 4.0)),
          ),
          InkWell(
            onTap: () => ref.read(canvasScaleProvider.notifier).state = 0.0,
            borderRadius: BorderRadius.circular(4),
            child: Tooltip(
              message: 'Fit to Screen',
              child: SizedBox(
                width: 60,
                height: 48,
                child: Center(
                  child: Text(
                    '${(currentScale * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Zoom In (Ctrl + Scroll)',
            onPressed: () => ref.read(canvasScaleProvider.notifier).update((scale) => (scale * 1.2).clamp(0.1, 4.0)),
          ),
        ],
      ),
    );
  }
}
