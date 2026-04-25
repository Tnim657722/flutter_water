import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/stock_screen.dart';
import '../screens/admin/order_list_screen.dart';
import '../screens/admin/create_order_screen.dart';
import '../screens/admin/order_detail_admin_screen.dart';
import '../screens/admin/customer_management_screen.dart';
import '../screens/customer/customer_shell.dart';
import '../screens/customer/customer_dashboard_screen.dart';
import '../screens/customer/my_orders_screen.dart';
import '../screens/customer/order_detail_customer_screen.dart';
import '../screens/customer/delivery_history_screen.dart';
import '../screens/customer/create_order_customer_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _adminShellKey = GlobalKey<NavigatorState>();
final _customerShellKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AppProvider provider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final user = provider.currentUser;
      final loc = state.matchedLocation;
      if (loc == '/splash' || loc == '/login') return null;
      if (user == null) return '/login';
      if (user.isAdmin && loc.startsWith('/customer')) return '/admin';
      if (!user.isAdmin && loc.startsWith('/admin')) return '/customer';
      return null;
    },
    refreshListenable: provider,
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => const LoginScreen(),
      ),

      // Admin Shell
      ShellRoute(
        navigatorKey: _adminShellKey,
        builder: (ctx, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (ctx, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/stock',
            builder: (ctx, state) => const StockScreen(),
          ),
          GoRoute(
            path: '/admin/orders',
            builder: (ctx, state) => const OrderListScreen(),
          ),

          GoRoute(
            path: '/admin/customers',
            builder: (ctx, state) => const CustomerManagementScreen(),
          ),
        ],
      ),

      // Customer Shell
      ShellRoute(
        navigatorKey: _customerShellKey,
        builder: (ctx, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(
            path: '/customer',
            builder: (ctx, state) => const CustomerDashboardScreen(),
          ),
          GoRoute(
            path: '/customer/orders',
            builder: (ctx, state) => const MyOrdersScreen(),
          ),

          GoRoute(
            path: '/customer/history',
            builder: (ctx, state) => const DeliveryHistoryScreen(),
          ),
        ],
      ),

      // Full-screen routes (moved out of ShellRoute to prevent go_router parentNavigatorKey assertion error)
      GoRoute(
        path: '/admin/orders/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => const CreateOrderScreen(),
      ),
      GoRoute(
        path: '/admin/orders/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => OrderDetailAdminScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/customer/orders/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => const CreateOrderCustomerScreen(),
      ),
      GoRoute(
        path: '/customer/orders/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => OrderDetailCustomerScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}
