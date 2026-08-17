import '../../features/configuration/domain/entities/configuration_entity.dart';

enum CategorieQualiteHuile { evoo, voo, lampante }

/// Classification EVOO/VOO/Lampante à partir de l'acidité et des seuils de
/// [ConfigurationEntity]. SEULE implémentation de cette règle métier côté
/// app — utilisée aussi bien pour l'affichage immédiat pendant une analyse
/// (voir nouvelle_analyse/presentation/widgets/etape_resultats.dart) que
/// pour le calcul agrégé des statistiques locales hors ligne (voir
/// core/local_storage/statistiques_locales_service.dart), afin qu'un même
/// échantillon soit toujours classé de façon identique quel que soit le
/// chemin — jamais dupliquée ailleurs.
CategorieQualiteHuile classifierAcidite({
  required double acidite,
  required ConfigurationEntity configuration,
}) {
  if (acidite <= configuration.seuilAciditeEvoo) return CategorieQualiteHuile.evoo;
  if (acidite <= configuration.seuilAciditeVoo) return CategorieQualiteHuile.voo;
  return CategorieQualiteHuile.lampante;
}
