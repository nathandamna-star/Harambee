import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences.dart';

/// Langue choisie dans l'app (null : celle du téléphone).
final langueAppProvider = NotifierProvider<LangueApp, String?>(LangueApp.new);

class LangueApp extends Notifier<String?> {
  static const _cle = 'langue';
  static const disponibles = ['fr', 'en', 'pt'];

  @override
  String? build() {
    final l = ref.watch(sharedPreferencesProvider).getString(_cle);
    return disponibles.contains(l) ? l : null;
  }

  Future<void> definir(String? langue) async {
    state = langue;
    final prefs = ref.read(sharedPreferencesProvider);
    if (langue == null) {
      await prefs.remove(_cle);
    } else {
      await prefs.setString(_cle, langue);
    }
  }
}
