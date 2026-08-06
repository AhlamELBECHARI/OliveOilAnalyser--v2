import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../analyseur/domain/entities/spectre_entity.dart';
import '../entities/nouvel_echantillon_entity.dart';

/// Écriture des données produites par l'écran Nouvelle Analyse (échantillon,
/// spectre). Toujours écrit en local (Drift) EN PREMIER, avant toute
/// tentative réseau — voir data/repositories/nouvelle_analyse_repository_impl.dart.
/// La Presentation ne sait jamais si l'appareil est en ligne ou hors ligne :
/// un [Failure] ici ne signifie qu'un échec d'écriture LOCALE, jamais une
/// absence de réseau (voir core/sync/synchronisation_service.dart, seul
/// responsable de la synchronisation).
abstract class NouvelleAnalyseRepository {
  Future<Either<Failure, void>> enregistrerEchantillon(NouvelEchantillonEntity echantillon);

  Future<Either<Failure, void>> enregistrerSpectre({
    required String echantillonId,
    required SpectreBrutEntity spectre,
  });
}
