import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_screen.dart';
import '../../features/admin/presentation/administrateurs_screen.dart';
import '../../features/admin/presentation/tarifs_screen.dart';
import '../../features/commandes/presentation/commande_screen.dart';
import '../../features/commandes/presentation/liste_commandes_screen.dart';
import '../../features/commandes/presentation/panier_screen.dart';
import '../../features/commandes/presentation/reglages_commande_screen.dart';
import '../../features/admin/presentation/verification_commerce_screen.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/domain/role.dart';
import '../../features/auth/presentation/bienvenue_screen.dart';
import '../../features/auth/presentation/connexion_email_screen.dart';
import '../../features/commerce/presentation/catalogue_screen.dart';
import '../../features/commerce/presentation/fiche_commerce_screen.dart';
import '../../features/commerce/presentation/produit_screen.dart';
import '../../features/explorer/presentation/explorer_screen.dart';
import '../../features/explorer/presentation/fiche_publique_screen.dart';
import '../../features/favoris/favoris_screen.dart';
import '../../features/messages/presentation/conversation_screen.dart';
import '../../features/messages/presentation/messages_screen.dart';
import '../../features/legal/legal_screen.dart';
import '../../features/mon_espace/mon_espace_screen.dart';
import '../../features/profil/profil_screen.dart';
import '../../features/revenus/presentation/recapitulatif_screen.dart';
import '../../features/revenus/presentation/revenus_screen.dart';
import '../../shared/models/produit.dart';
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
      // Pages légales : toujours accessibles.
      if (lieu.startsWith('/legal')) return null;

      // Une fois connecté, on quitte les écrans de connexion.
      if (role != null && surBienvenue) {
        return role == Role.pro ? Routes.monEspace : Routes.explorer;
      }
      // Premier lancement : écran de bienvenue.
      if (role == null && !surBienvenue && !ref.read(bienvenueVueProvider)) {
        return Routes.bienvenue;
      }
      // L'espace pro est réservé aux professionnels.
      if ((lieu.startsWith('${Routes.monEspace}/commerce') ||
              lieu.startsWith(Routes.commandesPro)) &&
          role != Role.pro) {
        return Routes.monEspace;
      }
      // L'espace admin est réservé aux administrateurs.
      if (lieu.startsWith(Routes.admin) && role != Role.admin) {
        return Routes.explorer;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.cgu,
        builder: (context, state) => const LegalScreen(page: PageLegale.cgu),
      ),
      GoRoute(
        path: Routes.confidentialite,
        builder: (context, state) =>
            const LegalScreen(page: PageLegale.confidentialite),
      ),
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
          _branche(Routes.explorer, const ExplorerScreen(), [_routeFiche]),
          _branche(Routes.favoris, const FavorisScreen(), [_routeFiche]),
          _branche(Routes.messages, const MessagesScreen(), [
            GoRoute(
              path: ':id',
              builder: (context, state) => ConversationScreen(
                conversationId: state.pathParameters['id']!,
              ),
            ),
          ]),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.monEspace,
                builder: (context, state) => const MonEspaceScreen(),
                routes: _routesEspacePro,
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.admin,
                builder: (context, state) => const AdminScreen(),
                routes: [
                  GoRoute(
                    path: 'commerce/:id',
                    builder: (context, state) => VerificationCommerceScreen(
                      commerceId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'administrateurs',
                    builder: (context, state) => const AdministrateursScreen(),
                  ),
                  GoRoute(
                    path: 'tarifs',
                    builder: (context, state) => const TarifsScreen(),
                  ),
                  GoRoute(
                    path: 'revenus',
                    builder: (context, state) => const RevenusScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

StatefulShellBranch _branche(
  String chemin,
  Widget ecran, [
  List<RouteBase> sousRoutes = const [],
]) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: chemin,
      builder: (context, state) => ecran,
      routes: sousRoutes,
    ),
  ],
);

final _routeFiche = GoRoute(
  path: 'commerce/:id',
  builder: (context, state) =>
      FichePubliqueScreen(commerceId: state.pathParameters['id']!),
  routes: [
    GoRoute(
      path: 'panier',
      builder: (context, state) =>
          PanierScreen(commerceId: state.pathParameters['id']!),
    ),
  ],
);

final _routesEspacePro = [
  GoRoute(path: 'profil', builder: (context, state) => const ProfilScreen()),
  GoRoute(
    path: 'commandes',
    builder: (context, state) => const ListeCommandesScreen(pourPro: false),
    routes: [
      GoRoute(
        path: ':commandeId',
        builder: (context, state) =>
            CommandeScreen(commandeId: state.pathParameters['commandeId']!),
      ),
    ],
  ),
  GoRoute(
    path: 'commandes-pro',
    builder: (context, state) => const ListeCommandesScreen(pourPro: true),
    routes: [
      GoRoute(
        path: 'recapitulatif',
        builder: (context, state) => const RecapitulatifScreen(),
      ),
    ],
  ),
  GoRoute(
    path: 'commerce/nouveau',
    builder: (context, state) => const FicheCommerceScreen(),
  ),
  GoRoute(
    path: 'commerce/:id',
    builder: (context, state) =>
        FicheCommerceScreen(commerceId: state.pathParameters['id']),
    routes: [
      GoRoute(
        path: 'commande',
        builder: (context, state) =>
            ReglagesCommandeScreen(commerceId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: 'catalogue',
        builder: (context, state) =>
            CatalogueScreen(commerceId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'nouveau',
            builder: (context, state) =>
                ProduitScreen(commerceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: ':produitId',
            builder: (context, state) => ProduitParIdScreen(
              commerceId: state.pathParameters['id']!,
              produitId: state.pathParameters['produitId']!,
              produit: state.extra as Produit?,
            ),
          ),
        ],
      ),
    ],
  ),
];
