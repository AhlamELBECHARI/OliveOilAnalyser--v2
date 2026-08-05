import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:olive_iq_app/core/demo/demo_credentials.dart';
import 'package:olive_iq_app/core/demo/demo_mode_provider.dart';
import 'package:olive_iq_app/core/error/failures.dart';
import 'package:olive_iq_app/core/theme/app_theme.dart';
import 'package:olive_iq_app/features/authentification/domain/entities/auth_session_entity.dart';
import 'package:olive_iq_app/features/authentification/domain/entities/utilisateur_entity.dart';
import 'package:olive_iq_app/features/authentification/domain/repositories/auth_repository.dart';
import 'package:olive_iq_app/features/authentification/domain/usecases/login_usecase.dart';
import 'package:olive_iq_app/features/authentification/presentation/providers/login_provider.dart';
import 'package:olive_iq_app/features/authentification/presentation/screens/login_screen.dart';
import 'package:olive_iq_app/l10n/generated/app_localizations.dart';

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

  Widget creerWidgetTeste({Locale locale = const Locale('fr')}) {
    return ProviderScope(
      overrides: [
        loginProvider.overrideWith(
          (ref) => LoginNotifier(LoginUseCase(mockRepository)),
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

  testWidgets(
      "le bouton Mode démo déclenche une vraie connexion (POST login) avec des identifiants fixes, jamais un contournement local",
      (tester) async {
    const session = AuthSessionEntity(
      accessToken: 'access',
      refreshToken: 'refresh',
      utilisateur: UtilisateurEntity(
        id: 2,
        nom: 'Laboratoire Démo',
        email: DemoCredentials.email,
        role: 'utilisateur',
      ),
    );
    when(
      () => mockRepository.login(
        email: DemoCredentials.email,
        password: DemoCredentials.password,
      ),
    ).thenAnswer((_) async => const Right(session));

    await definirViewportTelephone(tester);
    await tester.pumpWidget(creerWidgetTeste());

    await tester.tap(find.text('Mode démo'));
    await tester.pumpAndSettle();

    verify(
      () => mockRepository.login(
        email: DemoCredentials.email,
        password: DemoCredentials.password,
      ),
    ).called(1);
    expect(find.text('Accueil'), findsOneWidget);

    final container = ProviderScope.containerOf(tester.element(find.text('Accueil')));
    expect(container.read(demoModeProvider), isTrue);
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

  group('internationalisation (i18n)', () {
    testWidgets("s'affiche en français quand la locale active est fr", (tester) async {
      await definirViewportTelephone(tester);
      await tester.pumpWidget(creerWidgetTeste(locale: const Locale('fr')));

      expect(find.text('Bienvenue !'), findsOneWidget);
      expect(find.text('Connectez-vous pour accéder à votre espace'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    });

    testWidgets("s'affiche en anglais quand la locale active est en, sans aucune chaîne française résiduelle",
        (tester) async {
      await definirViewportTelephone(tester);
      await tester.pumpWidget(creerWidgetTeste(locale: const Locale('en')));

      expect(find.text('Welcome!'), findsOneWidget);
      expect(find.text('Log in to access your workspace'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);

      expect(find.text('Bienvenue !'), findsNothing);
      expect(find.text('Se connecter'), findsNothing);
    });
  });
}
