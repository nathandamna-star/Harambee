import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';

void main() {
  // Les polices sont incluses dans l'app (assets/google_fonts) :
  // pas de téléchargement, utile avec une connexion lente.
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const ProviderScope(child: HarambeeApp()));
}
