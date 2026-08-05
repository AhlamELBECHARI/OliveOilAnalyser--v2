import '../../features/dashboard/domain/entities/etat_analyseur_entity.dart';
import '../../features/dashboard/domain/entities/statistiques_dashboard_entity.dart';

/// Statistiques factices affichées par le dashboard en Mode démo : aucun
/// appel réseau, aucune dépendance à dashboard.data/domain.usecases.
///
/// ATTENTION : ce dossier `core/demo/` est isolé du reste de l'application
/// (voir demo_fake_data.dart) pour pouvoir être supprimé intégralement sans
/// effet de bord le jour où le Mode démo sera retiré.
class DemoDashboardData {
  const DemoDashboardData._();

  static StatistiquesDashboardEntity statistiques() {
    final aujourdHui = DateTime.now();
    final valeursSerie = [14, 18, 11, 9, 23, 30, 8];

    return StatistiquesDashboardEntity(
      nomUtilisateur: 'Laboratoire Démo',
      analysesCeMois: const MetriqueAvecVariationEntity(valeur: 156, variationPourcentage: 18.4),
      echantillonsTotaux: const EchantillonsTotauxEntity(valeur: 12458, ajoutsCeMois: 3245),
      analysesAujourdHui: const MetriqueAvecVariationEntity(valeur: 8, variationPourcentage: 14),
      tempsMoyenParAnalyse: const TempsMoyenEntity(valeur: 3.7, variationPourcentage: -8),
      serie7Jours: [
        for (var i = 0; i < valeursSerie.length; i++)
          PointSerieEntity(
            date: aujourdHui.subtract(Duration(days: valeursSerie.length - 1 - i)),
            nombreAnalyses: valeursSerie[i],
          ),
      ],
      repartitionQualite: const [
        RepartitionQualiteEntity(
          categorie: CategorieQualite.evoo,
          libelle: 'Extra Vierge (EVOO)',
          effectif: 97,
          pourcentage: 62.2,
        ),
        RepartitionQualiteEntity(
          categorie: CategorieQualite.voo,
          libelle: 'Vierge (VOO)',
          effectif: 38,
          pourcentage: 24.4,
        ),
        RepartitionQualiteEntity(
          categorie: CategorieQualite.lampante,
          libelle: 'Lampante',
          effectif: 21,
          pourcentage: 13.4,
        ),
      ],
      analysesRecentes: const [
        AnalyseRecenteEntity(
          numero: 'SMP-2026-01246',
          origine: 'Domaine Alami',
          variete: 'Picholine',
          heure: '09:32',
          categorie: CategorieQualite.evoo,
        ),
        AnalyseRecenteEntity(
          numero: 'SMP-2026-01245',
          origine: 'Coopérative Saada',
          variete: 'Arbequina',
          heure: '08:57',
          categorie: CategorieQualite.voo,
        ),
        AnalyseRecenteEntity(
          numero: 'SMP-2026-01244',
          origine: 'Domaine Atlas',
          variete: 'Koroneiki',
          heure: '08:15',
          categorie: CategorieQualite.lampante,
        ),
      ],
    );
  }

  static EtatAnalyseurEntity etatAnalyseur() {
    return EtatAnalyseurEntity(
      appareilConnecte: true,
      nomAppareil: 'UM6P-Spectrometer-01',
      bluetoothActif: true,
      niveauBatteriePourcentage: 87,
      derniereSynchronisation: DateTime.now().subtract(const Duration(minutes: 5)),
    );
  }

  static const int alertesNonLues = 2;
}
