import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/commerce.dart';
import '../../shared/models/produit.dart';
import '../auth/auth_providers.dart';
import 'data/commerce_repository.dart';
import 'data/localisation_service.dart';
import 'data/photos_service.dart';

final firebaseStorageProvider = Provider<FirebaseStorage>(
  (ref) => FirebaseStorage.instance,
);

final selecteurPhotoProvider = Provider<SelecteurPhoto>(
  (ref) => SelecteurPhotoNatif(),
);

final localisationServiceProvider = Provider<LocalisationService>(
  (ref) => LocalisationServiceNatif(),
);

final commerceRepositoryProvider = Provider<CommerceRepository>(
  (ref) => CommerceRepository(
    firestore: ref.watch(firestoreProvider),
    photos: PhotosService(ref.watch(firebaseStorageProvider)),
  ),
);

/// Commerces du pro connecté.
final mesCommercesProvider = StreamProvider<List<Commerce>>((ref) {
  final user = ref.watch(utilisateurFirebaseProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(commerceRepositoryProvider).commercesDuPro(user.uid);
});

final commerceProvider = StreamProvider.family<Commerce?, String>(
  (ref, id) => ref.watch(commerceRepositoryProvider).commerce(id),
);

final produitsProvider = StreamProvider.family<List<Produit>, String>(
  (ref, commerceId) =>
      ref.watch(commerceRepositoryProvider).produits(commerceId),
);
