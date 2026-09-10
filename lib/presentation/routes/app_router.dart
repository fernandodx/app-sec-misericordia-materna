import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../pages/admin/invites_management_page.dart';
import '../pages/admin/member_search_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/verify_email_page.dart';
import '../pages/home/home_dashboard_page.dart';
import '../pages/onboarding/institutional_page.dart';
import '../pages/onboarding/invite_landing_page.dart';
import '../pages/onboarding/member_form_page.dart';
import '../signals/auth_signal.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.login,
      refreshListenable: _SignalsListenable(),
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.verifyEmail,
          builder: (context, state) => const VerifyEmailPage(),
        ),
        GoRoute(
          path: AppRoutes.memberForm,
          builder: (context, state) => const MemberFormPage(),
        ),
        GoRoute(
          path: AppRoutes.institucional,
          builder: (context, state) => const InstitutionalPage(),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const HomeDashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.adminInvites,
          builder: (context, state) => const InvitesManagementPage(),
        ),
        GoRoute(
          path: AppRoutes.memberSearch,
          builder: (context, state) => const MemberSearchPage(),
        ),
        // Rota de convite: https://app.misericordiamaterna.org/convite?codigo=TOKEN_XYZ
        GoRoute(
          path: AppRoutes.convite,
          builder: (context, state) {
            final code = state.uri.queryParameters['codigo'];
            return InviteLandingPage(codigo: code);
          },
        ),
      ],
      redirect: (context, state) {
        final user = authSignal.currentUser.value;
        final loc = state.matchedLocation;

        // A página de convite trata seu próprio fluxo tanto para visitantes quanto para usuários logados
        if (loc.startsWith(AppRoutes.convite) || state.uri.path.startsWith(AppRoutes.convite)) {
          return null;
        }

        final isAuthRoute = loc == AppRoutes.login || loc == AppRoutes.register;

        // Não autenticado
        if (user == null) {
          return isAuthRoute ? null : AppRoutes.login;
        }

        // Se está na tela de login/registro mas já está logado
        if (isAuthRoute) {
          if (user.role.isVisitante) return AppRoutes.institucional;
          return AppRoutes.dashboard;
        }

        // Usuário logado que é visitante (sem convite)
        if (user.role.isVisitante && loc != AppRoutes.institucional) {
          return AppRoutes.institucional;
        }

        return null;
      },
    );
  }
}

class _SignalsListenable extends ChangeNotifier {
  _SignalsListenable() {
    authSignal.currentUser.subscribe((_) => notifyListeners());
    authSignal.activeInvite.subscribe((_) => notifyListeners());
  }
}
