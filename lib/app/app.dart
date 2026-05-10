import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import 'router.dart';

class ColorinApp extends StatelessWidget {
  const ColorinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Colorin',
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
