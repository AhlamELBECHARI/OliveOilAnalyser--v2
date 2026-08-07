import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../local_storage/local_database.dart';

/// Mesure la taille RÉELLE occupée sur le disque par l'app (Partie B,
/// "Espace de stockage") : la base locale Drift (toutes les analyses en
/// attente ou déjà synchronisées) + le dossier de cache temporaire. Jamais
/// de quota inventé : seule la taille utilisée est retournée, à afficher
/// telle quelle côté Presentation.
class EspaceStockageService {
  const EspaceStockageService();

  Future<int> calculerOctetsUtilises() async {
    final tailleBase = await _tailleFichier();
    final tailleCache = await _tailleDossier(await getTemporaryDirectory());
    return tailleBase + tailleCache;
  }

  Future<int> _tailleFichier() async {
    final fichier = await LocalDatabase.cheminFichier();
    if (!await fichier.exists()) return 0;
    return fichier.length();
  }

  Future<int> _tailleDossier(Directory dossier) async {
    if (!await dossier.exists()) return 0;
    var total = 0;
    await for (final entite in dossier.list(recursive: true, followLinks: false)) {
      try {
        final stat = await entite.stat();
        if (stat.type == FileSystemEntityType.file) {
          total += stat.size;
        }
      } catch (_) {
        // Fichier supprimé/inaccessible entre le listing et le stat : ignoré,
        // ne doit jamais faire échouer tout le calcul pour un seul fichier.
      }
    }
    return total;
  }

  /// Vide le dossier de cache temporaire (voir Partie B, "Gestion des
  /// données"). Ne touche jamais à la base Drift : les analyses en attente
  /// de synchronisation ne sont pas du cache, seulement du travail non
  /// encore envoyé.
  Future<void> viderCache() async {
    final dossier = await getTemporaryDirectory();
    if (!await dossier.exists()) return;
    await for (final entite in dossier.list(followLinks: false)) {
      try {
        await entite.delete(recursive: true);
      } catch (_) {
        // Un fichier verrouillé/en cours d'utilisation ne doit pas bloquer
        // la suppression du reste du cache.
      }
    }
  }
}

String formaterTailleOctets(int octets) {
  const unites = ['o', 'Ko', 'Mo', 'Go'];
  double valeur = octets.toDouble();
  var index = 0;
  while (valeur >= 1024 && index < unites.length - 1) {
    valeur /= 1024;
    index++;
  }
  // Une décimale seulement pour une valeur non entière sous 10 unités
  // (ex. "1.5 Mo") : jamais de ".0" superflu sur un nombre rond ("2 Ko",
  // pas "2.0 Ko").
  final estEntier = valeur == valeur.roundToDouble();
  final decimales = (!estEntier && valeur < 10 && index > 0) ? 1 : 0;
  return '${valeur.toStringAsFixed(decimales)} ${unites[index]}';
}
