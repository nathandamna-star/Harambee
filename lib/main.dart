import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/stripe.dart';
import 'core/firebase/firebase_options.dart';
import 'core/preferences/preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Les polices sont incluses dans l'app (assets/google_fonts) :
  // pas de téléchargement, utile avec une connexion lente.
  GoogleFonts.config.allowRuntimeFetching = false;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final preferences = await SharedPreferences.getInstance();
  if (stripeClePublique.isNotEmpty) {
    Stripe.publishableKey = stripeClePublique;
    Stripe.urlScheme = stripeSchemaUrl;
    await Stripe.instance.applySettings();
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const HarambeeApp(),
    ),
  );
}
