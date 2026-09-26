import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/commerce.dart';
import '../../shared/models/enums.dart';
import '../../shared/models/signalement.dart';
import '../auth/auth_providers.dart';
import 'data/admin_repository.dart';
import 'data/fonctions_admin.dart';

final fonctionsAdminProvider = Provider<FonctionsAdmin>(
  (ref) => FonctionsAdminFirebase(
    FirebaseFunctions.instanceFor(region: 'europe-west1'),
  ),
);

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(firestoreProvider)),
);

final commercesParStatutProvider =
    StreamProvider.family<List<Commerce>, StatutCommerce>(
      (ref, statut) =>
          ref.watch(adminRepositoryProvider).commercesParStatut(statut),
    );

final signalementsProvider = StreamProvider<List<Signalement>>(
  (ref) => ref.watch(adminRepositoryProvider).signalementsATraiter(),
);
