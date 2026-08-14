import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/gestion_donnees_entity.dart';
import '../entities/journal_audit_entity.dart';
import '../entities/supervision_entity.dart';

class PageJournalAudit {
  final List<JournalAuditEntity> entrees;
  final bool aPageSuivante;
  final int total;

  const PageJournalAudit({required this.entrees, required this.aPageSuivante, required this.total});
}

abstract class AdministrationRepository {
  /// GET /api/admin/supervision/ — écran d'accueil admin, une seule requête.
  Future<Either<Failure, SupervisionEntity>> obtenirSupervision();

  /// POST /api/alertes/{id}/resoudre/
  Future<Either<Failure, void>> resoudreAlerte(int alerteId);

  /// GET /api/admin/journal-audit/
  Future<Either<Failure, PageJournalAudit>> listerJournalAudit({required int page});

  /// GET /api/admin/donnees/statistiques/
  Future<Either<Failure, StatistiquesOccupationEntity>> obtenirStatistiquesOccupation();

  /// POST /api/admin/donnees/purge/apercu/ — ne supprime rien.
  Future<Either<Failure, PurgeApercuEntity>> previsualiserPurge(DateTime dateLimite);

  /// POST /api/admin/donnees/purge/ — suppression réelle et irréversible.
  Future<Either<Failure, void>> executerPurge(DateTime dateLimite);
}
