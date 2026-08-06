import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/injection_container.dart';
import 'synchronisation_service.dart';

/// Indicateur visible "en attente de synchronisation" (Partie C du cahier
/// des charges) : simple lecture du flux exposé par [SynchronisationService],
/// jamais de logique de synchronisation dans la Presentation.
final elementsEnAttenteSyncProvider = StreamProvider.autoDispose<int>((ref) {
  return sl<SynchronisationService>().flusElementsEnAttente;
});
