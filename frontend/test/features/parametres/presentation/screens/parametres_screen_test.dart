import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:olive_iq_app/core/theme/app_theme.dart';
import 'package:olive_iq_app/features/parametres/domain/repositories/parametres_repository.dart';
import 'package:olive_iq_app/features/parametres/domain/usecases/definir_locale_usecase.dart';
import 'package:olive_iq_app/features/parametres/domain/usecases/obtenir_locale_usecase.dart';
import 'package:olive_iq_app/features/parametres/presentation/providers/locale_provider.dart';
import 'package:olive_iq_app/features/parametres/presentation/screens/parametres_screen.dart';
import 'package:olive_iq_app/l10n/generated/app_localizations.dart';

class MockParametresRepository extends Mock implements ParametresRepository {}

void main() {
  late MockParametresRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const Locale('fr'));
  });

  setUp(() {
    mockRepository = MockParametresRepository();
    when(() => mockRepository.obtenirLocale()).thenAnswer((_) async => const Locale('fr'));
    when(() => mockRepository.definirLocale(any())).thenAnswer((_) async {});
  });

  Widget creerWidgetTeste() {
    return ProviderScope(
      overrides: [
        localeProvider.overrideWith(
          (ref) => LocaleNotifier(
            ObtenirLocaleUseCase(mockRepository),
            DefinirLocaleUseCase(mockRepository),
          ),
        ),
      ],
      child: Consumer(
        builder: (context, ref, _) => MaterialApp(
          theme: AppTheme.theme,
          locale: ref.watch(localeProvider),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ParametresScreen(),
        ),
      ),
    );
  }

  testWidgets('affiche les deux langues, avec le français coché par défaut', (tester) async {
    await tester.pumpWidget(creerWidgetTeste());
    await tester.pump();

    expect(find.text('Français'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets("bascule vers l'anglais au tap et persiste le choix via le repository",
      (tester) async {
    await tester.pumpWidget(creerWidgetTeste());
    await tester.pump();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.definirLocale(const Locale('en'))).called(1);
    expect(find.text('Paramètres'), findsNothing);
    expect(find.text('Settings'), findsOneWidget);
  });
}
