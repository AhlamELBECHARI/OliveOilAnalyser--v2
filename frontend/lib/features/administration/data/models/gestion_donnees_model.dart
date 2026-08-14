import '../../domain/entities/gestion_donnees_entity.dart';

class StatistiquesOccupationModel extends StatistiquesOccupationEntity {
  const StatistiquesOccupationModel({
    required super.echantillons,
    required super.spectres,
    required super.resultats,
    required super.modeles,
    required super.utilisateurs,
    required super.tailleBaseOctets,
  });

  factory StatistiquesOccupationModel.fromJson(Map<String, dynamic> json) {
    return StatistiquesOccupationModel(
      echantillons: json['echantillons'] as int,
      spectres: json['spectres'] as int,
      resultats: json['resultats'] as int,
      modeles: json['modeles'] as int,
      utilisateurs: json['utilisateurs'] as int,
      tailleBaseOctets: json['taille_base_octets'] as int,
    );
  }
}

class PurgeApercuModel extends PurgeApercuEntity {
  const PurgeApercuModel({
    required super.echantillonsASupprimer,
    required super.spectresASupprimer,
    required super.resultatsASupprimer,
  });

  factory PurgeApercuModel.fromJson(Map<String, dynamic> json) {
    return PurgeApercuModel(
      echantillonsASupprimer: json['echantillons_a_supprimer'] as int,
      spectresASupprimer: json['spectres_a_supprimer'] as int,
      resultatsASupprimer: json['resultats_a_supprimer'] as int,
    );
  }
}
