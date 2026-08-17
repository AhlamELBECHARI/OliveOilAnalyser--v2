import '../../features/dashboard/domain/entities/statistiques_dashboard_entity.dart';
import '../../features/historique/domain/entities/analyse_historique_entity.dart';
import '../../features/historique/domain/entities/statistiques_rapides_entity.dart';
import 'local_database.dart';

const _nombreJoursTendance = 14;
const _nombreJoursFrequence = 30;
const _nombreAnalysesRecentes = 5;

// Mêmes libellés que backend.core.qualite.LIBELLES_CATEGORIE — jamais
// traduits ni côté serveur ni ici (voir carte_apercu_historique.dart, qui
// affiche déjà ce champ brut tel quel), pour rester cohérent que les
// chiffres viennent du serveur ou de ce calcul local.
const _libellesCategorie = {
  'evoo': 'Extra Vierge (EVOO)',
  'voo': 'Vierge (VOO)',
  'lampante': 'Lampante',
};

/// Recalcule localement, à partir du cache [AnalysesCache], les mêmes
/// agrégations que dashboard.services.obtenir_statistiques et
/// analyses.services.obtenir_statistiques_rapides côté backend — utilisé
/// uniquement en repli hors ligne (voir DashboardRepositoryImpl et
/// HistoriqueRepositoryImpl), jamais quand le serveur est joignable. Ne
/// recalcule JAMAIS la catégorie qualité elle-même : celle-ci est déjà
/// résolue une fois pour toutes à l'écriture de chaque ligne du cache (voir
/// core/domain/classification_qualite.dart), pour ne jamais dupliquer cette
/// règle métier.
class StatistiquesLocalesService {
  final LocalDatabase _base;

  const StatistiquesLocalesService({required LocalDatabase base}) : _base = base;

