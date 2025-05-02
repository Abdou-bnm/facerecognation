import 'package:go_router/go_router.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/signup_page.dart';
import 'screens/auth/forgot_password_page.dart';
import 'screens/auth/verify_email_page.dart';
import 'screens/home_page.dart';
import 'screens/auth/biometric_auth_page.dart'; // ✅ Add this line

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignUpPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => const VerifyEmailPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: '/biometric-auth', // ✅ NEW
        builder: (_, __) => const BiometricAuthPage(),
      ),
    ],
  );
}
