# CLAUDE.md — Projet Harambee

> Ce fichier décrit l'application à construire. Lis-le en entier avant de commencer.
> Le porteur du projet n'est pas développeur : explique chaque étape simplement, en français,
> et dis-lui exactement quoi faire quand une action de sa part est nécessaire
> (créer un compte, copier une clé, installer un outil).

## 1. Le projet

Harambee (nom provisoire) est une application mobile qui répertorie les **magasins, restaurants,
logements et services africains et chrétiens**, et relie **clients et professionnels** entre
l'**Europe, l'Afrique et l'Amérique**.

- **Clients** : trouver un commerce près d'eux ou dans une ville qu'ils visitent, le contacter, laisser un avis.
- **Professionnels** : s'inscrire, créer la fiche de leur commerce, publier et mettre à jour leurs produits, répondre aux clients.
- **Administrateur** : vérifier chaque commerce et attribuer les labels avant publication, modérer.

Un prototype web existe déjà ; cette application est la version mobile réelle, publiable sur
l'App Store et Google Play.

## 2. Choix techniques (imposés)

| Sujet | Choix |
|---|---|
| Application | **Flutter** (une base de code iOS + Android), Dart, null safety |
| Gestion d'état | Riverpod |
| Navigation | go_router |
| Back-end | **Firebase** : Authentication, Cloud Firestore, Storage, Cloud Messaging (notifications), Cloud Functions si nécessaire |
| Région des données | Europe (ex. `europe-west1`) pour le RGPD |
| Carte | `google_maps_flutter` + géolocalisation (`geolocator`) |
| Langues | Français (par défaut), anglais, portugais via `flutter_localizations` + fichiers ARB. Aucun texte en dur dans le code |
| Devises | Prix stockés avec leur devise (EUR, USD, CAD, XOF, XAF, NGN, GHS, CDF), affichés avec `intl` |

N'ajoute pas d'autre service payant sans le demander.

## 3. Identité visuelle

Reprendre la maquette validée.

- Couleurs : principale `#B4451F` (terracotta), secondaire `#1F5E4A` (vert), fond `#F6F1E7` (crème), cartes `#FFFDF8`, texte `#1E1B16`, texte secondaire `#5E574C`, bordures `#DDD3C2`.
- Labels : « Africain » fond `#E3EFE9` texte `#1F5E4A` ; « Chrétien » fond `#F7E1D6` texte `#8A3416`.
- Polices : **Fraunces** (titres) et **DM Sans** (texte), via `google_fonts`.
- Coins arrondis 12–18 px, zones tactiles ≥ 44 px, contraste AA, mode sombre prévu dans le thème.
- Barre de navigation en bas : Explorer, Favoris, Messages, Mon espace (+ Admin pour les administrateurs).

## 4. Modèle de données Firestore

```
users/{uid}
  nom, email, photoUrl, role: "client" | "pro" | "admin",
  langue, ville, pays, favoris: [commerceId], createdAt

commerces/{commerceId}
  nom, categorie: "magasin" | "restaurant" | "logement" | "service",
  description, photos: [url], adresse, geo: GeoPoint, geohash,
  pays, ville, continent: "europe" | "afrique" | "amerique",
  horaires, telephone, labelAfricain: bool, labelChretien: bool,
  charteSigneeLe: timestamp | null,
  statut: "en_verification" | "publie" | "suspendu",
  proprietaire: uid, noteMoyenne, nbAvis, createdAt, updatedAt

commerces/{commerceId}/produits/{produitId}
  nom, description, photoUrl, prix, devise, publie: bool, ordre, createdAt

commerces/{commerceId}/avis/{avisId}
  auteur: uid, note: 1..5, texte, createdAt

conversations/{commerceId__clientUid}
  commerceId, commerceNom, clientId, proId, participants: [clientId, proId],
  dernierMessage, updatedAt, nonLusClient, nonLusPro

conversations/{id}/messages/{messageId}
  auteur: uid, texte, photoUrl?, createdAt

signalements/{id}
  cible (commerce | avis | message), cibleId, auteur, motif, createdAt, traite: bool
```

Utilise `geohash` (package `geoflutterfire_plus` ou équivalent) pour la recherche par distance.

## 5. Règles de sécurité (obligatoires)

Écris `firestore.rules` et `storage.rules`, avec des tests (émulateur Firebase) :

