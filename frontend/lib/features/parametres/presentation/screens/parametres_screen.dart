import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/demo/demo_mode_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../../authentification/domain/usecases/logout_usecase.dart';
import '../providers/locale_provider.dart';
import '../widgets/option_langue.dart';

/// Écran Paramètres, accessible depuis l'onglet "Paramètres" de la barre de
/// navigation du dashboard.
class ParametresScreen extends ConsumerWidget {
  const ParametresScreen({super.key});

  /// Le mode démo est une vraie session JWT (voir demo_mode_provider.dart) :
  /// en sortir passe donc par la même déconnexion réelle, quel que soit le
  /// libellé affiché sur le bouton.
  Future<void> _seDeconnecter(BuildContext context, WidgetRef ref) async {
    await sl<LogoutUseCase>()(const NoParams());
    ref.read(demoModeProvider.notifier).state = false;
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final localeActive = ref.watch(localeProvider);
    final estModeDemo = ref.watch(demoModeProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.parametresTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _TitreSection(l10n.langueSectionTitre),
          const SizedBox(height: 8),
          CarteStylisee(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                OptionLangue(
                  libelle: l10n.langueFrancais,
                  active: localeActive.languageCode == 'fr',
                  onTap: () => ref.read(localeProvider.notifier).changerLocale(const Locale('fr')),
                ),
                const Divider(height: 1, color: AppColors.grisLigne),
                OptionLangue(
                  libelle: l10n.langueAnglais,
                  active: localeActive.languageCode == 'en',
                  onTap: () => ref.read(localeProvider.notifier).changerLocale(const Locale('en')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _TitreSection(l10n.compteSectionTitre),
          const SizedBox(height: 8),
          CarteStylisee(
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.vertOlive, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _seDeconnecter(context, ref),
                child: Text(
                  estModeDemo ? l10n.quitterModeDemo : l10n.seDeconnecter,
                  style: AppTextStyles.boutonSecondaire,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitreSection extends StatelessWidget {
  final String texte;

  const _TitreSection(this.texte);

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisMoyen),
    );
  }
}
