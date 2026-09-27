import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Partage d'un fichier (enregistrer, envoyer par e-mail…).
abstract interface class PartageFichier {
  Future<void> partager({
    required String nom,
    required String contenu,
    required String typeMime,
  });
}

class PartageNatif implements PartageFichier {
  @override
  Future<void> partager({
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
