import 'package:equatable/equatable.dart';

class EtatSystemeEntity extends Equatable {
  final bool apiDisponible;
  final bool baseDeDonneesDisponible;
  final int tailleBaseOctets;
  // `null` si l'information n'existe pas côté serveur (aucun système de
  // sauvegarde/télémétrie automatisé n'est en place) — jamais une valeur
  // inventée, voir administration.services côté backend.
  final DateTime? dateDerniereSauvegarde;
  final int? nombreAnalyseursRecents;

  const EtatSystemeEntity({
    required this.apiDisponible,
    required this.baseDeDonneesDisponible,
    required this.tailleBaseOctets,
    required this.dateDerniereSauvegarde,
    required this.nombreAnalyseursRecents,
  });

  @override
  List<Object?> get props => [
        apiDisponible,
        baseDeDonneesDisponible,
        tailleBaseOctets,
        dateDerniereSauvegarde,
        nombreAnalyseursRecents,
      ];
}

class ActiviteJourEntity extends Equatable {
  final int utilisateursConnectes;
  final int sessionsActives;
  final int analysesAujourdHui;
  final int analysesCetteSemaine;
  final double? variationPourcentage;

  const ActiviteJourEntity({
    required this.utilisateursConnectes,
    required this.sessionsActives,
    required this.analysesAujourdHui,
    required this.analysesCetteSemaine,
    required this.variationPourcentage,
  });

  @override
  List<Object?> get props => [
        utilisateursConnectes,
        sessionsActives,
        analysesAujourdHui,
        analysesCetteSemaine,
        variationPourcentage,
      ];
}

class AlerteSupervisionEntity extends Equatable {
  final int id;
  final String type;
  final String message;
  final String niveauGravite;
  final DateTime dateCreation;
  final String? numeroEchantillon;

  const AlerteSupervisionEntity({
    required this.id,
    required this.type,
    required this.message,
    required this.niveauGravite,
    required this.dateCreation,
    required this.numeroEchantillon,
  });

  @override
  List<Object?> get props => [id, type, message, niveauGravite, dateCreation, numeroEchantillon];
}

class ActiviteOperateurEntity extends Equatable {
  final int utilisateurId;
  final String nom;
  final String email;
  final int nombreAnalyses;
  final Map<String, int> repartitionQualite;
  final DateTime? derniereActivite;

  const ActiviteOperateurEntity({
    required this.utilisateurId,
    required this.nom,
    required this.email,
    required this.nombreAnalyses,
    required this.repartitionQualite,
    required this.derniereActivite,
  });

  @override
  List<Object?> get props =>
      [utilisateurId, nom, email, nombreAnalyses, repartitionQualite, derniereActivite];
}

class AnomaliesEntity extends Equatable {
  final int comptesVerrouilles;
  final int? echecsSynchronisation;
  final int? resultatsEnErreur;
  final int modelesDepreciesReferences;

  const AnomaliesEntity({
    required this.comptesVerrouilles,
    required this.echecsSynchronisation,
    required this.resultatsEnErreur,
    required this.modelesDepreciesReferences,
  });

  @override
  List<Object?> get props =>
      [comptesVerrouilles, echecsSynchronisation, resultatsEnErreur, modelesDepreciesReferences];
}

class SupervisionEntity extends Equatable {
  final EtatSystemeEntity etatSysteme;
  final ActiviteJourEntity activiteJour;
  final List<AlerteSupervisionEntity> alertesNonResolues;
  final List<ActiviteOperateurEntity> activiteParOperateur;
  final AnomaliesEntity anomalies;

  const SupervisionEntity({
    required this.etatSysteme,
    required this.activiteJour,
    required this.alertesNonResolues,
    required this.activiteParOperateur,
    required this.anomalies,
  });

  @override
  List<Object?> get props =>
      [etatSysteme, activiteJour, alertesNonResolues, activiteParOperateur, anomalies];
}
