import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../commerce_providers.dart';
import '../data/commerce_repository.dart';

/// Photos d'une fiche : aperçu, ajout (galerie ou appareil photo), retrait.
class GrillePhotos extends ConsumerWidget {
  const GrillePhotos({
    super.key,
    required this.photos,
    required this.onChanged,
    this.maximum = CommerceRepository.maxPhotosFiche,
  });

  final List<PhotoFiche> photos;
  final ValueChanged<List<PhotoFiche>> onChanged;
  final int maximum;

  Future<void> _ajouter(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final camera = await choisirSourcePhoto(context, l10n);
    if (camera == null) return;
    final octets = await ref
        .read(selecteurPhotoProvider)
        .choisir(camera: camera);
    if (octets != null) onChanged([...photos, PhotoFiche.nouvelle(octets)]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (var i = 0; i < photos.length; i++)
          Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ApercuPhoto(photo: photos[i]),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton.filledTonal(
                  tooltip: l10n.retirerPhoto,
                  icon: const Icon(Icons.close),
                  onPressed: () => onChanged([...photos]..removeAt(i)),
                ),
              ),
            ],
          ),
        if (photos.length < maximum)
          Semantics(
            button: true,
            label: l10n.ajouterPhoto,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _ajouter(context, ref),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: const Center(
                  child: ExcludeSemantics(
                    child: Icon(Icons.add_a_photo_outlined, size: 32),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ApercuPhoto extends StatelessWidget {
  const ApercuPhoto({super.key, required this.photo});

  final PhotoFiche photo;

  @override
  Widget build(BuildContext context) {
    if (photo.octets != null) {
      return Image.memory(photo.octets!, fit: BoxFit.cover, cacheWidth: 400);
    }
    return Image.network(
      photo.url!,
      fit: BoxFit.cover,
      cacheWidth: 400,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
    );
  }
}

/// Demande galerie ou appareil photo. Renvoie true pour l'appareil photo,
/// false pour la galerie, null si annulé.
Future<bool?> choisirSourcePhoto(BuildContext context, AppLocalizations l10n) =>
    showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.photoGalerie),
              onTap: () => Navigator.pop(context, false),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.photoCamera),
              onTap: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
