import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:olive_iq_app/core/error/failures.dart';
import 'package:olive_iq_app/core/theme/app_theme.dart';
import 'package:olive_iq_app/features/authentification/domain/entities/auth_session_entity.dart';
import 'package:olive_iq_app/features/authentification/domain/entities/utilisateur_entity.dart';
import 'package:olive_iq_app/features/authentification/domain/repositories/auth_repository.dart';
import 'package:olive_iq_app/features/authentification/domain/usecases/login_usecase.dart';
import 'package:olive_iq_app/features/authentification/presentation/providers/login_provider.dart';
import 'package:olive_iq_app/features/authentification/presentation/screens/login_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  /// La colonne de login (marges généreuses de la maquette) dépasse la
  /// taille par défaut du viewport de test (800x600) : on utilise un
  /// viewport plus haut, façon écran de téléphone, pour que le bouton
  /// "Se connecter" reste atteignable par tap() sans avoir à scroller.
  Future<void> definirViewportTelephone(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Widget creerWidgetTeste() {
    return ProviderScope(
      overrides: [
        loginProvider.overrideWith(
          (ref) => LoginNotifier(LoginUseCase(mockRepository)),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.theme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/accueil': (context) => const Scaffold(body: Text('Accueil')),
        },
      ),
    );
  }

  testWidgets('affiche tous les éléments requis par la maquette, sans bouton de création de compte',
      (tester) async {
    await definirViewportTelephone(tester);
    await tester.pumpWidget(creerWidgetTeste());

    expect(find.text('OliveIQ'), findsOneWidget);
    expect(find.text("Analyse d'Huile d'Olive"), findsOneWidget);
    expect(find.text('Bienvenue !'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
    expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Mode démo'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);
    expect(find.text('Créer un compte'), findsNothing);
  });

  testWidgets('affiche des erreurs de validation locale et n\'appelle pas le repository si les champs sont vides',
      (tester) async {
    await definirViewportTelephone(tester);
    await tester.pumpWidget(creerWidgetTeste());

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(find.text('Email requis'), findsOneWidget);
    expect(find.text('Mot de passe requis'), findsOneWidget);
    verifyNever(
      () => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('navigue vers /accueil après une connexion réussie', (tester) async {
    const session = AuthSessionEntity(
      accessToken: 'access',
      refreshToken: 'refresh',
      utilisateur: UtilisateurEntity(
        id: 1,
        nom: 'Test',
        email: 'test@example.com',
        role: 'utilisateur',
      ),
    );
    when(
      () => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Right(session));

    await definirViewportTelephone(tester);
    await tester.pumpWidget(creerWidgetTeste());

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'motdepasse123');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsOneWidget);
  });

  testWidgets("affiche un message générique sur identifiants invalides, sans préciser le champ fautif",
      (tester) async {
    when(
      () => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Left(IdentifiantsInvalidesFailure()));

    await definirViewportTelephone(tester);
    await tester.pumpWidget(creerWidgetTeste());

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'mauvais-mdp');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Email ou mot de passe incorrect.'), findsOneWidget);
  });

  testWidgets('affiche un message spécifique quand le compte est verrouillé', (tester) async {
    when(
      () => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Left(CompteVerrouilleFailure()));

    await definirViewportTelephone(tester);
    await tester.pumpWidget(creerWidgetTeste());

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'motdepasse123');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('temporairement bloqué'),
      findsOneWidget,
    );
  });
}
