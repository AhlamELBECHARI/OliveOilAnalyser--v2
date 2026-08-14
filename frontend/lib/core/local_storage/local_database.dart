import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/echantillons_locaux_table.dart';
import 'tables/predictions_locales_table.dart';
import 'tables/resultats_locaux_table.dart';
import 'tables/spectres_locaux_table.dart';

part 'local_database.g.dart';

/// Base SQLite locale (Drift) : toute analyse (échantillon, spectre,
/// résultat) y est TOUJOURS écrite en premier, avant toute tentative
/// réseau — voir features/analyseur (acquisition) et
/// core/sync/synchronisation_service.dart (envoi vers l'API). Aucune
/// logique de synchronisation ici : uniquement des requêtes CRUD/lecture.
@DriftDatabase(
  tables: [EchantillonsLocaux, SpectresLocaux, ResultatsLocaux, PredictionsLocales],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor]) : super(executor ?? _ouvrirConnexion());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 -> v2 : ajout de PredictionsLocales (ResultatsLocaux existait
          // déjà en v1, réservée mais non alimentée) — table nouvelle
          // uniquement, rien à migrer sur les données existantes.
          if (from < 2) {
            await m.createTable(predictionsLocales);
          }
        },
      );

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

  // --- Résultats et leurs prédictions par modèle ---

  /// Écrit le résultat ET ses prédictions dans une seule transaction : soit
  /// les deux sont visibles, soit aucun (jamais un résultat orphelin sans
  /// ses lignes de prédiction en cas d'interruption).
  Future<void> insererResultat(
    ResultatsLocauxCompanion resultat,
    List<PredictionsLocalesCompanion> predictions,
  ) async {
    await transaction(() async {
      await into(resultatsLocaux).insertOnConflictUpdate(resultat);
      for (final prediction in predictions) {
        await into(predictionsLocales).insertOnConflictUpdate(prediction);
      }
    });
  }

  Future<ResultatsLocauxData?> obtenirResultat(String id) =>
      (select(resultatsLocaux)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Version réactive de [obtenirResultat], utilisée par l'étape Résultats
  /// pour refléter en direct le passage "en attente" → "synchronisé" de
  /// l'indicateur de synchronisation, sans avoir à re-solliciter le réseau.
  Stream<ResultatsLocauxData?> observerResultat(String id) =>
      (select(resultatsLocaux)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<List<PredictionsLocalesData>> obtenirPredictionsPourResultat(String resultatId) =>
      (select(predictionsLocales)..where((t) => t.resultatId.equals(resultatId))).get();

  /// Voir obtenirEchantillonsEnAttente : inclut aussi les résultats en
  /// erreur, pour qu'un échec réseau soit retenté automatiquement.
  Future<List<ResultatsLocauxData>> obtenirResultatsEnAttente() => (select(resultatsLocaux)
        ..where((t) => t.statutSync.equals(_synchronise).not()))
      .get();

  Future<int> compterResultatsEnAttente() =>
      obtenirResultatsEnAttente().then((liste) => liste.length);

  Future<void> marquerResultatSynchronise(String id) =>
      (update(resultatsLocaux)..where((t) => t.id.equals(id))).write(
        const ResultatsLocauxCompanion(
          statutSync: Value(_synchronise),
          messageErreurSync: Value(null),
        ),
      );

  Future<void> marquerResultatErreur(String id, String message) =>
      (update(resultatsLocaux)..where((t) => t.id.equals(id))).write(
        ResultatsLocauxCompanion(statutSync: const Value(_erreur), messageErreurSync: Value(message)),
      );

  Future<void> incrementerTentativesResultat(String id) async {
    final ligne = await obtenirResultat(id);
    if (ligne == null) return;
    await (update(resultatsLocaux)..where((t) => t.id.equals(id))).write(
      ResultatsLocauxCompanion(nombreTentativesSync: Value(ligne.nombreTentativesSync + 1)),
    );
  }

  /// Indicateur visible "éléments en attente de synchronisation" : somme
  /// des échantillons, spectres et résultats pas encore confirmés par l'API.
  Future<int> compterElementsEnAttente() async {
    final echantillons = await compterEchantillonsEnAttente();
    final spectres = await compterSpectresEnAttente();
    final resultats = await compterResultatsEnAttente();
    return echantillons + spectres + resultats;
  }
}

const _synchronise = 'synchronise';
const _erreur = 'erreur';
