import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/local_storage/local_database.dart';
import '../../../../core/sync/synchronisation_service.dart';
import '../../../analyseur/domain/entities/spectre_entity.dart';
import '../../domain/entities/nouvel_echantillon_entity.dart';
import '../../domain/entities/resultat_a_creer_entity.dart';
import '../../domain/repositories/nouvelle_analyse_repository.dart';

const _uuid = Uuid();

/// Écrit toujours d'abord dans [LocalDatabase] (Drift), puis déclenche une
/// tentative de synchronisation en arrière-plan via [SynchronisationService]
/// — sans jamais attendre son résultat ni le remonter comme échec : une
/// absence de réseau n'est jamais une erreur pour cet écran, seulement un
/// enregistrement qui reste "en attente" jusqu'au retour de la connexion.
class NouvelleAnalyseRepositoryImpl implements NouvelleAnalyseRepository {
  final LocalDatabase _base;
  final SynchronisationService _synchronisation;

  const NouvelleAnalyseRepositoryImpl({
    required LocalDatabase base,
    required SynchronisationService synchronisation,
  })  : _base = base,
        _synchronisation = synchronisation;

  @override
  Future<Either<Failure, void>> enregistrerEchantillon(NouvelEchantillonEntity echantillon) async {
    try {
      await _base.insererEchantillon(EchantillonsLocauxCompanion.insert(
        id: echantillon.id,
        numero: echantillon.numero,
        dateAnalyse: echantillon.dateAnalyse,
        producteur: Value(echantillon.producteur),
        region: Value(echantillon.region),
        dateRecolte: Value(echantillon.dateRecolte),
        latitude: Value(echantillon.latitude),
        longitude: Value(echantillon.longitude),
        variete: Value(echantillon.variete),
        origine: Value(echantillon.origine),
        notes: Value(echantillon.notes),
      ));
      unawaited(_synchronisation.synchroniser());
      return const Right(null);
    } catch (_) {
      return const Left(ErreurStockageLocalFailure());
    }
  }

  @override
  Future<Either<Failure, void>> enregistrerSpectre({
    required String echantillonId,
    required SpectreBrutEntity spectre,
  }) async {
    try {
      final valeursX = spectre.points.map((point) => point.longueurOndeNm).toList();
      final valeursY = spectre.points.map((point) => point.absorbance).toList();
      await _base.insererSpectre(SpectresLocauxCompanion.insert(
        id: _uuid.v4(),
        echantillonId: echantillonId,
        valeursXJson: jsonEncode(valeursX),
        valeursYJson: jsonEncode(valeursY),
        nombreSeries: valeursX.length,
        dateAcquisition: spectre.dateAcquisition,
      ));
      unawaited(_synchronisation.synchroniser());
      return const Right(null);
    } catch (_) {
      return const Left(ErreurStockageLocalFailure());
    }
  }

  @override
  Future<Either<Failure, void>> enregistrerResultat({
    required String resultatId,
    required String echantillonId,
    required ResultatACreerEntity resultat,
  }) async {
    try {
      final companionResultat = ResultatsLocauxCompanion.insert(
        id: resultatId,
        echantillonId: echantillonId,
        modeleUtiliseId: Value(resultat.modeleUtiliseId),
        acidite: Value(resultat.acidite),
        indicePeroxyde: Value(resultat.indicePeroxyde),
        dateCalcul: Value(DateTime.now()),
        dureeAnalyseSecondes: Value(resultat.dureeAnalyseSecondes),
        conforme: Value(resultat.conforme),
      );
      final companionsPredictions = [
        for (final prediction in resultat.predictions)
          PredictionsLocalesCompanion.insert(
            id: _uuid.v4(),
            resultatId: resultatId,
            modeleId: prediction.modeleId,
            valeurNumerique: Value(prediction.valeurNumerique),
            classePredite: Value(prediction.classePredite ?? ''),
            scoreConfiance: Value(prediction.scoreConfiance),
          ),
      ];
      await _base.insererResultat(companionResultat, companionsPredictions);
      await _mettreAJourCacheAnalyses(
        resultatId: resultatId,
        echantillonId: echantillonId,
        resultat: resultat,
      );
      unawaited(_synchronisation.synchroniser());
      return const Right(null);
    } catch (_) {
      return const Left(ErreurStockageLocalFailure());
    }
  }

  /// Fait apparaître immédiatement une analyse créée hors ligne dans le
  /// calcul local du tableau de bord/historique (voir
  /// core/local_storage/statistiques_locales_service.dart) — sans attendre
  /// un futur GET réussi. Best-effort : un échec ici ne doit jamais faire
  /// échouer l'enregistrement du résultat lui-même, déjà confirmé au-dessus.
  Future<void> _mettreAJourCacheAnalyses({
    required String resultatId,
    required String echantillonId,
    required ResultatACreerEntity resultat,
  }) async {
    if (resultat.acidite == null) return;
    try {
      final echantillon = await _base.obtenirEchantillon(echantillonId);
      if (echantillon == null) return;
      await _base.upsertAnalyseCache(AnalysesCacheCompanion.insert(
        id: resultatId,
        numeroEchantillon: Value(echantillon.numero),
        producteurEchantillon: Value(echantillon.producteur),
        varieteEchantillon: Value(echantillon.variete),
        regionEchantillon: Value(echantillon.region),
        origineEchantillon: Value(echantillon.origine),
        acidite: resultat.acidite!,
        indicePeroxyde: Value(resultat.indicePeroxyde),
        dateCalcul: DateTime.now(),
        conforme: Value(resultat.conforme),
        categorie: resultat.categorie?.name ?? 'lampante',
        dureeAnalyseSecondes: Value(resultat.dureeAnalyseSecondes),
      ));
    } catch (_) {
      // Best-effort — voir docstring.
    }
  }
}
