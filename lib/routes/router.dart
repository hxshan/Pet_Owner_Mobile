import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';
import 'package:pet_owner_mobile/models/ecommerce/address_model.dart';
import 'package:pet_owner_mobile/models/vet/vet_model.dart';
import 'package:pet_owner_mobile/pages/adoption/adoption_dahboard_page.dart';
import 'package:pet_owner_mobile/pages/adoption/pet_details_page.dart';
import 'package:pet_owner_mobile/pages/ecommerce/CheckoutScreen.dart';
import 'package:pet_owner_mobile/pages/ecommerce/OrderSuccessScreen.dart';
import 'package:pet_owner_mobile/pages/ecommerce/add_edit_address_screen.dart';
import 'package:pet_owner_mobile/pages/ecommerce/addressed_screen.dart';
import 'package:pet_owner_mobile/pages/ecommerce/cart_page.dart';
import 'package:pet_owner_mobile/pages/ecommerce/ecommerce_dashboard_page.dart';
import 'package:pet_owner_mobile/pages/ecommerce/ecommerce_search_screen.dart';
import 'package:pet_owner_mobile/pages/ecommerce/ecommerce_search_view_screen.dart';
import 'package:pet_owner_mobile/pages/ecommerce/ecommerce_shell.dart';
import 'package:pet_owner_mobile/pages/ecommerce/order_details_screen.dart';
import 'package:pet_owner_mobile/pages/ecommerce/orders_history_screen.dart';
import 'package:pet_owner_mobile/pages/ecommerce/product_detail_page.dart';
import 'package:pet_owner_mobile/pages/ecommerce/vouchers_screen.dart';
import 'package:pet_owner_mobile/pages/ecommerce/wishlist_screen.dart';
import 'package:pet_owner_mobile/pages/notification_page.dart';
import 'package:pet_owner_mobile/pages/nutrition/meal_plan_details_page%20.dart';
import 'package:pet_owner_mobile/pages/nutrition/nutrition_plan_page.dart';
import 'package:pet_owner_mobile/pages/pet_management/add_pet_page.dart';
import 'package:pet_owner_mobile/pages/pet_management/chat_screen.dart';
import 'package:pet_owner_mobile/pages/pet_management/medical_reports_page.dart';
import 'package:pet_owner_mobile/pages/pet_management/my_pets_page.dart';
import 'package:pet_owner_mobile/pages/pet_management/pet_profile_page.dart';
import 'package:pet_owner_mobile/pages/pet_management/upcoming_appointments_page.dart';
import 'package:pet_owner_mobile/pages/pet_management/vaccinations_page.dart';
import 'package:pet_owner_mobile/pages/pet_management/view_all_pets_page.dart';
import 'package:pet_owner_mobile/pages/profile_page.dart';
import 'package:pet_owner_mobile/pages/signup/account_info_page.dart';
import 'package:pet_owner_mobile/pages/signup/animal_info_page.dart';
import 'package:pet_owner_mobile/pages/dashboard_page.dart';
import 'package:pet_owner_mobile/pages/get_started_page.dart';
import 'package:pet_owner_mobile/pages/login_page.dart';
import 'package:pet_owner_mobile/pages/signup/personal_info_page.dart';
import 'package:pet_owner_mobile/pages/splash_page.dart';
import 'package:pet_owner_mobile/pages/vet/my_vet_appointments_screen.dart';
import 'package:pet_owner_mobile/pages/vet/vet_booking_screen.dart';
import 'package:pet_owner_mobile/pages/vet/vet_details_screen.dart';
import 'package:pet_owner_mobile/pages/vet/vet_home_screen.dart';
import 'package:pet_owner_mobile/pages/vet/vet_search_result_screen.dart';
import 'package:pet_owner_mobile/pages/welcome_page.dart';
import 'package:pet_owner_mobile/widgets/navbar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _ecommerceNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  navigatorKey: _rootNavigatorKey,
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
      navigatorKey: _shellNavigatorKey,
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
          path: '/profile',
          name: 'ProfileScreen',
          builder: (context, state) => ProfileScreen(),
        ),
        GoRoute(
          path: '/notifications',
          name: 'NotificationsScreen',
          builder: (context, state) => NotificationsScreen(),
        ),

        // Pet management Routes
        GoRoute(
          path: '/my-pets',
          name: 'MyPetsScreen',
          builder: (context, state) => const MyPetsScreen(),
          routes: [
            GoRoute(
              path: '/addpet',
              name: 'AddPetScreen',
              builder: (context, state) => AddPetScreen(),
            ),
            GoRoute(
              path: '/petprofile/:petId',
              name: 'PetProfileScreen',
              builder: (context, state) {
                final petId = state.pathParameters['petId']!;
                return PetProfileScreen(petId: petId);
              },
            ),
            GoRoute(
              path: '/aichat',
              name: 'ChatScreen',
              builder: (context, state) => ChatScreen(),
            ),
            GoRoute(
              path: '/viewallpets',
              name: 'ViewAllPetsScreen',
              builder: (context, state) => ViewAllPetsScreen(),
            ),
            GoRoute(
              path: '/upcomingappointments',
              name: 'UpcomingAppointmentsScreen',
              builder: (context, state) => UpcomingAppointmentsScreen(),
            ),
            GoRoute(
              path: '/vaccinations',
              name: 'VaccinationsScreen',
              builder: (context, state) => VaccinationsScreen(),
            ),
            GoRoute(
              path: '/medicalrecords',
              name: 'MedicalReportsScreen',
              builder: (context, state) => MedicalReportsScreen(),
            ),
          ],
        ),

        // Adoption Routes
        GoRoute(
          path: '/adoption',
          name: 'PetListingDashboard',
          builder: (context, state) => const PetListingDashboard(),
          routes: [
            GoRoute(
              path: 'pet-detail',
              name: 'PetDetailsPage',
              builder: (context, state) {
                final pet = state.extra as AdoptionPet;
                return PetDetailsPage(pet: pet);
              },
            ),
          ],
        ),

        // Ecoommerce Routes
        ShellRoute(
          navigatorKey: _ecommerceNavigatorKey,
          builder: (context, state, child) => EcommerceShell(child: child),
          routes: [
            GoRoute(
              path: '/ecommerce',
              name: 'EcommerceDashboardScreen',
              builder: (context, state) => const EcommerceDashboardScreen(),
              routes: [
                GoRoute(
                  path: 'product-detail/:productId',
                  name: 'ProductDetailScreen',
                  builder: (context, state) {
                    final productId = state.pathParameters['productId'] ?? '';
                    return ProductDetailScreen(productId: productId);
                  },
                ),
                GoRoute(
                  name: 'EcommerceSearchViewScreen',
                  path: 'search-view',
                  builder: (context, state) {
                    final q = state.uri.queryParameters['q'] ?? '';
                    final cat = state.uri.queryParameters['category'] ?? 'All';
                    return EcommerceSearchViewScreen(
                      initialQuery: q,
                      initialCategory: cat,
                    );
                  },
                ),
                GoRoute(
                  name: 'EcommerceSearchResultsScreen',
                  path: 'search',
                  builder: (context, state) {
                    final q = state.uri.queryParameters['q'] ?? '';
                    final cat = state.uri.queryParameters['category'] ?? 'All';
                    return EcommerceSearchScreen(
                      initialQuery: q,
                      initialCategory: cat,
                    );
                  },
                ),
                GoRoute(
                  path: 'cart',
                  name: 'CartScreen',
                  builder: (context, state) => const CartScreen(),
                ),
                GoRoute(
                  path: 'orders',
                  name: 'OrderHistoryScreen',
                  builder: (context, state) => const OrdersHistoryScreen(),
                ),
                GoRoute(
                  path: 'addresses',
                  name: 'AddressesScreen',
                  builder: (context, state) => const AddressesScreen(),
                ),
                GoRoute(
                  name: 'AddAddressScreen',
                  path: '/addresses/add',
                  builder: (context, state) => const AddEditAddressScreen(),
                ),
                GoRoute(
                  name: 'EditAddressScreen',
                  path: '/addresses/edit',
                  builder: (context, state) {
                    final addr = state.extra as Address;
                    return AddEditAddressScreen(initial: addr);
                  },
                ),
                GoRoute(
                  path: 'wishlist',
                  name: 'WishlistScreen',
                  builder: (context, state) => const WishlistScreen(),
                ),
                GoRoute(
                  path: 'vouchers',
                  name: 'VouchersScreen',
                  builder: (context, state) => const VouchersScreen(),
                ),
                GoRoute(
                  name: 'CheckoutScreen',
                  path: 'checkout',
                  builder: (context, state) => const CheckoutScreen(),
                ),
                GoRoute(
                  name: 'OrderSuccessScreen',
                  path: 'order-success',
                  builder: (context, state) {
                    final orderId = state.extra as String;
                    return OrderSuccessScreen(orderId: orderId);
                  },
                ),
                GoRoute(
                  name: 'OrderDetailsScreen',
                  path: '/orders/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return OrderDetailsScreen(orderId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // Nutrition Routes
        GoRoute(
          path: '/nutrition',
          name: 'NutritionPlanScreen',
          builder: (context, state) => const NutritionPlanScreen(),
          routes: [
            GoRoute(
              path: 'details',
              name: 'NutritionPlanDetailsScreen',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return MealPlanDetailsScreen(
                  petName: extra['petName'] ?? '',
                  petBreed: extra['petBreed'] ?? '',
                );
              },
            ),
          ],
        ),

        // Vet Routes
        GoRoute(
          path: '/vet',
          name: 'VetHomeScreen',
          builder: (context, state) => const VetHomeScreen(),
          routes: [
            GoRoute(
              path: 'search',
              name: 'VetSearchResultScreen',
              builder: (context, state) {
                final location = (state.extra as String?) ?? '';

                return VetSearchResultsScreen(location: location);
              },
            ),
            GoRoute(
              path: 'vet-details',
              name: 'VetDetailsScreen',
              builder: (context, state) {
                final vet = state.extra as VetModel;

                return VetDetailScreen(vet: vet);
              },
            ),
            GoRoute(
              path: 'book',
              name: 'VetBookingScreen',
              builder: (context, state) {
                final vet = state.extra as VetModel;

                return VetBookingScreen(vet: vet);
              },
            ),
            GoRoute(
              path: 'my-appointments',
              name: 'MyVetAppointmentScreen',
              builder: (context, state) => MyVetAppointmentsScreen(),
            ),
          ],
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
    if (location.startsWith('/ecommerce')) return 1;
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
        context.goNamed('EcommerceDashboardScreen');
        break;
      case 2:
        context.goNamed('MyPetsScreen');
        break;
      case 3:
        context.goNamed('ProfileScreen');
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
