# Harambee

Application mobile (iOS + Android) qui répertorie les magasins, restaurants, logements et
services africains et chrétiens, entre l'Europe, l'Afrique et l'Amérique.

Le cahier des charges complet se trouve dans [CLAUDE.md](CLAUDE.md).

## Lancer l'application

1. Installer Flutter : https://docs.flutter.dev/get-started/install
2. Dans ce dossier :
   ```
   flutter pub get
   flutter run
   ```

## Clé Google Maps

La clé n'est pas dans le dépôt. Sur l'ordinateur qui compile l'app :

- iPhone : créer `ios/Flutter/Secrets.xcconfig` contenant `MAPS_API_KEY=la_cle`
- Android : ajouter `MAPS_API_KEY=la_cle` dans `android/local.properties`

## Vérifier le code

```
flutter analyze
flutter test
```

Règles de sécurité Firebase (nécessite Node.js et Java 21) :

```
cd firebase
npm install
npm test
```

Fonctions serveur (nécessite Node.js et Java 21) :

```
cd functions
npm install
npm test
```

## Déployer sur Firebase

Depuis le dossier `firebase/` (après `npx firebase login`) :

```
npx firebase deploy --only firestore:rules,storage,functions
```

