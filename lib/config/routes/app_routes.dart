import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/data/models/notification_preferences_model.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/inventory/presentation/bloc/inventory_bloc.dart';
import '../../features/inventory/presentation/screens/stock_history_screen.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../features/notifications/presentation/screens/notification_preferences_screen.dart';
import '../../features/products/data/models/category_model.dart';
import '../../features/products/data/models/product_model.dart';
import '../../features/products/presentation/bloc/category_bloc.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';
import '../../features/products/presentation/screens/category_form_screen.dart';
import '../../features/products/presentation/screens/category_list_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

abstract class AppRoutes {
  static final goRouter = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register.name,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        name: RouteNames.home.name,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              DashboardBloc()..add(const DashboardSummaryRequested()),
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/products',
        name: RouteNames.products.name,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => ProductBloc()..add(const ProductListRequested()),
            ),
            BlocProvider(
              create: (_) => CategoryBloc()..add(const CategoryListRequested()),
            ),
          ],
          child: const ProductListScreen(),
        ),
      ),
      GoRoute(
        path: '/products/detail',
        name: RouteNames.productDetail.name,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => InventoryBloc()),
            BlocProvider(create: (_) => CategoryBloc()),
          ],
          child: ProductDetailScreen(product: state.extra! as ProductModel),
        ),
      ),
      GoRoute(
        path: '/products/form',
        name: RouteNames.productForm.name,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ProductBloc()),
            BlocProvider(create: (_) => CategoryBloc()),
          ],
          child: ProductFormScreen(product: state.extra as ProductModel?),
        ),
      ),
      GoRoute(
        path: '/products/history',
        name: RouteNames.productHistory.name,
        builder: (context, state) => BlocProvider(
          create: (_) => InventoryBloc(),
          child: StockHistoryScreen(product: state.extra! as ProductModel),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: RouteNames.settings.name,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: RouteNames.profile.name,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: RouteNames.notifications.name,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              NotificationBloc()..add(const NotificationListRequested()),
          child: const NotificationCenterScreen(),
        ),
      ),
      GoRoute(
        path: '/notifications/preferences',
        name: RouteNames.notificationPreferences.name,
        builder: (context, state) => BlocProvider(
          create: (_) => NotificationBloc(),
          child: NotificationPreferencesScreen(
            initialPreferences:
                context.read<AuthBloc>().state.user?.notificationPreferences ??
                const NotificationPreferencesModel(),
          ),
        ),
      ),
      GoRoute(
        path: '/categories',
        name: RouteNames.categories.name,
        builder: (context, state) => BlocProvider(
          create: (_) => CategoryBloc()..add(const CategoryListRequested()),
          child: const CategoryListScreen(),
        ),
      ),
      GoRoute(
        path: '/categories/form',
        name: RouteNames.categoryForm.name,
        builder: (context, state) => BlocProvider(
          create: (_) => CategoryBloc()..add(const CategoryListRequested()),
          child: CategoryFormScreen(category: state.extra as CategoryModel?),
        ),
      ),
    ],
  );
}

enum RouteNames {
  splash,
  login,
  register,
  forgotPassword,
  home,
  products,
  productDetail,
  productForm,
  productHistory,
  settings,
  profile,
  notifications,
  notificationPreferences,
  categories,
  categoryForm,
}
