import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:olive_iq_app/core/error/failures.dart';
import 'package:olive_iq_app/features/authentification/domain/entities/auth_session_entity.dart';
import 'package:olive_iq_app/features/authentification/domain/entities/utilisateur_entity.dart';
import 'package:olive_iq_app/features/authentification/domain/repositories/auth_repository.dart';
import 'package:olive_iq_app/features/authentification/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LoginUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  const email = 'utilisateur@example.com';
  const password = 'MotDePasse123!';
  const session = AuthSessionEntity(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    utilisateur: UtilisateurEntity(
      id: 1,
      nom: 'Test',
      email: email,
      role: 'utilisateur',
    ),
  );

  test(
    "délègue l'appel au repository avec les paramètres fournis et renvoie la session en cas de succès",
    () async {
      when(() => repository.login(email: email, password: password))
          .thenAnswer((_) async => const Right(session));

      final resultat = await useCase(
        const LoginParams(email: email, password: password),
      );

      expect(resultat, const Right(session));
      verify(() => repository.login(email: email, password: password)).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'propage un IdentifiantsInvalidesFailure sans le transformer quand le repository échoue',
    () async {
      when(() => repository.login(email: email, password: password))
          .thenAnswer((_) async => const Left(IdentifiantsInvalidesFailure()));

      final resultat = await useCase(
        const LoginParams(email: email, password: password),
      );

      expect(resultat, const Left(IdentifiantsInvalidesFailure()));
    },
  );

  test(
    'propage un CompteVerrouilleFailure quand le compte est verrouillé',
    () async {
      when(() => repository.login(email: email, password: password))
          .thenAnswer((_) async => const Left(CompteVerrouilleFailure()));

      final resultat = await useCase(
        const LoginParams(email: email, password: password),
      );

      expect(resultat, const Left(CompteVerrouilleFailure()));
    },
  );
}
