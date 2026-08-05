import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../../core/localization/failure_localizer.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../providers/demande_reset_provider.dart';
import '../../widgets/champ_texte_olive_iq.dart';
import 'code_reset_screen.dart';

/// Étape 1/3 : saisie de l'email pour recevoir un code de vérification.
class EmailResetScreen extends ConsumerStatefulWidget {
  const EmailResetScreen({super.key});

  @override
  ConsumerState<EmailResetScreen> createState() => _EmailResetScreenState();
}

class _EmailResetScreenState extends ConsumerState<EmailResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validerEmail(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return context.l10n.erreurEmailRequis;
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(valeur.trim())) {
      return context.l10n.erreurEmailFormatInvalide;
    }
    return null;
  }

  void _envoyerCode() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(demandeResetProvider.notifier).demander(email: _emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(demandeResetProvider, (previous, next) {
      if (next.demandeEnvoyee && previous?.demandeEnvoyee != true) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CodeResetScreen(email: _emailController.text.trim()),
          ),
        );
      }
    });

    final state = ref.watch(demandeResetProvider);

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
                const Icon(Icons.lock_reset, size: 64, color: AppColors.vertOlive),
                const SizedBox(height: 24),
                Text(
                  l10n.motDePasseOublie,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bienvenue,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.sousTitreEmailReset,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sousTexteBienvenue,
                ),
                const SizedBox(height: 32),
                ChampTexteOliveIQ(
                  controller: _emailController,
                  placeholder: l10n.champEmail,
                  icone: Icons.mail_outline,
                  clavier: TextInputType.emailAddress,
                  validator: _validerEmail,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    onPressed: state.enChargement ? null : _envoyerCode,
                    child: state.enChargement
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.blanc,
                            ),
                          )
                        : Text(l10n.envoyerCode, style: AppTextStyles.boutonPrincipal),
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
