import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../analyseur/domain/entities/etat_connexion_analyseur_entity.dart';
import '../../../analyseur/domain/repositories/analyseur_repository.dart';
import '../entities/etat_analyseur_entity.dart';

/// Construit l'état affiché par la carte "État du laboratoire" du dashboard
/// à partir de la même source que l'écran Nouvelle Analyse
/// ([AnalyseurRepository]) — plus de deuxième état Bluetooth fictif et
/// potentiellement incohérent : dashboard et écran d'analyse reflètent
/// toujours la même connexion réelle.
class ObtenirEtatAnalyseurUseCase implements UseCase<EtatAnalyseurEntity, NoParams> {
  final AnalyseurRepository repository;

  const ObtenirEtatAnalyseurUseCase(this.repository);

  @override
  Future<Either<Failure, EtatAnalyseurEntity>> call(NoParams params) async {
    final etatConnexion = await repository.flusEtatConnexion.first;
    final infoAppareil = await repository.obtenirInfoAppareil();

    return Right(EtatAnalyseurEntity(
      appareilConnecte: etatConnexion.estConnecte,
      nomAppareil: infoAppareil?.nom,
      // Pas de distinction radio-Bluetooth / appareil-connecté côté
      // AnalyseurRepository : le Bluetooth est considéré actif dès qu'une
      // recherche ou une connexion est en cours.
      bluetoothActif: etatConnexion.etat != EtatConnexion.deconnecte,
      niveauBatteriePourcentage: infoAppareil?.niveauBatteriePourcentage,
      // Aucune vraie source de "dernière synchronisation" pour l'instant
      // (viendra du service de synchronisation hors ligne) : jamais de
      // valeur fabriquée ici, on affiche l'absence plutôt qu'une fausse date.
      derniereSynchronisation: null,
    ));
  }
}
