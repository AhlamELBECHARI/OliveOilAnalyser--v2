import '../../domain/entities/supervision_entity.dart';

class EtatSystemeModel extends EtatSystemeEntity {
  const EtatSystemeModel({
    required super.apiDisponible,
    required super.baseDeDonneesDisponible,
    required super.tailleBaseOctets,
    required super.dateDerniereSauvegarde,
    required super.nombreAnalyseursRecents,
  });

  factory EtatSystemeModel.fromJson(Map<String, dynamic> json) {
    return EtatSystemeModel(
      apiDisponible: json['api_disponible'] as bool,
      baseDeDonneesDisponible: json['base_de_donnees_disponible'] as bool,
      tailleBaseOctets: json['taille_base_octets'] as int,
      dateDerniereSauvegarde: json['date_derniere_sauvegarde'] == null
          ? null
          : DateTime.parse(json['date_derniere_sauvegarde'] as String),
      nombreAnalyseursRecents: json['nombre_analyseurs_recents'] as int?,
    );
  }
}

class ActiviteJourModel extends ActiviteJourEntity {
  const ActiviteJourModel({
    required super.utilisateursConnectes,
    required super.sessionsActives,
    required super.analysesAujourdHui,
    required super.analysesCetteSemaine,
    required super.variationPourcentage,
  });

  factory ActiviteJourModel.fromJson(Map<String, dynamic> json) {
    return ActiviteJourModel(
      utilisateursConnectes: json['utilisateurs_connectes'] as int,
      sessionsActives: json['sessions_actives'] as int,
      analysesAujourdHui: json['analyses_aujourd_hui'] as int,
      analysesCetteSemaine: json['analyses_cette_semaine'] as int,
      variationPourcentage: (json['variation_pourcentage'] as num?)?.toDouble(),
    );
  }
}

class AlerteSupervisionModel extends AlerteSupervisionEntity {
  const AlerteSupervisionModel({
    required super.id,
    required super.type,
    required super.message,
    required super.niveauGravite,
    required super.dateCreation,
    required super.numeroEchantillon,
  });

  factory AlerteSupervisionModel.fromJson(Map<String, dynamic> json) {
    return AlerteSupervisionModel(
      id: json['id'] as int,
      type: json['type'] as String,
      message: json['message'] as String,
      niveauGravite: json['niveau_gravite'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      numeroEchantillon: json['numero_echantillon'] as String?,
    );
  }
}

class ActiviteOperateurModel extends ActiviteOperateurEntity {
  const ActiviteOperateurModel({
    required super.utilisateurId,
    required super.nom,
    required super.email,
    required super.nombreAnalyses,
    required super.repartitionQualite,
    required super.derniereActivite,
  });

  factory ActiviteOperateurModel.fromJson(Map<String, dynamic> json) {
    return ActiviteOperateurModel(
      utilisateurId: json['utilisateur_id'] as int,
      nom: json['nom'] as String,
      email: json['email'] as String,
      nombreAnalyses: json['nombre_analyses'] as int,
      repartitionQualite: Map<String, int>.from(json['repartition_qualite'] as Map),
      derniereActivite: json['derniere_activite'] == null
          ? null
          : DateTime.parse(json['derniere_activite'] as String),
    );
  }
}

class AnomaliesModel extends AnomaliesEntity {
  const AnomaliesModel({
    required super.comptesVerrouilles,
    required super.echecsSynchronisation,
    required super.resultatsEnErreur,
    required super.modelesDepreciesReferences,
  });

  factory AnomaliesModel.fromJson(Map<String, dynamic> json) {
    return AnomaliesModel(
      comptesVerrouilles: json['comptes_verrouilles'] as int,
      echecsSynchronisation: json['echecs_synchronisation'] as int?,
      resultatsEnErreur: json['resultats_en_erreur'] as int?,
      modelesDepreciesReferences: json['modeles_deprecies_references'] as int,
    );
  }
}

class SupervisionModel extends SupervisionEntity {
  const SupervisionModel({
    required super.etatSysteme,
    required super.activiteJour,
    required super.alertesNonResolues,
    required super.activiteParOperateur,
    required super.anomalies,
  });

  factory SupervisionModel.fromJson(Map<String, dynamic> json) {
    return SupervisionModel(
      etatSysteme: EtatSystemeModel.fromJson(json['etat_systeme'] as Map<String, dynamic>),
      activiteJour: ActiviteJourModel.fromJson(json['activite_jour'] as Map<String, dynamic>),
      alertesNonResolues: (json['alertes_non_resolues'] as List)
          .map((e) => AlerteSupervisionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      activiteParOperateur: (json['activite_par_operateur'] as List)
          .map((e) => ActiviteOperateurModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      anomalies: AnomaliesModel.fromJson(json['anomalies'] as Map<String, dynamic>),
    );
  }
}
