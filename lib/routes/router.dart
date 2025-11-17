import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/pages/account_info_page.dart';
import 'package:pet_owner_mobile/pages/animal_info_page.dart';
import 'package:pet_owner_mobile/pages/get_started_page.dart';
import 'package:pet_owner_mobile/pages/personal_info_page.dart';
import 'package:pet_owner_mobile/pages/splash_page.dart';
import 'package:pet_owner_mobile/pages/welcome_page.dart';
import 'package:pet_owner_mobile/widgets/navbar.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
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
      path: '/animalinfo',
      name: 'AnimalInfoPage',
      builder: (context, state) => const AnimalInfoPage(),
    ),

    // Pages with NavBar
    ShellRoute(
      builder: (context, state, child) => NavBarShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const SplashScreen(),
        ),
        // GoRoute(
        //   path: '/search',
        //   name: 'search',
        //   builder: (context, state) => const SearchPage(),
        // ),
        // GoRoute(
        //   path: '/profile',
        //   name: 'profile',
        //   builder: (context, state) => const ProfilePage(),
        // ),
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
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.goNamed('home');
        break;
      case 1:
        context.goNamed('search');
        break;
      case 2:
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
