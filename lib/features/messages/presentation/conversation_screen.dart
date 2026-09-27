import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/conversation.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/signalement.dart';
import '../../../shared/widgets/dialogue_texte.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../../commerce/commerce_providers.dart';
import '../../commerce/presentation/grille_photos.dart';
import '../../explorer/explorer_providers.dart';
import '../messagerie_providers.dart';

/// Une conversation en temps réel entre un client et un commerce.
class ConversationScreen extends ConsumerWidget {
  const ConversationScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final conversation = ref.watch(conversationProvider(conversationId));

    return conversation.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
        ),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: EtatVide(
          icone: Icons.chat_bubble_outline,
          titre: l10n.conversationIntrouvable,
          texte: '',
        ),
      ),
      data: (c) => c == null || uid == null
          ? Scaffold(
              appBar: AppBar(),
              body: EtatVide(
                icone: Icons.chat_bubble_outline,
                titre: l10n.conversationIntrouvable,
                texte: '',
              ),
            )
          : _Conversation(conversation: c, uid: uid),
    );
  }
}

class _Conversation extends ConsumerStatefulWidget {
  const _Conversation({required this.conversation, required this.uid});

  final Conversation conversation;
  final String uid;

  @override
  ConsumerState<_Conversation> createState() => _ConversationState();
}

class _ConversationState extends ConsumerState<_Conversation> {
  final _texte = TextEditingController();
  bool _envoiEnCours = false;

  Conversation get c => widget.conversation;

  @override
  void initState() {
    super.initState();
    _marquerLue();
  }

  @override
  void didUpdateWidget(covariant _Conversation ancien) {
    super.didUpdateWidget(ancien);
    // Nouveau message reçu pendant que la conversation est ouverte.
    _marquerLue();
  }

  void _marquerLue() => ref
      .read(messagerieRepositoryProvider)
      .marquerLue(c, widget.uid)
      .catchError((_) {});

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  Future<void> _envoyer({Uint8List? photo}) async {
    final l10n = AppLocalizations.of(context);
    final texte = photo == null ? _texte.text : '';
    if (texte.trim().isEmpty && photo == null) return;
    setState(() => _envoiEnCours = true);
    try {
      await ref
          .read(messagerieRepositoryProvider)
          .envoyer(
            c,
            auteur: widget.uid,
            texte: texte,
            photo: photo,
            apercuPhoto: l10n.apercuPhoto,
          );
      if (photo == null) _texte.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.erreurEnvoiMessage)));
      }
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  Future<void> _envoyerPhoto() async {
    final camera = await choisirSourcePhoto(
      context,
      AppLocalizations.of(context),
    );
    if (camera == null) return;
    final octets = await ref
        .read(selecteurPhotoProvider)
        .choisir(camera: camera);
    if (octets != null) await _envoyer(photo: octets);
  }

  Future<void> _basculerBlocage(bool bloqueParMoi) async {
    final l10n = AppLocalizations.of(context);
    if (!bloqueParMoi) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.bloquerTitre),
          content: Text(l10n.bloquerTexte),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.annuler),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.bloquer),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await ref
        .read(messagerieRepositoryProvider)
        .definirBlocage(c.id, widget.uid, !bloqueParMoi);
  }

  Future<void> _signaler(Message m) async {
    final l10n = AppLocalizations.of(context);
    final motif = await demanderTexte(
      context,
      titre: l10n.signaler,
      libelle: l10n.motif,
      aide: l10n.signalerAide,
    );
    if (motif == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(explorerRepositoryProvider)
        .signaler(
          Signalement(
            auteur: widget.uid,
            cible: CibleSignalement.message,
            cibleId: 'conversations/${c.id}/messages/${m.id}',
            motif: motif,
          ),
        );
    messenger.showSnackBar(SnackBar(content: Text(l10n.signalementEnvoye)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final messages = ref.watch(messagesProvider(c.id));
    final nom = c.interlocuteur(widget.uid);

    final bloqueParMoi = c.bloquePar.contains(widget.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(nom.isEmpty ? l10n.anonyme : nom),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.actions,
            onSelected: (_) => _basculerBlocage(bloqueParMoi),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'bloquer',
                child: Text(bloqueParMoi ? l10n.debloquer : l10n.bloquer),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messages.when(
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
                        icone: Icons.waving_hand_outlined,
                        titre: l10n.premierMessageTitre,
                        texte: l10n.premierMessageTexte,
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(12),
                        itemCount: liste.length,
                        itemBuilder: (context, i) {
                          final m = liste[liste.length - 1 - i];
                          return _Bulle(
                            message: m,
                            deMoi: m.auteur == widget.uid,
                            onSignaler: () => _signaler(m),
                          );
                        },
                      ),
              ),
            ),
            const Divider(height: 1),
            if (c.bloquee)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  bloqueParMoi
                      ? l10n.vousAvezBloque
                      : l10n.conversationIndisponible,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l10n.envoyerPhoto,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      onPressed: _envoiEnCours ? null : _envoyerPhoto,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _texte,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: 5000,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: l10n.ecrireMessage,
                          counterText: '',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton.filled(
                      tooltip: l10n.envoyer,
                      icon: _envoiEnCours
                          ? SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                                semanticsLabel: l10n.chargement,
                              ),
                            )
                          : const Icon(Icons.send),
                      onPressed: _envoiEnCours ? null : () => _envoyer(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bulle extends StatelessWidget {
  const _Bulle({
    required this.message,
    required this.deMoi,
    required this.onSignaler,
  });

  final Message message;
  final bool deMoi;
  final VoidCallback onSignaler;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final langue = Localizations.localeOf(context).languageCode;
    final fond = deMoi
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerLowest;
    final texte = deMoi
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Align(
      alignment: deMoi ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: deMoi ? null : onSignaler,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: fond,
            borderRadius: BorderRadius.circular(16),
            border: deMoi ? null : Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.photoUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      message.photoUrl!,
                      width: 220,
                      fit: BoxFit.cover,
                      cacheWidth: 660,
                      semanticLabel: l10n.photoEnvoyee,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              if (message.texte.isNotEmpty)
                Text(message.texte, style: TextStyle(color: texte)),
              if (message.createdAt != null)
                Text(
                  DateFormat.Hm(langue).format(message.createdAt!),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: texte.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
