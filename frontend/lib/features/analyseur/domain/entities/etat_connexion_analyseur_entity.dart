import 'package:equatable/equatable.dart';

/// État de la connexion Bluetooth à l'analyseur spectroscopique. Les 4
/// valeurs couvrent tout le cycle de vie d'une connexion SPP : de la
/// recherche de l'appareil appairé à l'erreur (coupure, appareil absent...).
enum EtatConnexion { deconnecte, recherche, connecte, erreur }

/// Cause précise d'un échec de connexion — permet à l'écran d'afficher un
/// bouton d'action adapté (ouvrir les réglages, activer le Bluetooth...)
/// plutôt qu'un message générique. `null`/[inconnue] quand la cause n'a pas
/// pu être déterminée (ex. appareil hors de portée).
enum CauseEchecConnexion {
  /// Une ou plusieurs permissions requises ont été refusées, mais peuvent
  /// encore être redemandées (l'utilisateur n'a pas coché "ne plus
  /// demander").
  permissionRefusee,

  /// Permission refusée définitivement ("Ne plus demander" côché, ou déjà
  /// refusée deux fois sur Android) : redemander via le système ne
  /// déclenchera plus aucune boîte de dialogue, seul un passage par les
  /// réglages de l'application peut y remédier.
  permissionRefuseeDefinitivement,

  /// L'adaptateur Bluetooth du téléphone est désactivé.
  bluetoothDesactive,

  /// Le service de localisation du téléphone est désactivé — requis par la
  /// découverte Bluetooth Classic sur Android 11 et antérieur uniquement.
  localisationDesactivee,

  /// Aucun appareil appairé ne correspond à la configuration attendue.
  appareilIntrouvable,

  /// Cause technique non catégorisée (coupure, timeout de connexion...).
  autre,
}

/// Exception porteuse d'une [CauseEchecConnexion] structurée — utilisée par
/// AnalyseurRepository.decouvrirAppareilsProximite (un Stream propage ses
/// échecs par exception, pas par état) pour que la Presentation puisse y
/// afficher le même bouton d'action que pour un échec de connexion.
class ErreurBluetooth implements Exception {
  final String message;
  final CauseEchecConnexion cause;

  const ErreurBluetooth(this.message, this.cause);

  @override
  String toString() => message;
}

class EtatConnexionAnalyseurEntity extends Equatable {
  final EtatConnexion etat;
  final String? messageErreur;
  final CauseEchecConnexion? causeEchec;

  const EtatConnexionAnalyseurEntity({required this.etat, this.messageErreur, this.causeEchec});

  const EtatConnexionAnalyseurEntity.deconnecte() : this(etat: EtatConnexion.deconnecte);

  const EtatConnexionAnalyseurEntity.recherche() : this(etat: EtatConnexion.recherche);

  const EtatConnexionAnalyseurEntity.connecte() : this(etat: EtatConnexion.connecte);

  const EtatConnexionAnalyseurEntity.erreur(String message, {CauseEchecConnexion? cause})
      : this(etat: EtatConnexion.erreur, messageErreur: message, causeEchec: cause);

  bool get estConnecte => etat == EtatConnexion.connecte;

  @override
  List<Object?> get props => [etat, messageErreur, causeEchec];
}
