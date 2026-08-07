import 'package:equatable/equatable.dart';

/// Miroir de comptes.models.Configuration côté backend (singleton) : seuils
/// de conformité/qualité et préférences globales. GET accessible à tout
/// utilisateur authentifié ; PUT réservé aux administrateurs (voir
/// core.permissions.IsAdministrateur côté API) — la Presentation doit donc
/// toujours prévoir l'échec de modification pour un utilisateur standard,
/// jamais supposer que le PUT réussira.
class ConfigurationEntity extends Equatable {
  final bool notificationsActives;
  final double seuilConformiteAcidite;
  final double seuilConformitePeroxyde;
  final double seuilAciditeEvoo;
  final double seuilAciditeVoo;

  const ConfigurationEntity({
    required this.notificationsActives,
    required this.seuilConformiteAcidite,
    required this.seuilConformitePeroxyde,
    required this.seuilAciditeEvoo,
    required this.seuilAciditeVoo,
  });

  @override
  List<Object?> get props => [
        notificationsActives,
        seuilConformiteAcidite,
        seuilConformitePeroxyde,
        seuilAciditeEvoo,
        seuilAciditeVoo,
      ];
}
