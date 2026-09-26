import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/domain/role.dart';
import '../../features/messages/messagerie_providers.dart';
import '../../l10n/app_localizations.dart';

/// Squelette commun : barre de navigation en bas.
/// L'onglet Admin n'apparaît que pour les administrateurs.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final estAdmin = ref.watch(roleProvider) == Role.admin;
    final nonLus = ref.watch(totalNonLusProvider);
    Widget pastille(Icon icone) => Badge(
      isLabelVisible: nonLus > 0,
      label: Text(nonLus > 99 ? '99+' : '$nonLus'),
      child: icone,
    );

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.explore_outlined),
        selectedIcon: const Icon(Icons.explore),
        label: l10n.navExplorer,
      ),
      NavigationDestination(
        icon: const Icon(Icons.favorite_border),
        selectedIcon: const Icon(Icons.favorite),
        label: l10n.navFavoris,
      ),
      NavigationDestination(
        icon: pastille(const Icon(Icons.chat_bubble_outline)),
        selectedIcon: pastille(const Icon(Icons.chat_bubble)),
        label: l10n.navMessages,
        tooltip: nonLus > 0 ? l10n.messagesNonLus(nonLus) : null,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: l10n.navMonEspace,
      ),
      if (estAdmin)
        NavigationDestination(
          icon: const Icon(Icons.verified_user_outlined),
          selectedIcon: const Icon(Icons.verified_user),
          label: l10n.navAdmin,
        ),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex.clamp(
          0,
          destinations.length - 1,
        ),
        destinations: destinations,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
