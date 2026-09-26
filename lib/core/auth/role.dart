import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rôle de l'utilisateur connecté.
enum Role { client, pro, admin }

/// Rôle courant. Provisoire : toujours « client » tant que Firebase
/// Authentication n'est pas branché (étape 2).
final roleProvider = Provider<Role>((ref) => Role.client);
