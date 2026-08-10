import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/modele_entity.dart';

abstract class ModelesRepository {
  Future<Either<Failure, List<ModeleEntity>>> listerModeles();

  /// POST /api/modeles/ — réservé aux administrateurs côté backend.
  Future<Either<Failure, ModeleEntity>> creerModele({
    required String nom,
    required String version,
    required String algorithme,
    required Map<String, dynamic> hyperparametres,
    required double r2,
    required double rmsecv,
    DateTime? dateEntrainement,
  });

  /// PATCH /api/modeles/{id}/ (multipart) — associe le fichier de modèle
  /// entraîné après création (voir modeles.serializers.ModeleSerializer côté
  /// backend : extension/taille validées, jamais désérialisé).
  Future<Either<Failure, ModeleEntity>> televerserFichierModele({
    required int modeleId,
    required String cheminFichier,
    required String nomFichier,
  });

  /// PATCH /api/modeles/{id}/ — activer/désactiver ou (dé)marquer comme
  /// déprécié un modèle existant.
  Future<Either<Failure, ModeleEntity>> modifierStatutModele({
    required int modeleId,
    bool? estActif,
    bool? estDeprecie,
  });
}
