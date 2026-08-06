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
}
