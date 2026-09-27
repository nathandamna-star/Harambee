# Guide de publication (App Store et Google Play)

Ce guide liste, dans l'ordre, tout ce qu'il faut remplir pour publier
Harambee. Les textes de présentation sont dans `docs/fiches-stores.md`.

## 1. Adresses web à fournir aux stores

Après `npx firebase deploy --only functions`, ces pages sont en ligne :

| Page | Adresse |
|---|---|
| Politique de confidentialité | https://europe-west1-harambee-75bab.cloudfunctions.net/legal?page=confidentialite |
| Conditions d'utilisation | https://europe-west1-harambee-75bab.cloudfunctions.net/legal?page=cgu |
| Aide et contact (support) | https://europe-west1-harambee-75bab.cloudfunctions.net/legal?page=support |

Avant de publier, il faut remplacer les passages entre crochets `[…]`
(raison sociale, adresse, e-mail de contact…) dans `assets/legal/*.md`, puis
recopier ces fichiers dans `functions/legal/` (un test vérifie que les copies
sont identiques). Faites relire ces textes par un juriste.

## 2. Informations générales

- **Identifiant de l'app (bundle / package)** : `com.harambee.harambee`
- **Catégorie principale** : Shopping (App Store) / Shopping (Google Play)
- **Catégorie secondaire (App Store)** : Food & Drink
- **Âge** : 12+ sur l'App Store (les utilisateurs échangent des messages
  et des photos, avec signalement et blocage). Sur Google Play,
  répondre au questionnaire : communication entre utilisateurs = oui,
  achats de biens physiques = oui, pas de violence ni de contenu adulte.
- **Chiffrement** : l'app n'utilise que le chiffrement standard (HTTPS).
  C'est déjà déclaré dans l'app (`ITSAppUsesNonExemptEncryption = NO`), Apple
  ne posera donc plus la question.
- **Prix** : gratuit.
- **Pays** : Belgique au lancement (vous pourrez en ajouter ensuite).

## 3. Confidentialité : ce que l'app collecte

À déclarer dans « App Privacy » (App Store) et « Sécurité des données »
(Google Play). Aucune donnée n'est utilisée pour de la publicité ni pour
suivre l'utilisateur sur d'autres apps (« tracking » = **non**).

| Donnée | Pourquoi | Liée à l'identité |
|---|---|---|
| Nom, adresse e-mail | Compte | Oui |
| Numéro de téléphone (commerçants) | Affiché sur la fiche du commerce | Oui |
| Adresse postale (commerçants, livraison) | Fiche du commerce, livraison | Oui |
| Position approximative ou précise | « Près de moi », position du commerce — non conservée pour les clients | Non |
| Photos | Fiche commerce, produits, messages | Oui |
| Messages entre utilisateurs | Messagerie | Oui |
| Historique d'achats | Commandes | Oui |
| Avis publiés | Avis sur les commerces | Oui |
| Identifiant de l'appareil (jeton de notification) | Notifications | Oui |

Les données de carte bancaire sont saisies chez Stripe : Harambee ne les voit
jamais. Sur Google Play, indiquer aussi : données chiffrées en transit = oui ;
l'utilisateur peut demander la suppression = oui (Mon espace → Profil et réglages → Supprimer mon
compte, directement dans l'app).

## 4. Comptes de test pour les vérificateurs

Apple et Google testent l'app avant de l'accepter. Il faut leur donner des
comptes qui fonctionnent :

1. Dans l'app, créer deux comptes avec des adresses dédiées, par exemple
   `revue.client@…` et `revue.pro@…` (mot de passe solide).
2. Avec le compte pro, créer un commerce et le faire valider depuis l'écran
   Admin, avec deux ou trois produits.
3. Garder les données de démonstration (Admin → Données de démonstration)
   pendant la revue pour que l'Explorer ne soit pas vide.
4. Dans les notes pour le vérificateur, écrire (en anglais) :
   > Test accounts: customer `…` / `…`, business owner `…` / `…`.
   > Card payments use Stripe; in test mode use card 4242 4242 4242 4242,
   > any future date, any CVC. Users can report messages and block a contact
   > from the conversation menu (⋮). Account deletion: Profile → Delete my account.

## 5. Captures d'écran

À faire sur le téléphone (ou le simulateur du Mac) avec les données de
démonstration, en français :

- **iPhone 6,9 pouces** (obligatoire) : 1320 × 2868 px — simulateur
  « iPhone 16 Pro Max » ou plus récent. De 3 à 10 captures.
- **Google Play** : au moins 2 captures de téléphone (format portrait,
  1080 × 1920 px conseillé) et une « image de présentation » de 1024 × 500 px.

Écrans conseillés, dans cet ordre : Explorer (liste), Carte « Près de moi »,
fiche d'un commerce, catalogue et panier, suivi de commande, messagerie,
espace commerçant.

## 6. Avant d'envoyer l'app en revue

- [ ] Compte Apple Developer validé, puis : notifications push, clé APNs
      envoyée dans Firebase, « Se connecter avec Apple » (obligatoire sur iOS
      dès qu'on propose la connexion Google).
- [ ] Clé Stripe **live** (`pk_live_…`) dans l'app et secrets live dans
      Firebase — seulement quand vous êtes prêt à encaisser de vrais paiements.
- [ ] Pages légales complétées et en ligne (section 1).
- [ ] Données de démonstration supprimées **après** l'acceptation par les
      stores (Admin → Données de démonstration → Supprimer).
- [ ] Numéro de version à jour dans `pubspec.yaml` (`1.0.0+1`, puis `+2`,
      `+3`… à chaque nouvel envoi).
- [ ] Une fois l'app publiée : ajouter les liens App Store et Google Play dans
      `functions/pageCommerce.js` (`LIENS_STORES`), puis
      `npx firebase deploy --only functions:commerce`. Les pages partagées et
      les QR codes proposeront alors le téléchargement.
