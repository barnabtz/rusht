import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/product_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/bookings/bookings_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/bookings/booking_detail_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final isInitialized = authProvider.isInitialized;
      final isAuthRoute = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/register';

      // Show loading screen while initializing auth state
      if (!isInitialized) {
        return null;
      }

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _calculateSelectedIndex(state),
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/bookings');
                    break;
                  case 2:
                    context.go('/profile');
                    break;
                  case 3:
                    context.go('/notifications');
                    break;
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Bookings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(Icons.notifications),
                  label: 'Notifications',
                ),
              ],
            ),
          );
        },
        routes: [
          // Home Route
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'product/:id',
                builder: (context, state) {
                  final product = state.extra as Map<String, dynamic>;
                  return ProductDetailScreen(product: product['product']);
                },
              ),
            ],
          ),

          // Bookings Route
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final bookingId = state.pathParameters['id'];
                  return BookingDetailScreen(bookingId: bookingId!);
                },
              ),
            ],
          ),

          // Profile Route
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // Notifications Route
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),

          // Chat Route
          GoRoute(
            path: '/chat/:id',
            builder: (context, state) {
              final bookingId = state.pathParameters['id'];
              return ChatScreen(bookingId: bookingId!);
            },
          ),
        ],
      ),
    ],
  );

  static int _calculateSelectedIndex(GoRouterState state) {
    final String location = state.matchedLocation;
    if (location.startsWith('/')) {
      if (location == '/') return 0;
      if (location.startsWith('/bookings')) return 1;
      if (location.startsWith('/profile')) return 2;
      if (location.startsWith('/notifications')) return 3;
    }
    return 0;
  }
}