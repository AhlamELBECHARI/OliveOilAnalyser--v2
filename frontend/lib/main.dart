import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/di/injection_container.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'core/usecase/usecase.dart';
import 'features/authentification/domain/usecases/get_session_locale_usecase.dart';
import 'features/authentification/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/parametres/presentation/providers/locale_provider.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await initializeDateFormatting('fr_FR', null);
  await initializeDateFormatting('en_US', null);

  final resultatSession = await sl<GetSessionLocaleUseCase>()(const NoParams());
  final possedeSession = resultatSession.fold((_) => false, (valeur) => valeur);

  runApp(ProviderScope(
    child: OliveIQApp(routeInitiale: possedeSession ? '/accueil' : '/login'),
  ));
}

class OliveIQApp extends ConsumerWidget {
  final String routeInitiale;

  const OliveIQApp({super.key, required this.routeInitiale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Olive IQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      navigatorKey: sl<AppNavigator>().navigatorKey,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: routeInitiale,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/accueil': (context) => const DashboardScreen(),
      },
    );
  }
}
