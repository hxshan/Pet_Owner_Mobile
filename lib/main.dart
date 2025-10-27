import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/routes/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: Colors.white,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color.fromRGBO(0, 104, 55, 1),
          selectionHandleColor: Color.fromRGBO(0, 104, 55, 1),
        ),
        fontFamily: 'Inter',
      ),
      routerConfig: appRouter,
    );
  }
}
