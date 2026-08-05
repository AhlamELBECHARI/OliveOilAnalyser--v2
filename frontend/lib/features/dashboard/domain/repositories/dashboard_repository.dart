import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/statistiques_dashboard_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, StatistiquesDashboardEntity>> obtenirStatistiques();

  /// Nombre d'alertes non résolues de l'utilisateur (pastille de
  /// notifications) — voir alertes/views.py::AlerteViewSet (?est_resolue=false).
  Future<Either<Failure, int>> compterAlertesNonResolues();
}
