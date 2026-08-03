import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/injection_container.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'core/usecase/usecase.dart';
import 'features/accueil/presentation/screens/home_screen.dart';
import 'features/authentification/domain/usecases/get_session_locale_usecase.dart';
import 'features/authentification/presentation/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  final resultatSession = await sl<GetSessionLocaleUseCase>()(const NoParams());
  final possedeSession = resultatSession.fold((_) => false, (valeur) => valeur);

  runApp(ProviderScope(
    child: OliveIQApp(routeInitiale: possedeSession ? '/accueil' : '/login'),
  ));
}

class OliveIQApp extends StatelessWidget {
  final String routeInitiale;

  const OliveIQApp({super.key, required this.routeInitiale});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Olive IQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      navigatorKey: sl<AppNavigator>().navigatorKey,
      initialRoute: routeInitiale,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/accueil': (context) => const HomeScreen(),
      },
    );
  }
}
