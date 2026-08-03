import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/demo/demo_mode_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/login_provider.dart';
import '../widgets/champ_texte_olive_iq.dart';
import '../widgets/dialogue_mot_de_passe_oublie.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _motDePasseVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validerEmail(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Email requis';
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(valeur.trim())) {
      return 'Format email invalide';
    }
    return null;
  }

  String? _validerMotDePasse(String? valeur) {
    if (valeur == null || valeur.isEmpty) {
      return 'Mot de passe requis';
    }
    return null;
  }

  void _soumettre() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(loginProvider.notifier).seConnecter(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  void _demarrerModeDemo() {
    ref.read(demoModeProvider.notifier).state = true;
    Navigator.of(context).pushNamedAndRemoveUntil('/accueil', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(loginProvider, (previous, next) {
      if (next.connexionReussie && previous?.connexionReussie != true) {
        Navigator.of(context).pushNamedAndRemoveUntil('/accueil', (route) => false);
      }
    });

    final state = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Image.asset(
                      'assets/images/oliveIQ_logo.png',
                      width: 180,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'OliveIQ',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titreLogo,
                  ),
                  const SizedBox(height: 8),
                  const _SousTitreEncadre(),
                  const SizedBox(height: 40),
                  const Text(
                    'Bienvenue !',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bienvenue,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connectez-vous pour accéder à votre espace',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sousTexteBienvenue,
                  ),
                  const SizedBox(height: 32),
                  ChampTexteOliveIQ(
                    controller: _emailController,
                    placeholder: 'Email',
                    icone: Icons.mail_outline,
                    clavier: TextInputType.emailAddress,
                    validator: _validerEmail,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 16),
                  ChampTexteOliveIQ(
                    controller: _passwordController,
                    placeholder: 'Mot de passe',
                    icone: Icons.lock_outline,
                    masquerTexte: !_motDePasseVisible,
                    validator: _validerMotDePasse,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    suffixe: IconButton(
                      icon: Icon(
                        _motDePasseVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.grisMoyen,
                      ),
                      onPressed: () => setState(
                        () => _motDePasseVisible = !_motDePasseVisible,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const DialogueMotDePasseOublie(),
                      ),
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: AppTextStyles.lienAction,
                      ),
                    ),
                  ),
                  if (state.messageErreur != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      state.messageErreur!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.erreurChamp.copyWith(fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vertOlive,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: state.enChargement ? null : _soumettre,
                      child: state.enChargement
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.blanc,
                              ),
                            )
                          : const Text('Se connecter', style: AppTextStyles.boutonPrincipal),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _Separateur(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 58,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(color: AppColors.vertOlive, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: state.enChargement ? null : _demarrerModeDemo,
                      child: const Text('Mode démo', style: AppTextStyles.boutonSecondaire),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Version 1.0.0',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.version,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SousTitreEncadre extends StatelessWidget {
  const _SousTitreEncadre();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.grisLigne, thickness: 1)),
        Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Analyse d'Huile d'Olive",
              style: AppTextStyles.sousTitreLogo,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.grisLigne, thickness: 1)),
      ],
    );
  }
}

class _Separateur extends StatelessWidget {
  const _Separateur();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.grisLigne, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou', style: AppTextStyles.separateur),
        ),
        Expanded(child: Divider(color: AppColors.grisLigne, thickness: 1)),
      ],
    );
  }
}
