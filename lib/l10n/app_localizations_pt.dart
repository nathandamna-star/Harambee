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

  @override
  String get bienvenueTitre => 'Bem-vindo ao Harambee';

  @override
  String get bienvenueSousTitre =>
      'Comércios africanos e cristãos perto de você e onde quer que você vá.';

  @override
  String get choixClient => 'Procuro um comércio';

  @override
  String get choixClientDetail => 'Encontrar, contatar, encomendar';

  @override
  String get choixPro => 'Tenho um comércio';

  @override
  String get choixProDetail => 'Apresentar meu comércio e meus produtos';

  @override
  String get continuerGoogle => 'Continuar com Google';

  @override
  String get continuerApple => 'Continuar com Apple';

  @override
  String get continuerEmail => 'Continuar com e-mail';

  @override
  String get explorerSansCompte => 'Explorar sem conta';

  @override
  String get seConnecter => 'Entrar';

  @override
  String get creerCompte => 'Criar conta';

  @override
  String get champNom => 'Nome';

  @override
  String get champEmail => 'Endereço de e-mail';

  @override
  String get champMotDePasse => 'Senha';

  @override
  String get afficherMotDePasse => 'Mostrar senha';

  @override
  String get masquerMotDePasse => 'Ocultar senha';

  @override
  String get motDePasseOublie => 'Esqueceu a senha?';

  @override
  String emailReinitialisationEnvoye(String email) {
    return 'Um e-mail para escolher uma nova senha foi enviado para $email.';
  }

  @override
  String get validationNomRequis => 'Informe seu nome.';

  @override
  String get validationEmail => 'Informe um e-mail válido.';

  @override
  String get validationMotDePasse => 'Pelo menos 8 caracteres.';

  @override
  String get erreurEmailInvalide => 'Este endereço de e-mail não é válido.';

  @override
  String get erreurMotDePasseFaible =>
      'Esta senha é muito fraca. Use pelo menos 8 caracteres.';

  @override
  String get erreurEmailDejaUtilise =>
      'Já existe uma conta com este e-mail. Entre em vez disso.';

  @override
  String get erreurIdentifiantsIncorrects => 'E-mail ou senha incorretos.';

  @override
  String get erreurTropDeTentatives =>
      'Muitas tentativas. Tente novamente em alguns minutos.';

  @override
  String get erreurReseau =>
      'Sem conexão com a internet. Verifique sua rede e tente novamente.';

  @override
  String get erreurInconnue => 'Ocorreu um erro. Tente novamente.';

  @override
  String get connexionRequiseTitre => 'Entre na sua conta';

  @override
  String get connexionRequiseFavoris =>
      'Crie uma conta ou entre para salvar seus comércios favoritos.';

  @override
  String get connexionRequiseMessages =>
      'Entre para conversar com os comércios.';

  @override
  String get seDeconnecter => 'Sair';

  @override
  String get roleClient => 'Cliente';

  @override
  String get rolePro => 'Profissional';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String monEspaceBonjour(String nom) {
    return 'Olá $nom';
  }

  @override
  String get monEspaceProBientot =>
      'Em breve você poderá criar a página do seu comércio aqui.';

  @override
  String get chargement => 'Carregando';
}
