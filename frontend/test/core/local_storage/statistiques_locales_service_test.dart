import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:olive_iq_app/core/local_storage/local_database.dart';
import 'package:olive_iq_app/core/local_storage/statistiques_locales_service.dart';
import 'package:olive_iq_app/features/dashboard/domain/entities/statistiques_dashboard_entity.dart';

void main() {
  late LocalDatabase base;
  late StatistiquesLocalesService service;

  setUp(() {
    base = LocalDatabase(NativeDatabase.memory());
    service = StatistiquesLocalesService(base: base);
  });

  tearDown(() async {
    await base.close();
  });

  Future<void> inserer({
    required String id,
    required double acidite,
    required String categorie,
    required DateTime dateCalcul,
    int? dureeAnalyseSecondes,
  }) {
    return base.upsertAnalyseCache(AnalysesCacheCompanion.insert(
      id: id,
      acidite: acidite,
      categorie: categorie,
      dateCalcul: dateCalcul,
      dureeAnalyseSecondes: Value(dureeAnalyseSecondes),
    ));
  }

  group('statistiquesDashboard', () {
    test(
        "recalcule les compteurs (aujourd'hui/mois/total), la répartition qualité et la série 7 "
        "jours à partir du seul cache local — jamais du réseau", () async {
      final maintenant = DateTime.now();
      final aujourdHui = DateTime(maintenant.year, maintenant.month, maintenant.day, 10);
      // 40 jours en arrière : toujours un mois calendaire différent, quelle
      // que soit la date d'exécution du test (jamais de faux négatif lié à
      // une limite de mois).
      final moisPrecedent = aujourdHui.subtract(const Duration(days: 40));

      await inserer(id: 'a1', acidite: 0.5, categorie: 'evoo', dateCalcul: aujourdHui, dureeAnalyseSecondes: 120);
      await inserer(id: 'a2', acidite: 0.7, categorie: 'evoo', dateCalcul: aujourdHui, dureeAnalyseSecondes: 180);
      await inserer(id: 'a3', acidite: 1.5, categorie: 'voo', dateCalcul: aujourdHui);
      await inserer(id: 'a4', acidite: 3.5, categorie: 'lampante', dateCalcul: moisPrecedent);

      final stats = await service.statistiquesDashboard(nomUtilisateur: 'Laboratoire Test');

      expect(stats.nomUtilisateur, 'Laboratoire Test');
      expect(stats.echantillonsTotaux.valeur, 4);
      expect(stats.analysesAujourdHui.valeur, 3);
      expect(stats.analysesCeMois.valeur, 3, reason: 'la ligne vieille de 40 jours ne doit pas compter');

      // La répartition qualité du dashboard porte sur le mois courant
      // uniquement (même périmètre que dashboard.services._repartition_qualite
      // côté backend) : la ligne "lampante" du mois précédent en est exclue.
      final evoo = stats.repartitionQualite.firstWhere((r) => r.categorie == CategorieQualite.evoo);
      final voo = stats.repartitionQualite.firstWhere((r) => r.categorie == CategorieQualite.voo);
      final lampante =
          stats.repartitionQualite.firstWhere((r) => r.categorie == CategorieQualite.lampante);
      expect(evoo.effectif, 2);
      expect(voo.effectif, 1);
      expect(lampante.effectif, 0);

      expect(stats.serie7Jours.last.nombreAnalyses, 3, reason: 'le dernier point de la série est aujourd\'hui');

      // Moyenne de durée (120 + 180) / 2 = 150s = 2.5 min, sur le mois
      // courant uniquement.
      expect(stats.tempsMoyenParAnalyse.valeur, 2.5);
    });

    test('ne plante jamais sur un cache vide (première utilisation hors ligne)', () async {
      final stats = await service.statistiquesDashboard(nomUtilisateur: '');

      expect(stats.echantillonsTotaux.valeur, 0);
      expect(stats.analysesAujourdHui.valeur, 0);
      expect(stats.serie7Jours, hasLength(7));
      expect(stats.analysesRecentes, isEmpty);
    });
  });

  group('statistiquesRapidesHistorique', () {
    test('le total et la répartition de l\'aperçu portent sur toutes les analyses connues (pas seulement le mois)',
        () async {
      final maintenant = DateTime.now();
      final aujourdHui = DateTime(maintenant.year, maintenant.month, maintenant.day, 10);
      final moisPrecedent = aujourdHui.subtract(const Duration(days: 40));

      await inserer(id: 'b1', acidite: 0.4, categorie: 'evoo', dateCalcul: aujourdHui);
      await inserer(id: 'b2', acidite: 3.9, categorie: 'lampante', dateCalcul: moisPrecedent);

      final stats = await service.statistiquesRapidesHistorique();

      expect(stats.apercu.totalAnalyses, 2, reason: 'contrairement au dashboard, l\'aperçu porte sur tout');
      expect(stats.apercu.ceMois.valeur, 1);
      // La fenêtre de tendance (14 jours) exclut la ligne vieille de 40
      // jours : seule celle d'aujourd'hui (acidité 0.4) y contribue.
      expect(stats.plusForteAcidite.valeur, 0.4);
      expect(stats.tendanceAciditeMoyenne.valeur, 0.4);
    });
  });
}