  Future<StatistiquesDashboardEntity> statistiquesDashboard({
    required String nomUtilisateur,
  }) async {
    final toutes = await _base.obtenirAnalysesCache();
    final maintenant = DateTime.now();
    final aujourdHui = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final hier = aujourdHui.subtract(const Duration(days: 1));
    final debutMoisCourant = DateTime(maintenant.year, maintenant.month, 1);
    final debutMoisPrecedent = maintenant.month == 1
        ? DateTime(maintenant.year - 1, 12, 1)
        : DateTime(maintenant.year, maintenant.month - 1, 1);

    bool leMemeJour(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final moisCourant = toutes.where((a) => !a.dateCalcul.isBefore(debutMoisCourant)).toList();
    final moisPrecedent = toutes
        .where((a) =>
            !a.dateCalcul.isBefore(debutMoisPrecedent) && a.dateCalcul.isBefore(debutMoisCourant))
        .toList();
    final analysesAujourdHui = toutes.where((a) => leMemeJour(a.dateCalcul, aujourdHui)).length;
    final analysesHier = toutes.where((a) => leMemeJour(a.dateCalcul, hier)).length;

    final dureesMoisCourant =
        moisCourant.map((a) => a.dureeAnalyseSecondes).whereType<int>().toList();
    final dureesMoisPrecedent =
        moisPrecedent.map((a) => a.dureeAnalyseSecondes).whereType<int>().toList();

    final serie7Jours = <PointSerieEntity>[];
    for (var i = 6; i >= 0; i--) {
      final jour = aujourdHui.subtract(Duration(days: i));
      serie7Jours.add(PointSerieEntity(
        date: jour,
        nombreAnalyses: toutes.where((a) => leMemeJour(a.dateCalcul, jour)).length,
      ));
    }

    final recentes = [...toutes]..sort((a, b) => b.dateCalcul.compareTo(a.dateCalcul));

    return StatistiquesDashboardEntity(
      nomUtilisateur: nomUtilisateur,
      analysesCeMois: MetriqueAvecVariationEntity(
        valeur: moisCourant.length,
        variationPourcentage: _variationPourcentage(moisCourant.length, moisPrecedent.length),
      ),
      echantillonsTotaux: EchantillonsTotauxEntity(
        valeur: toutes.length,
        ajoutsCeMois: moisCourant.length,
      ),
      analysesAujourdHui: MetriqueAvecVariationEntity(
        valeur: analysesAujourdHui,
        variationPourcentage: _variationPourcentage(analysesAujourdHui, analysesHier),
      ),
      tempsMoyenParAnalyse: TempsMoyenEntity(
        valeur: _moyenne(dureesMoisCourant.map((s) => s / 60).toList()),
        variationPourcentage: _variationPourcentage(
          _moyenne(dureesMoisCourant.map((s) => s / 60).toList()),
          _moyenne(dureesMoisPrecedent.map((s) => s / 60).toList()),
        ),
      ),
      serie7Jours: serie7Jours,
      repartitionQualite: _repartition(moisCourant),
      analysesRecentes: recentes.take(_nombreAnalysesRecentes).map((a) {
        final heure = a.dateCalcul.hour.toString().padLeft(2, '0');
        final minute = a.dateCalcul.minute.toString().padLeft(2, '0');
        return AnalyseRecenteEntity(
          resultatId: a.id,
          numero: a.numeroEchantillon,
          origine: a.origineEchantillon,
          variete: a.varieteEchantillon,
          heure: '$heure:$minute',
          categorie: categorieQualiteDepuisCode(a.categorie),
        );
      }).toList(),
    );
  }

  Future<StatistiquesRapidesEntity> statistiquesRapidesHistorique() async {
    final toutes = await _base.obtenirAnalysesCache();
    final maintenant = DateTime.now();
    final aujourdHui = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final debutMoisCourant = DateTime(maintenant.year, maintenant.month, 1);
    final debutMoisPrecedent = maintenant.month == 1
        ? DateTime(maintenant.year - 1, 12, 1)
        : DateTime(maintenant.year, maintenant.month - 1, 1);

    final moisCourant = toutes.where((a) => !a.dateCalcul.isBefore(debutMoisCourant)).length;
    final moisPrecedent = toutes
        .where((a) =>
            !a.dateCalcul.isBefore(debutMoisPrecedent) && a.dateCalcul.isBefore(debutMoisCourant))
        .length;

    final debutTendance = aujourdHui.subtract(Duration(days: _nombreJoursTendance - 1));
    final debutTendancePrecedente = debutTendance.subtract(const Duration(days: _nombreJoursTendance));
    final finTendancePrecedente = debutTendance.subtract(const Duration(days: 1));

    final fenetreActuelle = toutes.where((a) => !a.dateCalcul.isBefore(debutTendance)).toList();
    final fenetrePrecedente = toutes
        .where((a) =>
            !a.dateCalcul.isBefore(debutTendancePrecedente) &&
            !a.dateCalcul.isAfter(finTendancePrecedente.add(const Duration(days: 1))))
        .toList();

    final acidites = fenetreActuelle.map((a) => a.acidite).toList();
    final moyenneActuelle = _moyenne(acidites);
    final moyennePrecedente = _moyenne(fenetrePrecedente.map((a) => a.acidite).toList());

    final debutFrequence = aujourdHui.subtract(Duration(days: _nombreJoursFrequence - 1));
    final nombreSurPeriode =
        toutes.where((a) => !a.dateCalcul.isBefore(debutFrequence)).length;

    return StatistiquesRapidesEntity(
      apercu: ApercuHistoriqueEntity(
        totalAnalyses: toutes.length,
        repartitionQualite: _repartitionHistorique(toutes),
        ceMois: IndicateurEntierEntity(
          valeur: moisCourant,
          variationPourcentage: _variationPourcentage(moisCourant, moisPrecedent),
        ),
      ),
      tendanceAciditeMoyenne: IndicateurAvecSerieEntity(
        valeur: moyenneActuelle,
        variationPourcentage: _variationPourcentage(moyenneActuelle, moyennePrecedente),
        serie: _serieQuotidienne(fenetreActuelle, jours: _nombreJoursTendance, agregat: _Agregat.moyenne),
      ),
      meilleureQualite: IndicateurAvecSerieEntity(
        valeur: acidites.isEmpty ? null : acidites.reduce((a, b) => a < b ? a : b),
        serie: _serieQuotidienne(fenetreActuelle, jours: _nombreJoursTendance, agregat: _Agregat.minimum),
      ),
      plusForteAcidite: IndicateurAvecSerieEntity(
        valeur: acidites.isEmpty ? null : acidites.reduce((a, b) => a > b ? a : b),
        serie: _serieQuotidienne(fenetreActuelle, jours: _nombreJoursTendance, agregat: _Agregat.maximum),
      ),
      analysesParJour: IndicateurAvecSerieEntity(
        valeur: double.parse((nombreSurPeriode / _nombreJoursFrequence).toStringAsFixed(1)),
        serie: _serieQuotidienne(
          toutes.where((a) => !a.dateCalcul.isBefore(debutFrequence)).toList(),
          jours: _nombreJoursFrequence,
          agregat: _Agregat.compte,
        ),
      ),
    );
  }

  List<RepartitionQualiteEntity> _repartition(List<AnalyseCacheData> lignes) {
    final total = lignes.length;
    return _libellesCategorie.entries.map((entry) {
      final effectif = lignes.where((a) => a.categorie == entry.key).length;
      return RepartitionQualiteEntity(
        categorie: categorieQualiteDepuisCode(entry.key),
        libelle: entry.value,
        effectif: effectif,
        pourcentage: total == 0 ? 0 : double.parse((effectif / total * 100).toStringAsFixed(1)),
      );
    }).toList();
  }

  List<RepartitionQualiteItemEntity> _repartitionHistorique(List<AnalyseCacheData> lignes) {
    final total = lignes.length;
    return _libellesCategorie.entries.map((entry) {
      final effectif = lignes.where((a) => a.categorie == entry.key).length;
      return RepartitionQualiteItemEntity(
        categorie: categorieQualiteHistoriqueDepuisCode(entry.key),
        libelle: entry.value,
        effectif: effectif,
        pourcentage: total == 0 ? 0 : double.parse((effectif / total * 100).toStringAsFixed(1)),
      );
    }).toList();
  }

  List<PointSerieValeurEntity> _serieQuotidienne(
    List<AnalyseCacheData> lignes, {
    required int jours,
    required _Agregat agregat,
  }) {
    final aujourdHui = DateTime.now();
    final debut = DateTime(aujourdHui.year, aujourdHui.month, aujourdHui.day)
        .subtract(Duration(days: jours - 1));

    return List.generate(jours, (i) {
      final jour = debut.add(Duration(days: i));
      final lignesJour = lignes
          .where((a) =>
              a.dateCalcul.year == jour.year &&
              a.dateCalcul.month == jour.month &&
              a.dateCalcul.day == jour.day)
          .toList();
      final dateLabel =
          '${jour.year.toString().padLeft(4, '0')}-${jour.month.toString().padLeft(2, '0')}-${jour.day.toString().padLeft(2, '0')}';

      if (agregat == _Agregat.compte) {
        return PointSerieValeurEntity(date: dateLabel, valeur: lignesJour.length.toDouble());
      }
      if (lignesJour.isEmpty) return PointSerieValeurEntity(date: dateLabel, valeur: null);

      final valeurs = lignesJour.map((a) => a.acidite).toList();
      final double valeur;
      switch (agregat) {
        case _Agregat.moyenne:
          valeur = _moyenne(valeurs) ?? 0;
          break;
        case _Agregat.minimum:
          valeur = valeurs.reduce((a, b) => a < b ? a : b);
          break;
        case _Agregat.maximum:
          valeur = valeurs.reduce((a, b) => a > b ? a : b);
          break;
        case _Agregat.compte:
          valeur = lignesJour.length.toDouble();
          break;
      }
      return PointSerieValeurEntity(date: dateLabel, valeur: valeur);
    });
  }

  double? _moyenne(List<double> valeurs) {
    if (valeurs.isEmpty) return null;
    return valeurs.reduce((a, b) => a + b) / valeurs.length;
  }

  double? _variationPourcentage(num? actuelle, num? precedente) {
    if (actuelle == null || precedente == null || precedente == 0) return null;
    return double.parse(((actuelle - precedente) / precedente * 100).toStringAsFixed(1));
  }
}

enum _Agregat { moyenne, minimum, maximum, compte }
