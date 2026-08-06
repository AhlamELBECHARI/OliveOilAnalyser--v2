import 'package:equatable/equatable.dart';

/// État de la connexion Bluetooth à l'analyseur spectroscopique. Les 4
/// valeurs couvrent tout le cycle de vie d'une connexion SPP : de la
/// recherche de l'appareil appairé à l'erreur (coupure, appareil absent...).
enum EtatConnexion { deconnecte, recherche, connecte, erreur }

class EtatConnexionAnalyseurEntity extends Equatable {
  final EtatConnexion etat;
  final String? messageErreur;

  const EtatConnexionAnalyseurEntity({required this.etat, this.messageErreur});

  const EtatConnexionAnalyseurEntity.deconnecte() : this(etat: EtatConnexion.deconnecte);

  const EtatConnexionAnalyseurEntity.recherche() : this(etat: EtatConnexion.recherche);

  const EtatConnexionAnalyseurEntity.connecte() : this(etat: EtatConnexion.connecte);

  const EtatConnexionAnalyseurEntity.erreur(String message)
      : this(etat: EtatConnexion.erreur, messageErreur: message);

  bool get estConnecte => etat == EtatConnexion.connecte;

  @override
  List<Object?> get props => [etat, messageErreur];
}
