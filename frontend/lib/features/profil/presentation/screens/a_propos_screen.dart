import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/package_info_provider.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Sous-écran "À propos d'OliveIQ" — version et build lus dynamiquement via
/// package_info_plus, jamais écrits en dur.
class AProposScreen extends ConsumerWidget {
  const AProposScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final infos = ref.watch(packageInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.aProposOliveIQTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/oliveIQ_logo.png', width: 96),
              const SizedBox(height: 16),
              Text(l10n.appName, style: AppTextStyles.titreLogo.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              infos.when(
                data: (info) => Text(
                  l10n.versionBuildLabel(info.version, info.buildNumber),
                  style: AppTextStyles.sousTexteBienvenue,
                ),
                loading: () => const CircularProgressIndicator(color: AppColors.vertOlive),
                error: (_, _) => Text('—', style: AppTextStyles.sousTexteBienvenue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
