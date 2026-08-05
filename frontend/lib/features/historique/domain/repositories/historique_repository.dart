import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/resultat_historique_entity.dart';

abstract class HistoriqueRepository {
  Future<Either<Failure, List<ResultatHistoriqueEntity>>> listerHistorique();
  Future<Either<Failure, ResultatHistoriqueEntity>> obtenirResultat(String resultatId);
}
