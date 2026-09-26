import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Chargé dans `main()` puis fourni via un override.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences non initialisé'),
);

/// Vrai une fois l'écran de bienvenue passé (connecté ou non).
final bienvenueVueProvider = NotifierProvider<BienvenueVue, bool>(
  BienvenueVue.new,
);

class BienvenueVue extends Notifier<bool> {
  static const _cle = 'bienvenueVue';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_cle) ?? false;

  Future<void> marquer() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_cle, true);
  }
}
