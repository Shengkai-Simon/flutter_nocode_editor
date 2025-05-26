import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'layout/canvas_panel.dart';
import 'layout/left_panel.dart';
import 'layout/right_panel.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Row(
            children: [
              SizedBox(width: kLeftPanelWidth, child: LeftPanel()),
              Expanded(child: CanvasPanel()),
              SizedBox(width: kRightPanelWidth, child: RightPanel()),
            ],
          ),
        ),
      ),
    );
  }
}
