import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

enum TypeLabel { africain, chretien }

/// Pastille « Africain » ou « Chrétien » affichée sur les commerces.
class LabelChip extends StatelessWidget {
  const LabelChip(this.type, {super.key});

  final TypeLabel type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (fond, texte, libelle) = switch (type) {
      TypeLabel.africain => (
        AppColors.labelAfricainFond,
        AppColors.labelAfricainTexte,
        l10n.labelAfricain,
      ),
      TypeLabel.chretien => (
        AppColors.labelChretienFond,
        AppColors.labelChretienTexte,
        l10n.labelChretien,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        libelle,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: texte, fontWeight: FontWeight.w600),
      ),
    );
  }
}
