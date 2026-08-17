import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/injection_container.dart';
import 'connectivity_service.dart';

/// Vrai si une interface réseau est active, avec une valeur initiale connue
/// immédiatement (jamais `AsyncLoading` affiché à l'écran pour ça) puis mise
/// à jour à chaud. Utilisé par l'écran de connexion et l'indicateur global
/// (Partie C) — jamais de logique de connectivité dupliquée dans la
/// Presentation.
final connectiviteProvider = StreamProvider<bool>((ref) async* {
  final service = sl<ConnectivityService>();
  yield await service.estEnLigne();
  yield* service.flusEnLigne;
});
