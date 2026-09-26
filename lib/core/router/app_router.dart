import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_screen.dart';
import '../../features/explorer/explorer_screen.dart';
import '../../features/favoris/favoris_screen.dart';
import '../../features/messages/messages_screen.dart';
import '../../features/mon_espace/mon_espace_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../auth/role.dart';

abstract final class Routes {
  static const explorer = '/explorer';
  static const favoris = '/favoris';
  static const messages = '/messages';
  static const monEspace = '/mon-espace';
  static const admin = '/admin';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.explorer,
    redirect: (context, state) {
      // L'espace admin est réservé aux administrateurs.
      final versAdmin = state.matchedLocation.startsWith(Routes.admin);
      if (versAdmin && ref.read(roleProvider) != Role.admin) {
        return Routes.explorer;
      }
      return null;
    },
    routes: [
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
