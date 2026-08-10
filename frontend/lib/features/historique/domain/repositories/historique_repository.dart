import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/analyse_historique_entity.dart';
import '../entities/demande_export_entity.dart';
import '../entities/rapport_export_entity.dart';
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

  /// POST /api/analyses/export/ — génère réellement le fichier d'export.
  Future<Either<Failure, RapportExportEntity>> declencherExport(DemandeExportEntity demande);

  /// GET /api/rapports/{id}/telecharger/ — récupère les octets du fichier
  /// généré pour un rapport, à enregistrer localement.
  Future<Either<Failure, List<int>>> telechargerRapport(String rapportId);
}
