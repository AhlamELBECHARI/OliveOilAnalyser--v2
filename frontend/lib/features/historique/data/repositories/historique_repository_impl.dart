import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' show Value;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/local_storage/local_database.dart';
import '../../../../core/local_storage/statistiques_locales_service.dart';
import '../../domain/entities/analyse_historique_entity.dart';
import '../../domain/entities/demande_export_entity.dart';
import '../../domain/entities/rapport_export_entity.dart';
import '../../domain/entities/resultat_historique_entity.dart';
import '../../domain/entities/spectre_historique_entity.dart';
import '../../domain/entities/statistiques_rapides_entity.dart';
import '../../domain/repositories/historique_repository.dart';
import '../datasources/historique_remote_datasource.dart';

const _taillePage = 20;

class HistoriqueRepositoryImpl implements HistoriqueRepository {
  final HistoriqueRemoteDataSource remoteDataSource;
  final LocalDatabase localDatabase;
  final StatistiquesLocalesService statistiquesLocales;

  const HistoriqueRepositoryImpl({
    required this.remoteDataSource,
    required this.localDatabase,
    required this.statistiquesLocales,
  });

  @override
  Future<Either<Failure, PageAnalysesHistorique>> listerAnalyses({
    required int page,
    FiltresHistorique filtres = const FiltresHistorique(),
  }) async {
    try {
      final resultat = await remoteDataSource.listerAnalyses(page: page, filtres: filtres);
      await _mettreEnCache(resultat.analyses);
      return Right(PageAnalysesHistorique(
        analyses: resultat.analyses,
        aPageSuivante: resultat.aPageSuivante,
        total: resultat.total,
      ));
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return _listerAnalysesDepuisCache(page: page, filtres: filtres);
    }
  }

