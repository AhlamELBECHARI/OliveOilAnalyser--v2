import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/demo/demo_fake_data.dart';
import '../../../../core/demo/demo_mode_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../authentification/domain/usecases/logout_usecase.dart';

/// Écran d'accueil provisoire : seul le module d'authentification est
/// implémenté pour l'instant. Le tableau de bord réel (échantillons,
/// résultats, alertes...) sera ajouté dans un prochain module.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _quitterModeDemo(BuildContext context, WidgetRef ref) async {
    ref.read(demoModeProvider.notifier).state = false;
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future<void> _seDeconnecter(BuildContext context) async {
    await sl<LogoutUseCase>()(const NoParams());
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estModeDemo = ref.watch(demoModeProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(title: const Text('Olive IQ')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (estModeDemo) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.vertOlive.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.vertOlive),
                  ),
                  child: Text(
                    'Mode démo — données factices, aucune connexion au serveur.\n'
                    '${DemoFakeData.nomUtilisateurDemo} · ${DemoFakeData.nombreEchantillonsDemo} échantillons · ${DemoFakeData.nombreAlertesDemo} alertes',
                    style: AppTextStyles.sousTexteBienvenue,
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                const Text('Connexion réussie', style: AppTextStyles.bienvenue),
                const SizedBox(height: 8),
                const Text(
                  'Le tableau de bord sera disponible dans un prochain module.',
                  style: AppTextStyles.sousTexteBienvenue,
                ),
                const SizedBox(height: 24),
              ],
              const Spacer(),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.vertOlive, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => estModeDemo
                      ? _quitterModeDemo(context, ref)
                      : _seDeconnecter(context),
                  child: Text(
                    estModeDemo ? 'Quitter le mode démo' : 'Se déconnecter',
                    style: AppTextStyles.boutonSecondaire,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
