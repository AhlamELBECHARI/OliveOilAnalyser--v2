import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/analyse_historique_entity.dart';
import '../entities/resultat_historique_entity.dart';
import '../entities/statistiques_rapides_entity.dart';

abstract class HistoriqueRepository {
  /// GET /api/analyses/historique/ — recherche, filtres et tri appliqués
  /// entièrement côté serveur (voir analyses.services.rechercher_historique).
  Future<Either<Failure, PageAnalysesHistorique>> listerAnalyses({
    required int page,
    FiltresHistorique filtres = const FiltresHistorique(),
  });

  /// GET /api/analyses/statistiques-rapides/
  Future<Either<Failure, StatistiquesRapidesEntity>> obtenirStatistiquesRapides();

  /// GET /api/resultats/{id}/ — écran de détail, inchangé.
  Future<Either<Failure, ResultatHistoriqueEntity>> obtenirResultat(String resultatId);

  /// POST /api/analyses/export/ — déclenche la génération d'un rapport.
  Future<Either<Failure, void>> declencherExport(String format);
}
