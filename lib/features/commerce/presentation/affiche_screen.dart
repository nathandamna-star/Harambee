import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/config/liens.dart';
import '../../../core/partage/partage.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/commerce.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../commerce_providers.dart';
import 'libelles.dart';

/// Affiche à imprimer (vitrine, caisse) avec le QR code du commerce, et
/// partage du lien vers sa page.
class AfficheScreen extends ConsumerStatefulWidget {
  const AfficheScreen({super.key, required this.commerceId});

  final String commerceId;

  @override
  ConsumerState<AfficheScreen> createState() => _AfficheScreenState();
}

class _AfficheScreenState extends ConsumerState<AfficheScreen> {
  final _cleAffiche = GlobalKey();
  var _enCours = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final commerce = ref.watch(commerceProvider(widget.commerceId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.afficheTitre)),
      body: switch (commerce) {
        AsyncData(value: final c?) when c.statut == StatutCommerce.publie =>
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.afficheAide),
              const SizedBox(height: 16),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: RepaintBoundary(
                    key: _cleAffiche,
                    child: _Affiche(commerce: c),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _enCours ? null : () => _partagerAffiche(c),
                icon: const Icon(Icons.print_outlined),
                label: Text(l10n.afficheImprimer),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (bouton) => OutlinedButton.icon(
                  onPressed: () => ref
                      .read(partageProvider)
                      .partagerTexte(
                        l10n.partagerCommerceTexte(c.nom, lienCommerce(c.id)),
                        sujet: c.nom,
                        origine: zoneDe(bouton),
                      ),
                  icon: const Icon(Icons.link),
                  label: Text(l10n.partagerLien),
                ),
              ),
            ],
          ),
        AsyncData() => EtatVide(
          icone: Icons.qr_code_2,
          titre: l10n.afficheTitre,
          texte: l10n.afficheIndisponible,
        ),
        AsyncError() => Center(child: Text(l10n.erreurInconnue)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Future<void> _partagerAffiche(Commerce commerce) async {
    final l10n = AppLocalizations.of(context);
    final origine = zoneDe(context);
    setState(() => _enCours = true);
    try {
      final boundary =
          _cleAffiche.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      // Haute résolution pour une impression nette (A4).
      final image = await boundary.toImage(pixelRatio: 4);
      final donnees = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      await ref
          .read(partageProvider)
          .partagerImage(
            donnees!.buffer.asUint8List(),
            nom: 'affiche-harambee.png',
            texte: l10n.partagerCommerceTexte(
              commerce.nom,
              lienCommerce(commerce.id),
            ),
            origine: origine,
          );
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }
}

/// L'affiche elle-même (format A4, couleurs fixes pour l'impression).
class _Affiche extends StatelessWidget {
  const _Affiche({required this.commerce});

  final Commerce commerce;

  static const _fond = Color(0xFFFFFDF8);
  static const _texte = Color(0xFF1E1B16);
  static const _second = Color(0xFF5E574C);
  static const _accent = Color(0xFFB4451F);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final styles = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: 1 / 1.414,
      child: Container(
        color: _fond,
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        child: Column(
          children: [
            Text(
              'Harambee',
              style: styles.headlineMedium?.copyWith(
                color: _accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.afficheAppel,
              textAlign: TextAlign.center,
              style: styles.titleMedium?.copyWith(color: _second),
            ),
            const Spacer(),
            Text(
              commerce.nom,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: styles.headlineSmall?.copyWith(
                color: _texte,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.categorie(commerce.categorie)} · ${commerce.ville}',
              style: styles.bodyMedium?.copyWith(color: _second),
            ),
            const SizedBox(height: 20),
            Flexible(
              flex: 6,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _accent, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: lienCommerce(commerce.id),
                    semanticsLabel: lienCommerce(commerce.id),
                    padding: EdgeInsets.zero,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: _texte,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: _texte,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.afficheScanner,
              textAlign: TextAlign.center,
              style: styles.titleSmall?.copyWith(color: _texte),
            ),
            const Spacer(),
            Text(
              l10n.bienvenueSousTitre,
              textAlign: TextAlign.center,
              style: styles.bodySmall?.copyWith(color: _second),
            ),
          ],
        ),
      ),
    );
  }
}
