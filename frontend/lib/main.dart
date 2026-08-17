import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/di/injection_container.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'core/usecase/usecase.dart';
import 'features/authentification/domain/entities/etat_session_locale.dart';
import 'features/authentification/domain/usecases/obtenir_etat_session_locale_usecase.dart';
import 'features/authentification/domain/usecases/obtenir_role_session_usecase.dart';
import 'features/parametres/presentation/providers/locale_provider.dart';
import 'features/parametres/presentation/providers/theme_mode_provider.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await initializeDateFormatting('fr_FR', null);
  await initializeDateFormatting('en_US', null);

  // Entièrement local : jamais d'appel réseau dans le chemin de démarrage,
  // pour ne jamais bloquer un lancement hors ligne (voir cahier des
  // charges, Partie A "Hors ligne", section 7).
  final resultatEtat = await sl<ObtenirEtatSessionLocaleUseCase>()(const NoParams());
  final etat = resultatEtat.fold((_) => EtatSessionLocale.absente, (valeur) => valeur);

  String emplacementInitial = '/login';
  if (etat == EtatSessionLocale.valide) {
    final resultatRole = await sl<ObtenirRoleSessionUseCase>()(const NoParams());
    final role = resultatRole.fold((_) => null, (valeur) => valeur);
    emplacementInitial = role == 'administrateur' ? '/admin/supervision' : '/accueil';
  }

  sl<AppNavigator>().initialiserRouter(emplacementInitial);

  runApp(const ProviderScope(child: OliveIQApp()));
}

class OliveIQApp extends ConsumerWidget {
  const OliveIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final modeTheme = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Olive IQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      darkTheme: AppTheme.themeSombre,
      themeMode: modeTheme,
      routerConfig: sl<AppNavigator>().router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
