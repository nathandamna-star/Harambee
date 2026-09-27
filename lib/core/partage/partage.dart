import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Feuille de partage du téléphone (messages, WhatsApp, e-mail, impression…).
/// [origine] : zone du bouton, exigée par l'iPad pour placer la fenêtre.
abstract interface class Partage {
  Future<void> partagerTexte(String texte, {String? sujet, Rect? origine});

  Future<void> partagerImage(
    Uint8List png, {
    required String nom,
    String? texte,
    Rect? origine,
  });

  Future<void> partagerFichier({
    required String nom,
    required String contenu,
    required String typeMime,
  });
}

class PartageNatif implements Partage {
  @override
  Future<void> partagerTexte(
    String texte, {
    String? sujet,
    Rect? origine,
  }) async {
    await SharePlus.instance.share(
      ShareParams(text: texte, subject: sujet, sharePositionOrigin: origine),
    );
  }

  @override
  Future<void> partagerImage(
    Uint8List png, {
    required String nom,
    String? texte,
    Rect? origine,
  }) async {
    final dossier = await getTemporaryDirectory();
    final fichier = File('${dossier.path}/$nom');
    await fichier.writeAsBytes(png);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(fichier.path, mimeType: 'image/png')],
        text: texte,
        sharePositionOrigin: origine,
      ),
    );
  }

  @override
  Future<void> partagerFichier({
    required String nom,
    required String contenu,
    required String typeMime,
  }) async {
    final dossier = await getTemporaryDirectory();
    final fichier = File('${dossier.path}/$nom');
    // BOM UTF-8 : accents corrects à l'ouverture dans Excel.
    await fichier.writeAsString('﻿$contenu');
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(fichier.path, mimeType: typeMime)],
        subject: nom,
      ),
    );
  }
}

final partageProvider = Provider<Partage>((ref) => PartageNatif());

/// Zone d'un widget à l'écran (position de la fenêtre de partage sur iPad).
Rect? zoneDe(BuildContext context) {
  final boite = context.findRenderObject();
  if (boite is! RenderBox || !boite.hasSize) return null;
  return boite.localToGlobal(Offset.zero) & boite.size;
}
