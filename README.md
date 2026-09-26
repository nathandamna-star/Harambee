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
