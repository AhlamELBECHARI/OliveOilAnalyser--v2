import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'espace_stockage_service.dart';

const _service = EspaceStockageService();

/// Taille réelle (en octets) occupée par la base locale Drift + le cache
/// temporaire — voir Partie B, "Espace de stockage". Recalculée à chaque
/// ouverture du sous-écran "Gestion des données" (autoDispose).
final espaceStockageProvider = FutureProvider.autoDispose<int>((ref) {
  return _service.calculerOctetsUtilises();
});
