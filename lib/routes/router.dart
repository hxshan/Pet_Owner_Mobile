import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/pages/pet_management/add_pet_page.dart';
import 'package:pet_owner_mobile/pages/pet_management/my_pets_page.dart';
import 'package:pet_owner_mobile/pages/pet_management/pet_profile_page.dart';
import 'package:pet_owner_mobile/pages/signup/account_info_page.dart';
import 'package:pet_owner_mobile/pages/signup/animal_info_page.dart';
import 'package:pet_owner_mobile/pages/dashboard_page.dart';
import 'package:pet_owner_mobile/pages/get_started_page.dart';
import 'package:pet_owner_mobile/pages/login_page.dart';
import 'package:pet_owner_mobile/pages/signup/personal_info_page.dart';
import 'package:pet_owner_mobile/pages/splash_page.dart';
import 'package:pet_owner_mobile/pages/welcome_page.dart';
import 'package:pet_owner_mobile/widgets/navbar.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  debugLogDiagnostics: true,
  routes: [
    // Pages without NavBar
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      name: 'WelcomePage',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/getstarted',
      name: 'GetStartedPage',
      builder: (context, state) => const GetStartedPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'PersonalInfoPage',
      builder: (context, state) => const PersonalInfoPage(),
    ),
    GoRoute(
      path: '/accountinfo',
      name: 'AccountInfoPage',
      builder: (context, state) => const AccountInfoPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'LoginPage',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/animalinfo',
      name: 'AnimalInfoPage',
      builder: (context, state) => const AnimalInfoPage(),
    ),

    // Pages with NavBar
    ShellRoute(
      builder: (context, state, child) => NavBarShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'DashboardScreen',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/shop',
          name: 'shop',
          builder: (context, state) => const PlaceholderPage(title: 'Shop'),
        ),
        GoRoute(
          path: '/my-pets',
          name: 'my-pets',
          builder: (context, state) => const MyPetsScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const PlaceholderPage(title: 'Profile'),
        ),

        GoRoute(
          path: '/addpet',
          name: 'AddPetScreen',
          builder: (context, state) => AddPetScreen(),
        ),
        GoRoute(
          path: '/petprofile',
          name: 'PetProfileScreen',
          builder: (context, state) => PetProfileScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
);

// NavBar Shell
class NavBarShell extends StatefulWidget {
  final Widget child;
  const NavBarShell({super.key, required this.child});

  @override
  State<NavBarShell> createState() => _NavBarShellState();
}

class _NavBarShellState extends State<NavBarShell> {
  int _calculateSelectedIndex() {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/shop')) return 1;
    if (location.startsWith('/my-pets')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.goNamed('DashboardScreen');
        break;
      case 1:
        context.goNamed('shop');
        break;
      case 2:
        context.goNamed('my-pets');
        break;
      case 3:
        context.goNamed('profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBarComponent(
        currentIndex: _calculateSelectedIndex(),
        onTap: _onItemTapped,
      ),
    );
  }
}

// Placeholder page for unimplemented screens
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title Page',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
