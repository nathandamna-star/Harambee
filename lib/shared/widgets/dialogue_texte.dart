import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Demande un texte obligatoire (motif de refus, de signalement…).
/// Renvoie null si l'utilisateur annule.
Future<String?> demanderTexte(
  BuildContext context, {
  required String titre,
  required String libelle,
  String? aide,
}) => showDialog<String>(
  context: context,
  builder: (context) =>
      _DialogueTexte(titre: titre, libelle: libelle, aide: aide),
);

class _DialogueTexte extends StatefulWidget {
  const _DialogueTexte({required this.titre, required this.libelle, this.aide});

  final String titre;
  final String libelle;
  final String? aide;

  @override
  State<_DialogueTexte> createState() => _DialogueTexteState();
}

class _DialogueTexteState extends State<_DialogueTexte> {
  // Le contrôleur vit avec la fenêtre : il n'est libéré qu'après sa fermeture
  // complète (animation comprise).
  final _controleur = TextEditingController();
  final _formulaire = GlobalKey<FormState>();

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.titre),
      content: Form(
        key: _formulaire,
        child: TextFormField(
          controller: _controleur,
          autofocus: true,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            labelText: widget.libelle,
            helperText: widget.aide,
            helperMaxLines: 2,
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l10n.champObligatoire : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.annuler),
        ),
        FilledButton(
          onPressed: () {
            if (_formulaire.currentState!.validate()) {
              Navigator.pop(context, _controleur.text.trim());
            }
          },
          child: Text(l10n.valider),
        ),
      ],
    );
  }
}
