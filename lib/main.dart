import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

import 'package:pet_owner_mobile/routes/router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

void main() {
  // runApp(const MyApp());

  runApp(DevicePreview(enabled: true, builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.mainColor),
        scaffoldBackgroundColor: Colors.white,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.darkPink,
          selectionHandleColor: AppColors.darkPink,
        ),
        fontFamily: 'Inter',
      ),
      routerConfig: appRouter,
    );
  }
}
