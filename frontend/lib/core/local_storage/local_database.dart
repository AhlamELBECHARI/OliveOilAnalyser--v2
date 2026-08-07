import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/echantillons_locaux_table.dart';
import 'tables/resultats_locaux_table.dart';
import 'tables/spectres_locaux_table.dart';

part 'local_database.g.dart';

/// Base SQLite locale (Drift) : toute analyse (échantillon, spectre,
/// résultat) y est TOUJOURS écrite en premier, avant toute tentative
/// réseau — voir features/analyseur (acquisition) et
/// core/sync/synchronisation_service.dart (envoi vers l'API). Aucune
/// logique de synchronisation ici : uniquement des requêtes CRUD/lecture.
@DriftDatabase(tables: [EchantillonsLocaux, SpectresLocaux, ResultatsLocaux])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor]) : super(executor ?? _ouvrirConnexion());

  @override
  int get schemaVersion => 1;

  static const nomFichier = 'olive_iq_local.sqlite';

  static QueryExecutor _ouvrirConnexion() {
    return LazyDatabase(() async {
      final fichier = await cheminFichier();
      return NativeDatabase.createInBackground(fichier);
    });
  }

  /// Chemin du fichier SQLite sur le disque — voir
  /// core/storage/espace_stockage_service.dart, qui en lit la taille réelle
  /// pour l'indicateur "Espace de stockage" (Partie B).
  static Future<File> cheminFichier() async {
    final dossier = await getApplicationDocumentsDirectory();
    return File(p.join(dossier.path, nomFichier));
  }

  // --- Échantillons ---

  Future<void> insererEchantillon(EchantillonsLocauxCompanion donnees) =>
      into(echantillonsLocaux).insertOnConflictUpdate(donnees);

  Future<EchantillonsLocauxData?> obtenirEchantillon(String id) =>
      (select(echantillonsLocaux)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Inclut aussi bien les échantillons jamais tentés (enAttente) que ceux
  /// dont la dernière tentative a échoué (erreur) : un échec réseau doit
  /// rester retenté automatiquement à la prochaine synchronisation, jamais
  /// abandonné silencieusement — seul le statut "synchronise" en sort.
  Future<List<EchantillonsLocauxData>> obtenirEchantillonsEnAttente() => (select(echantillonsLocaux)
        ..where((t) => t.statutSync.equals(_synchronise).not()))
      .get();

  Future<int> compterEchantillonsEnAttente() =>
      obtenirEchantillonsEnAttente().then((liste) => liste.length);

  Future<void> marquerEchantillonSynchronise(String id) =>
      (update(echantillonsLocaux)..where((t) => t.id.equals(id))).write(
        const EchantillonsLocauxCompanion(
          statutSync: Value(_synchronise),
          messageErreurSync: Value(null),
        ),
      );

  Future<void> marquerEchantillonErreur(String id, String message) =>
      (update(echantillonsLocaux)..where((t) => t.id.equals(id))).write(
        EchantillonsLocauxCompanion(
          statutSync: const Value(_erreur),
          messageErreurSync: Value(message),
        ),
      );

  Future<void> incrementerTentativesEchantillon(String id) async {
    final ligne = await obtenirEchantillon(id);
    if (ligne == null) return;
    await (update(echantillonsLocaux)..where((t) => t.id.equals(id))).write(
      EchantillonsLocauxCompanion(nombreTentativesSync: Value(ligne.nombreTentativesSync + 1)),
    );
  }

  // --- Spectres ---

  Future<void> insererSpectre(SpectresLocauxCompanion donnees) =>
      into(spectresLocaux).insertOnConflictUpdate(donnees);

  Future<SpectresLocauxData?> obtenirSpectrePourEchantillon(String echantillonId) =>
      (select(spectresLocaux)..where((t) => t.echantillonId.equals(echantillonId)))
          .getSingleOrNull();

  /// Voir obtenirEchantillonsEnAttente : inclut aussi les spectres en erreur,
  /// pour qu'un échec réseau soit retenté automatiquement.
  Future<List<SpectresLocauxData>> obtenirSpectresEnAttente() => (select(spectresLocaux)
        ..where((t) => t.statutSync.equals(_synchronise).not()))
      .get();

  Future<int> compterSpectresEnAttente() =>
      obtenirSpectresEnAttente().then((liste) => liste.length);

  Future<void> marquerSpectreSynchronise(String id) =>
      (update(spectresLocaux)..where((t) => t.id.equals(id))).write(
        const SpectresLocauxCompanion(
          statutSync: Value(_synchronise),
          messageErreurSync: Value(null),
        ),
      );

  Future<void> marquerSpectreErreur(String id, String message) =>
      (update(spectresLocaux)..where((t) => t.id.equals(id))).write(
        SpectresLocauxCompanion(statutSync: const Value(_erreur), messageErreurSync: Value(message)),
      );

  Future<void> incrementerTentativesSpectre(String id) async {
    final ligne = await (select(spectresLocaux)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (ligne == null) return;
    await (update(spectresLocaux)..where((t) => t.id.equals(id))).write(
      SpectresLocauxCompanion(nombreTentativesSync: Value(ligne.nombreTentativesSync + 1)),
    );
  }

  /// Indicateur visible "éléments en attente de synchronisation" : somme
  /// des échantillons et spectres pas encore confirmés par l'API.
  Future<int> compterElementsEnAttente() async {
    final echantillons = await compterEchantillonsEnAttente();
    final spectres = await compterSpectresEnAttente();
    return echantillons + spectres;
  }
}

const _synchronise = 'synchronise';
const _erreur = 'erreur';
