import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_screen.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/domain/role.dart';
import '../../features/auth/presentation/bienvenue_screen.dart';
import '../../features/auth/presentation/connexion_email_screen.dart';
import '../../features/explorer/explorer_screen.dart';
import '../../features/favoris/favoris_screen.dart';
import '../../features/messages/messages_screen.dart';
import '../../features/mon_espace/mon_espace_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../preferences/preferences.dart';
import 'routes.dart';

export 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Relance les redirections quand la connexion ou le rôle change.
  final rafraichir = ValueNotifier(0);
  ref.listen(roleProvider, (_, _) => rafraichir.value++);
  ref.listen(bienvenueVueProvider, (_, _) => rafraichir.value++);
  ref.onDispose(rafraichir.dispose);

  return GoRouter(
    initialLocation: Routes.explorer,
    refreshListenable: rafraichir,
    redirect: (context, state) {
      final role = ref.read(roleProvider);
      final lieu = state.matchedLocation;
      final surBienvenue = lieu.startsWith(Routes.bienvenue);

      // Une fois connecté, on quitte les écrans de connexion.
      if (role != null && surBienvenue) {
        return role == Role.pro ? Routes.monEspace : Routes.explorer;
      }
      // Premier lancement : écran de bienvenue.
      if (role == null && !surBienvenue && !ref.read(bienvenueVueProvider)) {
        return Routes.bienvenue;
      }
      // L'espace admin est réservé aux administrateurs.
      if (lieu.startsWith(Routes.admin) && role != Role.admin) {
        return Routes.explorer;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.bienvenue,
        builder: (context, state) => const BienvenueScreen(),
        routes: [
          GoRoute(
            path: 'email',
            builder: (context, state) => const ConnexionEmailScreen(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          _branche(Routes.explorer, const ExplorerScreen()),
          _branche(Routes.favoris, const FavorisScreen()),
          _branche(Routes.messages, const MessagesScreen()),
          _branche(Routes.monEspace, const MonEspaceScreen()),
          _branche(Routes.admin, const AdminScreen()),
        ],
      ),
    ],
  );
});

StatefulShellBranch _branche(String chemin, Widget ecran) =>
    StatefulShellBranch(
      routes: [GoRoute(path: chemin, builder: (context, state) => ecran)],
    );
