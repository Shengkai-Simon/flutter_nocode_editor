import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/app_constants.dart';
import 'ui/canvas/canvas_view.dart';
import 'ui/left/left_view.dart';
import 'ui/right/right_view.dart';

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
              SizedBox(width: kLeftPanelWidth, child: LeftView()),
              Expanded(child: CanvasView()),
              SizedBox(width: kRightPanelWidth, child: RightView()),
            ],
          ),
        ),
      ),
    );
  }
}