  /// Repli hors ligne : reconstitue une page depuis [AnalysesCache], en
  /// appliquant les mêmes filtres que rechercher_historique côté backend,
  /// entièrement en local — jamais un écran vide faute de réseau (cahier
  /// des charges, Partie A, section 2).
  Future<Either<Failure, PageAnalysesHistorique>> _listerAnalysesDepuisCache({
    required int page,
    required FiltresHistorique filtres,
  }) async {
    try {
      var lignes = await localDatabase.obtenirAnalysesCache();
      final recherche = filtres.recherche?.trim().toLowerCase();
      if (recherche != null && recherche.isNotEmpty) {
        lignes = lignes
            .where((a) =>
                a.numeroEchantillon.toLowerCase().contains(recherche) ||
                a.producteurEchantillon.toLowerCase().contains(recherche) ||
                a.varieteEchantillon.toLowerCase().contains(recherche) ||
                a.regionEchantillon.toLowerCase().contains(recherche))
            .toList();
      }
      if (filtres.qualite != null) {
        lignes = lignes.where((a) => a.categorie == filtres.qualite).toList();
      }
      if (filtres.variete != null && filtres.variete!.isNotEmpty) {
        lignes = lignes
            .where((a) => a.varieteEchantillon.toLowerCase() == filtres.variete!.toLowerCase())
            .toList();
      }
      if (filtres.region != null && filtres.region!.isNotEmpty) {
        lignes = lignes
            .where((a) => a.regionEchantillon.toLowerCase() == filtres.region!.toLowerCase())
            .toList();
      }
      if (filtres.operateur != null) {
        lignes = lignes.where((a) => a.auteurId == filtres.operateur).toList();
      }
      if (filtres.dateDebut != null) {
        lignes = lignes.where((a) => !a.dateCalcul.isBefore(filtres.dateDebut!)).toList();
      }
      if (filtres.dateFin != null) {
        final finInclusive = filtres.dateFin!.add(const Duration(days: 1));
        lignes = lignes.where((a) => a.dateCalcul.isBefore(finInclusive)).toList();
      }

      lignes.sort((a, b) => b.dateCalcul.compareTo(a.dateCalcul));
      final total = lignes.length;
      final debut = (page - 1) * _taillePage;
      final fin = (debut + _taillePage).clamp(0, total);
      final pageLignes = debut >= total ? <AnalyseCacheData>[] : lignes.sublist(debut, fin);

      return Right(PageAnalysesHistorique(
        analyses: pageLignes.map(_versEntity).toList(),
        aPageSuivante: fin < total,
        total: total,
      ));
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  AnalyseHistoriqueEntity _versEntity(AnalyseCacheData a) => AnalyseHistoriqueEntity(
        id: a.id,
        numeroEchantillon: a.numeroEchantillon,
        producteurEchantillon: a.producteurEchantillon,
        varieteEchantillon: a.varieteEchantillon,
        regionEchantillon: a.regionEchantillon,
        origineEchantillon: a.origineEchantillon,
        acidite: a.acidite,
        indicePeroxyde: a.indicePeroxyde ?? 0,
        dateCalcul: a.dateCalcul,
        conforme: a.conforme,
        categorie: categorieQualiteHistoriqueDepuisCode(a.categorie),
        auteurId: a.auteurId,
        auteurNom: a.auteurNom,
      );

  Future<void> _mettreEnCache(List<AnalyseHistoriqueEntity> analyses) async {
    try {
      await localDatabase.upsertAnalysesCache([
        for (final a in analyses)
          AnalysesCacheCompanion.insert(
            id: a.id,
            numeroEchantillon: Value(a.numeroEchantillon),
            producteurEchantillon: Value(a.producteurEchantillon),
            varieteEchantillon: Value(a.varieteEchantillon),
            regionEchantillon: Value(a.regionEchantillon),
            origineEchantillon: Value(a.origineEchantillon),
            acidite: a.acidite,
            indicePeroxyde: Value(a.indicePeroxyde),
            dateCalcul: a.dateCalcul,
            conforme: Value(a.conforme),
            categorie: _codeCategorie(a.categorie),
            auteurId: Value(a.auteurId),
            auteurNom: Value(a.auteurNom),
          ),
      ]);
    } catch (_) {
      // Best-effort : une écriture cache ratée ne doit jamais faire échouer
      // l'affichage des données fraîchement reçues du serveur.
    }
  }

  String _codeCategorie(CategorieQualiteHistorique categorie) {
    switch (categorie) {
      case CategorieQualiteHistorique.evoo:
        return 'evoo';
      case CategorieQualiteHistorique.voo:
        return 'voo';
      case CategorieQualiteHistorique.lampante:
        return 'lampante';
    }
  }

  @override
  Future<Either<Failure, StatistiquesRapidesEntity>> obtenirStatistiquesRapides() async {
    try {
      return Right(await remoteDataSource.obtenirStatistiquesRapides());
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      try {
        return Right(await statistiquesLocales.statistiquesRapidesHistorique());
      } catch (_) {
        return const Left(ErreurReseauFailure());
      }
    }
  }

  @override
  Future<Either<Failure, ResultatHistoriqueEntity>> obtenirResultat(String resultatId) async {
    try {
      final resultat = await remoteDataSource.obtenirResultat(resultatId);
      return Right(resultat);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, SpectreHistoriqueEntity?>> obtenirSpectrePourEchantillon(
    String echantillonId,
  ) async {
    try {
      return Right(await remoteDataSource.obtenirSpectrePourEchantillon(echantillonId));
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, RapportExportEntity>> declencherExport(DemandeExportEntity demande) async {
    try {
      final rapport = await remoteDataSource.declencherExport(demande);
      return Right(rapport);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, List<int>>> telechargerRapport(String rapportId) async {
    try {
      final octets = await remoteDataSource.telechargerRapport(rapportId);
      return Right(octets);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, void>> supprimerResultat(String resultatId) async {
    try {
      await remoteDataSource.supprimerResultat(resultatId);
      return const Right(null);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }

  @override
  Future<Either<Failure, void>> modifierEchantillon({
    required String echantillonId,
    required String producteur,
    required String variete,
    required String region,
  }) async {
    try {
      await remoteDataSource.modifierEchantillon(
        echantillonId: echantillonId,
        producteur: producteur,
        variete: variete,
        region: region,
      );
      return const Right(null);
    } on ErreurValidationException {
      return const Left(ErreurValidationFailure());
    } on ErreurServeurException {
      return const Left(ErreurServeurFailure());
    } catch (_) {
      return const Left(ErreurReseauFailure());
    }
  }
}
