import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:olive_iq_app/core/demo/demo_mode_provider.dart';
import 'package:olive_iq_app/core/theme/app_theme.dart';
import 'package:olive_iq_app/features/dashboard/domain/entities/statistiques_dashboard_entity.dart';
import 'package:olive_iq_app/features/analyseur/domain/repositories/analyseur_repository.dart';
import 'package:olive_iq_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:olive_iq_app/features/dashboard/domain/usecases/compter_alertes_non_resolues_usecase.dart';
import 'package:olive_iq_app/features/dashboard/domain/usecases/obtenir_etat_analyseur_usecase.dart';
import 'package:olive_iq_app/features/dashboard/domain/usecases/obtenir_statistiques_usecase.dart';
import 'package:olive_iq_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:olive_iq_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:olive_iq_app/l10n/generated/app_localizations.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockAnalyseurRepository extends Mock implements AnalyseurRepository {}

/// Notifier de test : neutralise l'appel réseau automatique du constructeur
/// réel (charger() y est appelé dès la construction) pour injecter un état
/// déterministe sans race condition asynchrone.
class _NotifierTest extends DashboardNotifier {
  _NotifierTest(DashboardState etat)
      : super(
          ObtenirStatistiquesUseCase(MockDashboardRepository()),
          CompterAlertesNonResoluesUseCase(MockDashboardRepository()),
          ObtenirEtatAnalyseurUseCase(MockAnalyseurRepository()),
        ) {
    state = etat;
  }

  @override
  Future<void> charger() async {}
}

final _statistiques = StatistiquesDashboardEntity(
  nomUtilisateur: 'Laboratoire UM6P',
  analysesCeMois: MetriqueAvecVariationEntity(valeur: 156, variationPourcentage: 18.4),
  echantillonsTotaux: EchantillonsTotauxEntity(valeur: 12458, ajoutsCeMois: 3245),
  analysesAujourdHui: MetriqueAvecVariationEntity(valeur: 8, variationPourcentage: 14),
  tempsMoyenParAnalyse: TempsMoyenEntity(valeur: 3.7, variationPourcentage: -8),
  serie7Jours: [
    PointSerieEntity(date: DateTime(2026, 7, 10), nombreAnalyses: 14),
    PointSerieEntity(date: DateTime(2026, 7, 11), nombreAnalyses: 18),
    PointSerieEntity(date: DateTime(2026, 7, 12), nombreAnalyses: 11),
    PointSerieEntity(date: DateTime(2026, 7, 13), nombreAnalyses: 9),
    PointSerieEntity(date: DateTime(2026, 7, 14), nombreAnalyses: 23),
    PointSerieEntity(date: DateTime(2026, 7, 15), nombreAnalyses: 30),
    PointSerieEntity(date: DateTime(2026, 7, 16), nombreAnalyses: 8),
  ],
  repartitionQualite: [
    RepartitionQualiteEntity(
      categorie: CategorieQualite.evoo,
      libelle: 'Extra Vierge (EVOO)',
      effectif: 97,
      pourcentage: 62.2,
    ),
  ],
  analysesRecentes: [
    AnalyseRecenteEntity(
      resultatId: 'b3ed861e-736f-4e66-b304-66a7b530c0e8',
      numero: 'SMP-2026-01246',
      origine: 'Domaine Alami',
      variete: 'Picholine',
      heure: '09:32',
      categorie: CategorieQualite.evoo,
    ),
  ],
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
    await initializeDateFormatting('en_US', null);
  });

  Future<void> definirViewportTelephone(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Widget creerWidgetTeste({required bool modeDemo, Locale locale = const Locale('fr')}) {
    return ProviderScope(
      overrides: [
        demoModeProvider.overrideWith((ref) => modeDemo),
        dashboardProvider.overrideWith(
          (ref) => _NotifierTest(DashboardState(statistiques: _statistiques, alertesNonLues: 2)),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.theme,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const DashboardScreen(),
      ),
    );
  }

  testWidgets('affiche les vraies données du dashboard (nom, statistiques, activité)',
      (tester) async {
    await definirViewportTelephone(tester);
    await tester.pumpWidget(creerWidgetTeste(modeDemo: false));
    await tester.pump();

    expect(find.text('Laboratoire UM6P'), findsOneWidget);
    expect(find.text('156'), findsOneWidget);
    expect(find.text('SMP-2026-01246'), findsOneWidget);
    expect(find.text('Mode démo — connecté avec le compte de démonstration.'), findsNothing);
  });

  testWidgets(
      'en Mode démo, affiche la bannière cosmétique mais les mêmes vraies données que la session normale (pas de dataset factice)',
      (tester) async {
    await definirViewportTelephone(tester);
    await tester.pumpWidget(creerWidgetTeste(modeDemo: true));
    await tester.pump();

    expect(find.text('Mode démo — connecté avec le compte de démonstration.'), findsOneWidget);
    // Les données affichées sont celles renvoyées par dashboardProvider (la
    // même API réelle qu'en session normale), jamais un dataset factice.
    expect(find.text('Laboratoire UM6P'), findsOneWidget);
    expect(find.text('156'), findsOneWidget);
  });

  group('internationalisation (i18n)', () {
    testWidgets('affiche les libellés en français quand la locale active est fr',
        (tester) async {
      await definirViewportTelephone(tester);
      await tester.pumpWidget(creerWidgetTeste(modeDemo: false, locale: const Locale('fr')));
      await tester.pump();

      expect(find.text('Bonjour,'), findsOneWidget);
      expect(find.text('Analyses ce mois'), findsOneWidget);
      expect(find.text('Échantillons totaux'), findsOneWidget);
      expect(find.text('Activité récente'), findsOneWidget);
    });

    testWidgets(
        'affiche les libellés en anglais quand la locale active est en, sans aucune chaîne française résiduelle',
        (tester) async {
      await definirViewportTelephone(tester);
      await tester.pumpWidget(creerWidgetTeste(modeDemo: false, locale: const Locale('en')));
      await tester.pump();

      expect(find.text('Hello,'), findsOneWidget);
      expect(find.text('Analyses this month'), findsOneWidget);
      expect(find.text('Total samples'), findsOneWidget);
      expect(find.text('Recent activity'), findsOneWidget);

      expect(find.text('Bonjour,'), findsNothing);
      expect(find.text('Analyses ce mois'), findsNothing);
    });
  });
}
