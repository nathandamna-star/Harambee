import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'libelles.dart';

/// Saisie des horaires : pour chaque jour, fermé ou une plage « 09:00-19:00 ».
class EditeurHoraires extends StatelessWidget {
  const EditeurHoraires({
    super.key,
    required this.horaires,
    required this.onChanged,
  });

  final Map<String, List<String>> horaires;
  final ValueChanged<Map<String, List<String>>> onChanged;

  static const plageParDefaut = '09:00-19:00';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (final (cle, nomJour) in l10n.jours)
          _LigneJour(
            nomJour: nomJour,
            plage: (horaires[cle]?.isNotEmpty ?? false)
                ? horaires[cle]!.first
                : null,
            onChanged: (plage) => onChanged({
              ...horaires,
              cle: plage == null ? <String>[] : [plage],
            }),
          ),
      ],
    );
  }
}

class _LigneJour extends StatelessWidget {
  const _LigneJour({
    required this.nomJour,
    required this.plage,
    required this.onChanged,
  });

  final String nomJour;
  final String? plage;
  final ValueChanged<String?> onChanged;

  Future<void> _choisir(BuildContext context, bool debut) async {
    final (d, f) = _decouper(plage ?? EditeurHoraires.plageParDefaut);
    final choisi = await showTimePicker(
      context: context,
      initialTime: debut ? d : f,
    );
    if (choisi == null) return;
    onChanged(
      debut
          ? '${_texte(choisi)}-${_texte(f)}'
          : '${_texte(d)}-${_texte(choisi)}',
    );
  }

  static (TimeOfDay, TimeOfDay) _decouper(String plage) {
    TimeOfDay lire(String t) {
      final [h, m] = t.split(':');
      return TimeOfDay(hour: int.parse(h), minute: int.parse(m));
    }

    final [d, f] = plage.split('-');
    return (lire(d), lire(f));
  }

  static String _texte(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ouvert = plage != null;
    final (debut, fin) = ouvert ? _decouper(plage!) : (null, null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 96, child: Text(nomJour)),
          Switch(
            value: ouvert,
            onChanged: (v) =>
                onChanged(v ? EditeurHoraires.plageParDefaut : null),
          ),
          const SizedBox(width: 8),
          if (ouvert) ...[
            TextButton(
              onPressed: () => _choisir(context, true),
              child: Text(_texte(debut!)),
            ),
            const Text('–'),
            TextButton(
              onPressed: () => _choisir(context, false),
              child: Text(_texte(fin!)),
            ),
          ] else
            Text(
              l10n.ferme,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
