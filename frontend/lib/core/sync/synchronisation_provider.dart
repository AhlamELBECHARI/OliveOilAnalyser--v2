import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/injection_container.dart';
import 'synchronisation_service.dart';

/// Indicateur visible "en attente de synchronisation" (Partie C du cahier
/// des charges) : simple lecture du flux exposé par [SynchronisationService],
/// jamais de logique de synchronisation dans la Presentation.
final elementsEnAttenteSyncProvider = StreamProvider.autoDispose<int>((ref) {
  return sl<SynchronisationService>().flusElementsEnAttente;
});

/// Date de la dernière synchronisation réussie (Partie B, "Données &
/// Synchronisation") — valeur initiale lue immédiatement, puis mise à jour
/// à chaud via le flux du service.
final derniereSynchronisationProvider = StreamProvider.autoDispose<DateTime?>((ref) async* {
  final service = sl<SynchronisationService>();
  yield service.derniereSynchronisation;
  yield* service.flusDerniereSynchronisation;
});

/// Interrupteur "Synchronisation cloud" : lit/écrit directement
/// [SynchronisationService.estActivee] (persisté localement), qui gate lui
/// -même toute tentative de synchronisation tant qu'il est désactivé.
class SyncActiveeNotifier extends StateNotifier<bool> {
  SyncActiveeNotifier() : super(sl<SynchronisationService>().estActivee);

  Future<void> definir(bool activee) async {
    state = activee;
    await sl<SynchronisationService>().definirActivee(activee);
  }
}

final syncActiveeProvider = StateNotifierProvider.autoDispose<SyncActiveeNotifier, bool>(
  (ref) => SyncActiveeNotifier(),
);
