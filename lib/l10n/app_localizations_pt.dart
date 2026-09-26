// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Harambee';

  @override
  String get navExplorer => 'Explorar';

  @override
  String get navFavoris => 'Favoritos';

  @override
  String get navMessages => 'Mensagens';

  @override
  String get navMonEspace => 'Meu espaço';

  @override
  String get navAdmin => 'Admin';

  @override
  String get explorerVideTitre => 'Encontre um comércio perto de você';

  @override
  String get explorerVideTexte =>
      'Lojas, restaurantes, alojamentos e serviços africanos e cristãos na Europa, na África e nas Américas.';

  @override
  String get favorisVideTitre => 'Nenhum favorito por enquanto';

  @override
  String get favorisVideTexte =>
      'Toque no coração na página de um comércio para encontrá-lo aqui.';

  @override
  String get messagesVideTitre => 'Nenhuma conversa';

  @override
  String get messagesVideTexte =>
      'Suas conversas com os comércios aparecerão aqui.';

  @override
  String get monEspaceVideTitre => 'Seu espaço';

  @override
  String get monEspaceVideTexte =>
      'Entre para gerenciar seu perfil ou seu comércio.';

  @override
  String get adminVideTitre => 'Administração';

  @override
  String get adminVideTexte =>
      'Os comércios aguardando verificação e as denúncias aparecerão aqui.';

  @override
  String get labelAfricain => 'Africano';

  @override
  String get labelChretien => 'Cristão';

  @override
  String get badgeVerifie => 'Verificado';

  @override
  String get bientotDisponible => 'Em breve';
}
