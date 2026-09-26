import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'features/auth/auth_providers.dart';
import 'features/notifications/notifications_providers.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class HarambeeApp extends ConsumerStatefulWidget {
  const HarambeeApp({super.key});

  @override
  ConsumerState<HarambeeApp> createState() => _HarambeeAppState();
}

class _HarambeeAppState extends ConsumerState<HarambeeApp> {
  @override
  void initState() {
    super.initState();
    // Toucher une notification ouvre la conversation ou la commande concernée.
    ref.read(notificationsServiceProvider).notificationsTouchees.listen((d) {
      final router = ref.read(routerProvider);
      if (d['conversationId'] is String) {
        router.go(Routes.conversation(d['conversationId'] as String));
      } else if (d['commandeId'] is String) {
        router.go(Routes.commande(d['commandeId'] as String));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Notifications activées pour chaque utilisateur qui se connecte.
    ref.listen(utilisateurFirebaseProvider.select((u) => u.value?.uid), (
      avant,
      uid,
    ) {
      if (uid != null && uid != avant) {
        ref.read(notificationsServiceProvider).activer(uid);
      }
    });

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clair,
      darkTheme: AppTheme.sombre,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Français par défaut si la langue du téléphone n'est pas prise en charge.
      localeResolutionCallback: (locale, supportees) {
        for (final l in supportees) {
          if (l.languageCode == locale?.languageCode) return l;
        }
        return const Locale('fr');
      },
    );
  }
}
