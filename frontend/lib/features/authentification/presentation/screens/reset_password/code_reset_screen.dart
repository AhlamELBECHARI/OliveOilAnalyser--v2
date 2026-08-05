import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../../core/localization/failure_localizer.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../providers/demande_reset_provider.dart';
import '../../providers/verifier_code_provider.dart';
import 'nouveau_mot_de_passe_screen.dart';

const _dureeCooldownRenvoi = Duration(seconds: 30);

/// Étape 2/3 : saisie du code à 6 chiffres reçu par email, avec possibilité
/// de le renvoyer (limité côté backend, cooldown local en plus côté UI).
class CodeResetScreen extends ConsumerStatefulWidget {
  final String email;

  const CodeResetScreen({super.key, required this.email});

  @override
  ConsumerState<CodeResetScreen> createState() => _CodeResetScreenState();
}

class _CodeResetScreenState extends ConsumerState<CodeResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  Timer? _timerCooldown;
  int _secondesRestantes = 0;

  @override
  void dispose() {
    _codeController.dispose();
    _timerCooldown?.cancel();
    super.dispose();
  }

  void _demarrerCooldown() {
    setState(() => _secondesRestantes = _dureeCooldownRenvoi.inSeconds);
    _timerCooldown?.cancel();
    _timerCooldown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondesRestantes <= 1) {
        timer.cancel();
        setState(() => _secondesRestantes = 0);
      } else {
        setState(() => _secondesRestantes -= 1);
      }
    });
  }

  String? _validerCode(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return context.l10n.erreurCodeRequis;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(valeur.trim())) {
      return context.l10n.erreurCodeFormat;
    }
    return null;
  }

  void _verifierCode() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(verifierCodeProvider.notifier).verifier(
            email: widget.email,
            code: _codeController.text.trim(),
          );
    }
  }

  void _renvoyerCode() {
    if (_secondesRestantes > 0) return;
    ref.read(demandeResetProvider.notifier).demander(email: widget.email);
    _demarrerCooldown();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.nouveauCodeEnvoye)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(verifierCodeProvider, (previous, next) {
      if (next.codeValide && previous?.codeValide != true) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NouveauMotDePasseScreen(
              email: widget.email,
              code: _codeController.text.trim(),
            ),
          ),
        );
      }
    });

    final state = ref.watch(verifierCodeProvider);

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
                const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.vertOlive),
                const SizedBox(height: 24),
                Text(
                  l10n.entrezLeCode,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bienvenue,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.codeEnvoyeA(widget.email),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sousTexteBienvenue,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  validator: _validerCode,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 16,
                    color: AppColors.grisFonce,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.blanc,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
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
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _secondesRestantes > 0 ? null : _renvoyerCode,
                    child: Text(
                      _secondesRestantes > 0
                          ? l10n.renvoyerLeCodeCompteur(_secondesRestantes)
                          : l10n.renvoyerLeCode,
                      style: _secondesRestantes > 0
                          ? AppTextStyles.sousTexteBienvenue
                          : AppTextStyles.lienAction,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vertOlive,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: state.enChargement ? null : _verifierCode,
                    child: state.enChargement
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.blanc,
                            ),
                          )
                        : Text(l10n.verifier, style: AppTextStyles.boutonPrincipal),
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