- Seuls les commerces `publie` sont lisibles par tous ; le propriétaire et les admins voient aussi les siens en vérification.
- Un pro ne crée un commerce qu'avec `statut = "en_verification"` et `proprietaire = son uid`.
- Seul un admin modifie `statut`, `labelAfricain`, `labelChretien` après création (le pro les *demande* à l'inscription).
- Seul le propriétaire modifie son commerce et ses produits.
- Un avis : un par utilisateur et par commerce, modifiable seulement par son auteur. `noteMoyenne` et `nbAvis` sont recalculés par une Cloud Function, jamais par le client.
- Une conversation et ses messages ne sont lisibles et écrits que par ses `participants`.
- Le rôle `admin` est attribué par *custom claim* (script ou fonction), jamais par l'app.
- Storage : images uniquement, 5 Mo max, écriture réservée au propriétaire du commerce concerné.

## 6. Écrans de la version 1

1. **Bienvenue / connexion** : e-mail, Google, Apple (obligatoire sur iOS si Google est proposé). Choix « Je cherche un commerce » / « J'ai un commerce ».
2. **Explorer** : recherche texte, filtres continent, catégorie, labels, « ouvert maintenant » ; bascule liste / carte ; tri par distance.
3. **Fiche commerce** : photos, labels, badge « Vérifié », note, description, adresse, horaires ; boutons Message, Appeler, Itinéraire (ouvre l'app de cartes) ; onglets Produits, Avis, Infos ; bouton Favori ; « Signaler ».
4. **Favoris**.
5. **Messages** : liste des conversations avec non-lus ; conversation temps réel, envoi de photo ; notifications push.
6. **Inscription pro** (3 étapes) : infos du commerce + position sur carte ; labels demandés (charte chrétienne à accepter, texte fourni plus tard — prévois un écran) ; photos.
7. **Espace pro** : statut de la fiche, réglages de commande et de livraison, onglet Commandes, modification de la fiche, catalogue (ajouter, modifier, masquer, réordonner, supprimer), messages, statistiques simples (vues de la fiche, favoris).
8. **Admin** : commerces en attente (publier / refuser avec motif), commerces publiés (suspendre), signalements.
9. **Profil** : langue, devise préférée, suppression du compte (RGPD), liens CGU et confidentialité.

## 7. Commande en ligne et livraison (inclus en V1)

Les clients commandent les produits d'un commerce directement dans l'app, en livraison ou à
emporter. Chaque commerce choisit s'il active la commande et fixe ses conditions.

**Réglages du commerce** (champs à ajouter à `commerces/{id}`, modifiables par le propriétaire) :

```
commande: {
  active: bool,
  modes: ["livraison", "emporter"],
  minimumCommande: number,        // montant minimum du panier pour commander, dans la devise du commerce
  minimumLivraison: number,       // minimum spécifique à la livraison (peut être plus élevé)
  fraisLivraison: number,         // frais fixes facturés au client
  livraisonGratuiteDes: number | null,  // panier à partir duquel la livraison est offerte
  rayonLivraisonKm: number,
  delaiPreparationMin: number,
  devise: string
}
```

**Données** :

```
commandes/{commandeId}
  commerceId, commerceNom, clientId, proId,
  lignes: [{ produitId, nom, prixUnitaire, quantite }],
  sousTotal, fraisLivraison, fraisService, commissionPlateforme, total, devise,
  mode: "livraison" | "emporter",
  adresseLivraison: { texte, geo, instructions } | null,
  telephoneClient,
  paiement: { methode: "carte" | "mobile_money" | "especes", statut: "en_attente" | "paye" | "rembourse" | "echoue", reference },
  statut: "nouvelle" | "acceptee" | "en_preparation" | "prete" | "en_livraison" | "livree" | "retiree" | "refusee" | "annulee",
  historique: [{ statut, date }], createdAt, updatedAt
```

**Parcours client** : bouton « Ajouter au panier » sur les produits ; un panier par commerce ;
écran panier qui affiche clairement le sous-total, les frais de livraison, les frais de service et
le total ; **le bouton « Commander » reste désactivé tant que le minimum n'est pas atteint**, avec le
message « Encore X € pour atteindre le minimum de commande » ; adresse vérifiée dans le rayon de
livraison ; paiement ; suivi de la commande en temps réel avec notifications à chaque étape.

**Parcours pro** : activer la commande et saisir ses conditions ; onglet « Commandes » avec alerte
sonore et notification pour chaque nouvelle commande ; accepter ou refuser (avec motif) ; faire
avancer les statuts ; marquer un produit « en rupture » en un geste ; historique et total des ventes.

**Livraison** : en V1, **le commerce livre lui-même** (ou avec son propre livreur). Prévois dans
le code une interface `LivraisonService` pour brancher plus tard des partenaires de livraison.

**Paiement** :

- Europe et Amérique : Stripe Connect (paiement par carte, argent versé au commerce moins la commission).
- Afrique : Flutterwave ou CinetPay (mobile money : Orange Money, Wave, MTN, M-Pesa).
- Option « paiement à la livraison en espèces » activable par commerce.
- Les montants (minimum, frais, commission, total) sont **toujours recalculés côté serveur**
  dans une Cloud Function au moment de la commande ; ne jamais faire confiance au prix envoyé par l'app.
- Les taux de commission et de frais de service sont stockés dans `parametres/tarifs`
  (par pays ou continent), modifiables par l'admin, jamais codés en dur.

**Sécurité** : une commande n'est lisible que par son client, le commerce concerné et les admins ;
le client ne peut que la créer (via la Cloud Function) et l'annuler tant qu'elle est « nouvelle » ;
seul le commerce fait avancer les statuts de préparation et de livraison.

## 7 bis. Modèle économique à implémenter

Principe : la plateforme ne gagne de l'argent que lorsque le commerçant en gagne, et reste bien moins
chère que les grandes plateformes de livraison. **Tous les montants et taux sont des paramètres
modifiables par l'admin dans `parametres/tarifs`, par pays ou par continent, jamais codés en dur.**
Les valeurs ci-dessous sont les valeurs de départ.

| Source de revenu | Valeur de départ | À implémenter |
|---|---|---|
| Commission sur les commandes | 5 à 8 % du sous-total (hors frais de livraison) | Calculée par la Cloud Function de commande ; prélevée via Stripe Connect / Flutterwave avant versement au commerce |
| Frais de service client | 0,49 à 0,99 € par commande, ou 2 % plafonnés | Ligne distincte et visible dans le panier, avec une info-bulle qui l'explique |
| Abonnement premium pro (facultatif) | ex. 9 à 15 €/mois en Europe et Amérique, prix réduit en Afrique | Plus de photos, statistiques détaillées, commission réduite ; paiement récurrent ; la fiche de base reste gratuite pour toujours |
| Mise en avant payante | ex. une semaine en tête des résultats d'une ville | Emplacements marqués « Sponsorisé », limités en nombre par page, achetés depuis l'espace pro |

**Règles obligatoires**

- **Période de lancement** : commission à 0 % pendant une durée paramétrable (3 à 6 mois) pour les commerçants inscrits avant une date donnée (`parametres/tarifs.lancement`).
- **Frais de livraison** : entièrement reversés au commerce (ou au livreur plus tard), jamais soumis à commission.
- **Tarifs par région** : commission, frais de service et prix des abonnements définis par pays ou continent.
- **Transparence** : pour chaque commande, l'espace pro affiche le montant payé par le client, la commission, les frais de paiement et le montant net reçu. Un récapitulatif mensuel est téléchargeable.
- **Écran admin « Revenus »** : total des commissions, frais de service, abonnements et mises en avant, par mois et par pays.
- Enregistre `commissionPlateforme`, `fraisService` et `fraisPaiement` sur chaque commande pour la comptabilité.

## 7 ter. Hors périmètre V1 (ne pas construire)

Réservation de logements avec calendrier, livreurs indépendants intégrés à l'app, fidélité, agenda
d'événements.

## 8. Exigences générales

- Fonctionne avec une connexion lente : images compressées avant envoi, miniatures, pagination, états de chargement.
- Chaque écran a un état vide utile et des messages d'erreur clairs.
- Accessibilité : libellés sur les icônes, tailles de texte système respectées.
- Aucune clé secrète dans le dépôt : utilise des fichiers d'environnement ignorés par git.
- Code organisé par fonctionnalité (`lib/features/...`), commenté là où c'est utile.

## 9. Ordre de travail

Avance étape par étape. À la fin de chaque étape : l'app compile, les tests passent, fais un commit,
résume ce qui est fait et ce que le porteur du projet doit vérifier sur son téléphone.

1. Projet Flutter, thème, polices, traductions, navigation avec écrans vides.
2. Connexion Firebase (guide le porteur pour créer le projet Firebase), authentification, rôles.
3. Modèle de données, règles de sécurité et leurs tests.
4. Inscription pro et espace pro (fiche + catalogue + photos).
5. Écran admin et custom claim admin.
6. Explorer (liste, filtres, recherche) et fiche commerce, favoris, avis.
7. Carte et recherche par distance.
8. Messagerie et notifications.
9. Commande en ligne : panier, minimum de commande, paiement (d'abord en mode test), suivi, espace commandes du pro, commission et frais de service paramétrables, écran admin Revenus. Abonnement premium et mise en avant peuvent venir juste après.
10. Profil, suppression de compte, pages légales.
11. Données de démonstration, tests sur appareils, préparation des fiches App Store / Google Play.

Avant toute décision importante non prévue ici (nouveau service, changement de modèle de données),
pose la question au lieu de choisir seul.

## Notes techniques (tenues à jour au fil des étapes)

- Structure : `lib/core/` (thème, navigation, auth), `lib/features/<fonctionnalité>/`, `lib/shared/widgets/`.
- Traductions : `lib/l10n/app_fr.arb` (modèle), `app_en.arb`, `app_pt.arb` ; code généré par `flutter gen-l10n`.
- Polices incluses dans `assets/google_fonts/` (pas de téléchargement à l'exécution).
- Auth (`lib/features/auth/`) : `roleProvider` renvoie null (non connecté), client, pro ou admin.
  Admin = uniquement le custom claim `admin: true` ; la valeur « admin » dans `users/{uid}.role` est ignorée.
  Le profil `users/{uid}` est créé à la première connexion avec le rôle choisi sur l'écran de bienvenue.
- On peut explorer sans compte (exigence App Store) ; Favoris, Messages et Mon espace demandent une connexion.
- Tests : Firebase simulé (`firebase_auth_mocks`, `fake_cloud_firestore`), voir `test/helpers.dart`.
- Modèles Firestore : `lib/shared/models/` (commerce, produit, avis, conversation/message, signalement).
- Règles de sécurité : `firebase/firestore.rules` et `firebase/storage.rules`, testées dans
  `firebase/tests/` avec l'émulateur (`cd firebase && npm install && npm test`, Java 21 requis).
  Projet Firebase : `harambee-75bab` (config dans `lib/core/firebase/firebase_options.dart`).
- Dans l'environnement cloud de Claude, un proxy bloque les appels entre émulateurs Storage → Firestore :
  les 2 tests Storage qui en dépendent y échouent, mais passent sur GitHub Actions (`.github/workflows/ci.yml`).
- Espace pro (`lib/features/commerce/`) : fiche en 3 étapes (`fiche_commerce_screen.dart`, sert aussi à la
  modification), catalogue (`catalogue_screen.dart`, `produit_screen.dart`), `CommerceRepository`, `PhotosService`.
  Photos compressées par image_picker (1600 px, qualité 80), 6 max par fiche, dans Storage `commerces/{id}/…`.
  Geohash calculé à l'enregistrement (`dart_geohash`, attention : longitude en premier).
  Pays proposés : `lib/features/commerce/data/pays.dart` (continent et devise par défaut en découlent).
- Charte chrétienne : texte provisoire (`charteTexteProvisoire` dans les ARB), à remplacer par le texte fourni.
- Statistiques de l'espace pro (vues, favoris) : pas encore faites, prévues avec les Cloud Functions.
- Cloud Functions (`functions/`, Node 22, JS, région europe-west1) : `revendiquerAdminInitial` (premier admin =
  compte dont l'e-mail est le paramètre `EMAIL_ADMIN_INITIAL`, une seule fois ; dans l'app : appui long sur la
  carte « Bonjour … » de Mon espace) et `definirAdmin` (admins seulement). Journal dans `systeme/admins/historique`.
  Tests : `cd functions && npm install && npm test` (émulateurs auth + firestore + functions).
- Admin (`lib/features/admin/`) : onglets En attente / Publiés / Suspendus / Signalements, fiche de vérification
  (labels, publier, refuser/suspendre avec motif obligatoire, republier), écran Administrateurs.
  Refuser = statut « suspendu » + `motifRefus` (le modèle n'a que 3 statuts).
- Vérifier avant chaque commit : `flutter analyze` et `flutter test`.
