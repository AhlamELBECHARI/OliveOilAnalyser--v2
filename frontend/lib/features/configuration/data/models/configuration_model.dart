import '../../domain/entities/configuration_entity.dart';

class ConfigurationModel extends ConfigurationEntity {
  const ConfigurationModel({
    required super.notificationsActives,
    required super.seuilConformiteAcidite,
    required super.seuilConformitePeroxyde,
    required super.seuilAciditeEvoo,
    required super.seuilAciditeVoo,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationModel(
      notificationsActives: json['notifications_actives'] as bool,
      seuilConformiteAcidite: double.parse(json['seuil_conformite_acidite'] as String),
      seuilConformitePeroxyde: double.parse(json['seuil_conformite_peroxyde'] as String),
      seuilAciditeEvoo: double.parse(json['seuil_acidite_evoo'] as String),
      seuilAciditeVoo: double.parse(json['seuil_acidite_voo'] as String),
    );
  }

  factory ConfigurationModel.depuisEntite(ConfigurationEntity entite) {
    return ConfigurationModel(
      notificationsActives: entite.notificationsActives,
      seuilConformiteAcidite: entite.seuilConformiteAcidite,
      seuilConformitePeroxyde: entite.seuilConformitePeroxyde,
      seuilAciditeEvoo: entite.seuilAciditeEvoo,
      seuilAciditeVoo: entite.seuilAciditeVoo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications_actives': notificationsActives,
      'seuil_conformite_acidite': seuilConformiteAcidite.toStringAsFixed(3),
      'seuil_conformite_peroxyde': seuilConformitePeroxyde.toStringAsFixed(3),
      'seuil_acidite_evoo': seuilAciditeEvoo.toStringAsFixed(3),
      'seuil_acidite_voo': seuilAciditeVoo.toStringAsFixed(3),
    };
  }
}
