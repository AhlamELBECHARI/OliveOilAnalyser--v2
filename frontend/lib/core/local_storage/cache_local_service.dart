import 'dart:convert';

import 'local_database.dart';

/// Sérialisation JSON au-dessus du cache générique clé/valeur (voir
/// CacheGenerique) — seul point de contact entre les repositories et le
/// stockage brut, pour que "toute donnée reçue du serveur est écrite en
/// local à la réception" (cahier des charges, Partie A) reste une ligne
/// d'appel, jamais réimplémentée par feature.
class CacheLocalService {
  final LocalDatabase _base;

  const CacheLocalService({required LocalDatabase base}) : _base = base;

  Future<void> ecrireMap(String cle, Map<String, dynamic> valeur) =>
      _base.ecrireCache(cle, jsonEncode(valeur));

  Future<void> ecrireListe(String cle, List<Map<String, dynamic>> valeur) =>
      _base.ecrireCache(cle, jsonEncode(valeur));

  Future<Map<String, dynamic>?> lireMap(String cle) async {
    final brut = await _base.lireCache(cle);
    if (brut == null) return null;
    return jsonDecode(brut) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>?> lireListe(String cle) async {
    final brut = await _base.lireCache(cle);
    if (brut == null) return null;
    return (jsonDecode(brut) as List).cast<Map<String, dynamic>>();
  }
}

/// Clés stables du cache générique — centralisées ici pour éviter toute
/// collision ou faute de frappe entre features.
class CleCache {
  const CleCache._();

  static const configuration = 'configuration';
  static const profil = 'profil_utilisateur';
  static const modelesActifs = 'modeles_actifs';
  static const alertesNonResolues = 'alertes_non_resolues_compte';
}
