import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../../core/localization/failure_localizer.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../providers/confirmer_reset_provider.dart';
import '../../widgets/champ_texte_olive_iq.dart';

/// Étape 3/3 : saisie du nouveau mot de passe (+ confirmation locale) puis
/// appel à POST /api/auth/reset-password/confirm/.
class NouveauMotDePasseScreen extends ConsumerStatefulWidget {
  final String email;
  final String code;

  const NouveauMotDePasseScreen({super.key, required this.email, required this.code});

  @override
  ConsumerState<NouveauMotDePasseScreen> createState() => _NouveauMotDePasseScreenState();
}

class _NouveauMotDePasseScreenState extends ConsumerState<NouveauMotDePasseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motDePasseController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _motDePasseVisible = false;
  bool _confirmationVisible = false;

  @override
  void dispose() {
    _motDePasseController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  String? _validerMotDePasse(String? valeur) {
    if (valeur == null || valeur.isEmpty) {
      return context.l10n.erreurMotDePasseRequis;
    }
    if (valeur.length < 8) {
      return context.l10n.erreurMinimum8Caracteres;
    }
    return null;
  }

  String? _validerConfirmation(String? valeur) {
    if (valeur == null || valeur.isEmpty) {
      return context.l10n.erreurConfirmationRequise;
    }
    if (valeur != _motDePasseController.text) {
      return context.l10n.erreurMotsDePasseNeCorrespondentPas;
    }
    return null;
  }

  void _reinitialiser() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(confirmerResetProvider.notifier).confirmer(
            email: widget.email,
            code: widget.code,
            nouveauMotDePasse: _motDePasseController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(confirmerResetProvider, (previous, next) {
      if (next.reinitialisationReussie && previous?.reinitialisationReussie != true) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.motDePasseReinitialiseSucces)),
        );
      }
    });

    final state = ref.watch(confirmerResetProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(backgroundColor: AppColors.fond, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.password_outlined, size: 64, color: AppColors.vertOlive),
                const SizedBox(height: 24),
                Text(
                  l10n.nouveauMotDePasse,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bienvenue,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.choisissezNouveauMotDePasse,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sousTexteBienvenue,
                ),
                const SizedBox(height: 32),
                ChampTexteOliveIQ(
                  controller: _motDePasseController,
                  placeholder: l10n.nouveauMotDePasse,
                  icone: Icons.lock_outline,
                  masquerTexte: !_motDePasseVisible,
                  validator: _validerMotDePasse,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  suffixe: IconButton(
                    icon: Icon(
                      _motDePasseVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.grisMoyen,
                    ),
                    onPressed: () => setState(() => _motDePasseVisible = !_motDePasseVisible),
                  ),
                ),
                const SizedBox(height: 16),
                ChampTexteOliveIQ(
                  controller: _confirmationController,
                  placeholder: l10n.champConfirmerMotDePasse,
                  icone: Icons.lock_outline,
                  masquerTexte: !_confirmationVisible,
                  validator: _validerConfirmation,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  suffixe: IconButton(
                    icon: Icon(
                      _confirmationVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grisMoyen,
                    ),
                    onPressed: () => setState(() => _confirmationVisible = !_confirmationVisible),
                  ),
                ),
                if (state.echec != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.echec!.messageLocalise(context),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.erreurChamp.copyWith(fontSize: 14),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vertOlive,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: state.enChargement ? null : _reinitialiser,
                    child: state.enChargement
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.blanc,
                            ),
                          )
                        : Text(l10n.reinitialiser, style: AppTextStyles.boutonPrincipal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
