import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/demo/demo_credentials.dart';
import '../../../../core/demo/demo_mode_provider.dart';
import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/login_provider.dart';
import '../widgets/champ_texte_olive_iq.dart';

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
  bool _tentativeModeDemo = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  String? _validerMotDePasse(String? valeur) {
    if (valeur == null || valeur.isEmpty) {
      return context.l10n.erreurMotDePasseRequis;
    }
    return null;
  }

  void _soumettre() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _tentativeModeDemo = false;
      ref.read(loginProvider.notifier).seConnecter(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  /// Le mode démo évite seulement la saisie manuelle des identifiants : il
  /// déclenche la même connexion réelle (POST /api/auth/login/) que le
  /// formulaire, avec un compte à identifiants fixes créé par
  /// `python manage.py seed_demo` côté backend.
  void _demarrerModeDemo() {
    FocusScope.of(context).unfocus();
    _tentativeModeDemo = true;
    ref.read(loginProvider.notifier).seConnecter(
          email: DemoCredentials.email,
          password: DemoCredentials.password,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(loginProvider, (previous, next) {
      if (next.connexionReussie && previous?.connexionReussie != true) {
        if (_tentativeModeDemo) {
          ref.read(demoModeProvider.notifier).state = true;
        }
        final estAdministrateur = next.utilisateur?.estAdministrateur ?? false;
        context.go(estAdministrateur ? '/admin/supervision' : '/accueil');
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
                  Text(
                    l10n.appName,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titreLogo,
                  ),
                  const SizedBox(height: 8),
                  const _SousTitreEncadre(),
                  const SizedBox(height: 40),
                  Text(
                    l10n.bienvenue,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bienvenue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.accedezVotreEspace,
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
                  const SizedBox(height: 16),
                  ChampTexteOliveIQ(
                    controller: _passwordController,
                    placeholder: l10n.champMotDePasse,
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
                      onPressed: () => context.push('/mot-de-passe-oublie'),
                      child: Text(
                        l10n.motDePasseOublie,
                        style: AppTextStyles.lienAction,
                      ),
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
                          : Text(l10n.seConnecter, style: AppTextStyles.boutonPrincipal),
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
                      child: Text(l10n.modeDemo, style: AppTextStyles.boutonSecondaire),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.versionApp,
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
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.grisLigne, thickness: 1)),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              context.l10n.sousTitreApp,
              style: AppTextStyles.sousTitreLogo,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.grisLigne, thickness: 1)),
      ],
    );
  }
}

class _Separateur extends StatelessWidget {
  const _Separateur();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.grisLigne, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(context.l10n.ou, style: AppTextStyles.separateur),
        ),
        const Expanded(child: Divider(color: AppColors.grisLigne, thickness: 1)),
      ],
    );
  }
}
