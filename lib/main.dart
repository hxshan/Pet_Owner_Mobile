import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:pet_owner_mobile/routes/router.dart';
import 'package:pet_owner_mobile/services/pet_service.dart';
import 'package:pet_owner_mobile/services/push_service.dart';
import 'package:pet_owner_mobile/store/adoption_favorites_scope.dart';
import 'package:pet_owner_mobile/store/adoption_favorites_store.dart';
import 'package:pet_owner_mobile/store/pet_scope.dart';
import 'package:pet_owner_mobile/store/pet_store.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  // Silently init push notifications — failures must not block startup
  try {
    await PushService.instance.initSilent();
  } catch (_) {}
  // No permission prompt here
  // await PushService.instance.initSilent();

  // Load adoption favorites from local storage before the first frame
  await MyApp._favoritesStore.loadOnce();

  runApp(const MyApp());

  // runApp(DevicePreview(enabled: true, builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Single store instances — live for the lifetime of the app
  static final _petStore = PetStore(PetService());
  static final _favoritesStore = AdoptionFavoritesStore();

  @override
  Widget build(BuildContext context) {
    return AdoptionFavoritesScope(
      notifier: _favoritesStore,
      child: PetScope(
      notifier: _petStore,
      child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
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
      },
    ),   // ScreenUtilInit
      ),   // PetScope
    );   // AdoptionFavoritesScope
  }
}
