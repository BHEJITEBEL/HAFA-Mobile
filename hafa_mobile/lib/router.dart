import 'package:go_router/go_router.dart';

import 'screens/admin_dashboard_screen.dart';
import 'screens/artisan_dashboard_screen.dart';
import 'screens/blockchain_screen.dart';
import 'screens/cybersecurity_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/heritage_map_screen.dart';
import 'screens/heritage_passport_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/nfc_verify_screen.dart';
import 'screens/passport_list_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_registration_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/register_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/verification_result_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';

const _publicRoutes = {'/', '/splash', '/welcome', '/login', '/register', '/role-selection'};

GoRouter buildRouter(AppState app) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: app,
    redirect: (context, state) {
      final path = state.uri.path;
      if (_publicRoutes.contains(path)) return null;
      // Halaman utama memerlukan log masuk (atau mod tetamu)
      if (!app.isAuthenticated) return '/welcome';
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/splash'),

      // --- Onboarding (tiada navigasi bawah) ---
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/role-selection',
        builder: (_, state) => RoleSelectionScreen(isGuest: state.uri.queryParameters['guest'] == 'true'),
      ),

      // Kamera penuh skrin (menyelubungi navigasi bawah). Memulangkan teks QR melalui pop().
      GoRoute(path: '/scan', builder: (_, __) => const QrScanScreen()),

      // --- Aplikasi utama (dengan navigasi bawah) ---
      ShellRoute(
        builder: (context, state, child) => MainShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
          GoRoute(
            path: '/product/:id',
            builder: (_, state) => ProductDetailScreen(productKey: state.pathParameters['id']!),
          ),
          GoRoute(path: '/passport', builder: (_, __) => const PassportListScreen()),
          GoRoute(
            path: '/heritage-passport/:id',
            builder: (_, state) => HeritagePassportScreen(productKey: state.pathParameters['id']!),
          ),
          GoRoute(path: '/verify', builder: (_, __) => const VerifyScreen()),
          GoRoute(
            path: '/qr-verify/:id',
            builder: (_, state) => VerificationResultScreen(
              productKey: state.pathParameters['id']!,
              method: state.uri.queryParameters['m'],
            ),
          ),
          GoRoute(path: '/nfc-verify', builder: (_, __) => const NfcVerifyScreen()),
          GoRoute(
            path: '/blockchain/:id',
            builder: (_, state) => BlockchainScreen(productKey: state.pathParameters['id']!),
          ),
          GoRoute(path: '/map', builder: (_, __) => const HeritageMapScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/artisan-dashboard', builder: (_, __) => const ArtisanDashboardScreen()),
          GoRoute(path: '/register-product', builder: (_, __) => const ProductRegistrationScreen()),
          GoRoute(path: '/admin-dashboard', builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(path: '/cybersecurity', builder: (_, __) => const CybersecurityScreen()),
        ],
      ),
    ],
  );
}
