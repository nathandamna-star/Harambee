import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/connexion_requise.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../messagerie_providers.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMessages)),
      body: uid == null || ref.watch(roleProvider) == null
          ? ConnexionRequise(
              icone: Icons.chat_bubble_outline,
              texte: l10n.connexionRequiseMessages,
            )
          : ref
                .watch(mesConversationsProvider)
                .when(
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: l10n.chargement,
                    ),
                  ),
                  error: (_, _) => EtatVide(
                    icone: Icons.wifi_off,
                    titre: l10n.erreurReseau,
                    texte: '',
                  ),
                  data: (liste) => liste.isEmpty
                      ? EtatVide(
                          icone: Icons.chat_bubble_outline,
                          titre: l10n.messagesVideTitre,
                          texte: l10n.messagesVideTexte,
                        )
                      : ListView.separated(
                          itemCount: liste.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1, indent: 72),
                          itemBuilder: (context, i) {
                            final c = liste[i];
                            final nonLus = c.nonLusPour(uid);
                            final nom = c.interlocuteur(uid);
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  nom.isEmpty ? '?' : nom[0].toUpperCase(),
                                ),
                              ),
                              title: Text(
                                nom.isEmpty ? l10n.anonyme : nom,
                                style: nonLus > 0
                                    ? const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      )
                                    : null,
                              ),
                              subtitle: Text(
                                c.dernierMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (c.updatedAt != null)
                                    Text(
                                      _date(context, c.updatedAt!),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  if (nonLus > 0) ...[
                                    const SizedBox(height: 4),
                                    Badge(
                                      label: Text('$nonLus'),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ],
                                ],
                              ),
                              onTap: () =>
                                  context.push(Routes.conversation(c.id)),
                            );
                          },
                        ),
                ),
    );
  }

  static String _date(BuildContext context, DateTime d) {
    final langue = Localizations.localeOf(context).languageCode;
    final maintenant = DateTime.now();
    final memeJour =
        d.year == maintenant.year &&
        d.month == maintenant.month &&
        d.day == maintenant.day;
    return memeJour
        ? DateFormat.Hm(langue).format(d)
        : DateFormat.MMMd(langue).format(d);
  }
}
