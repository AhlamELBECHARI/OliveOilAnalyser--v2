import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:olive_iq_app/core/error/failures.dart';
import 'package:olive_iq_app/core/usecase/usecase.dart';
import 'package:olive_iq_app/features/dashboard/domain/entities/statistiques_dashboard_entity.dart';
import 'package:olive_iq_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:olive_iq_app/features/dashboard/domain/usecases/obtenir_statistiques_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository repository;
  late ObtenirStatistiquesUseCase useCase;

  setUp(() {
    repository = MockDashboardRepository();
    useCase = ObtenirStatistiquesUseCase(repository);
  });

  const statistiques = StatistiquesDashboardEntity(
    nomUtilisateur: 'Laboratoire UM6P',
    analysesCeMois: MetriqueAvecVariationEntity(valeur: 156, variationPourcentage: 18.4),
    echantillonsTotaux: EchantillonsTotauxEntity(valeur: 12458, ajoutsCeMois: 3245),
    analysesAujourdHui: MetriqueAvecVariationEntity(valeur: 8, variationPourcentage: 14),
    tempsMoyenParAnalyse: TempsMoyenEntity(valeur: 3.7, variationPourcentage: -8),
    serie7Jours: [],
    repartitionQualite: [],
    analysesRecentes: [],
  );

  test('délègue au repository et renvoie les statistiques en cas de succès', () async {
    when(() => repository.obtenirStatistiques()).thenAnswer((_) async => const Right(statistiques));

    final resultat = await useCase(const NoParams());

    expect(resultat, const Right(statistiques));
    verify(() => repository.obtenirStatistiques()).called(1);
  });

  test('propage le Failure du repository sans le transformer en cas d\'échec', () async {
    when(() => repository.obtenirStatistiques())
        .thenAnswer((_) async => const Left(ErreurServeurFailure()));

    final resultat = await useCase(const NoParams());

    expect(resultat, const Left(ErreurServeurFailure()));
  });
}
