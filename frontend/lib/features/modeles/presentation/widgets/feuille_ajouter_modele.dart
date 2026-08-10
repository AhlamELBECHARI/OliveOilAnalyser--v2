import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/modeles_provider.dart';

/// Extensions autorisées côté mobile — doit rester cohérent avec
/// backend/modeles/models.py::Modele.EXTENSIONS_AUTORISEES, le backend
/// restant la seule source de vérité (revalidé côté serveur dans tous les
/// cas). Affiché ici uniquement pour guider l'utilisateur en amont.
const _extensionsAutorisees = ['pkl', 'pickle', 'joblib'];

/// Formulaire d'import d'un modèle déjà entraîné (l'entraînement reste hors
/// périmètre de l'application — voir README). Réservé aux administrateurs :
/// le bouton qui ouvre cette feuille n'est visible que pour eux, et
/// l'endpoint refuse de toute façon la requête d'un utilisateur standard.
Future<void> afficherFeuilleAjouterModele(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.blanc,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _FeuilleAjouterModele(),
  );
}

class _FeuilleAjouterModele extends ConsumerStatefulWidget {
  const _FeuilleAjouterModele();

  @override
  ConsumerState<_FeuilleAjouterModele> createState() => _FeuilleAjouterModeleState();
}

class _FeuilleAjouterModeleState extends ConsumerState<_FeuilleAjouterModele> {
  final _formKey = GlobalKey<FormState>();
  final _nomControleur = TextEditingController();
  final _versionControleur = TextEditingController();
  final _algorithmeControleur = TextEditingController();
  final _r2Controleur = TextEditingController();
  final _rmsecvControleur = TextEditingController();
  final _hyperparametresControleur = TextEditingController(text: '{}');
  DateTime? _dateEntrainement;
  PlatformFile? _fichierChoisi;
  bool _envoiEnCours = false;

  @override
  void dispose() {
    _nomControleur.dispose();
    _versionControleur.dispose();
    _algorithmeControleur.dispose();
    _r2Controleur.dispose();
    _rmsecvControleur.dispose();
    _hyperparametresControleur.dispose();
    super.dispose();
  }

  Future<void> _choisirFichier() async {
    final resultat = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _extensionsAutorisees,
    );
    if (resultat == null || resultat.files.isEmpty) return;
    setState(() => _fichierChoisi = resultat.files.single);
  }

  Future<void> _choisirDateEntrainement() async {
    final choisie = await showDatePicker(
      context: context,
      initialDate: _dateEntrainement ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (choisie == null) return;
    setState(() => _dateEntrainement = choisie);
  }

  Future<void> _soumettre() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _envoiEnCours = true);
    final succes = await ref.read(modelesProvider.notifier).creerModele(
          nom: _nomControleur.text.trim(),
          version: _versionControleur.text.trim(),
          algorithme: _algorithmeControleur.text.trim(),
          hyperparametres: jsonDecode(_hyperparametresControleur.text) as Map<String, dynamic>,
          r2: double.parse(_r2Controleur.text.replaceAll(',', '.')),
          rmsecv: double.parse(_rmsecvControleur.text.replaceAll(',', '.')),
          dateEntrainement: _dateEntrainement,
          cheminFichier: _fichierChoisi?.path,
          nomFichier: _fichierChoisi?.name,
        );
    if (!mounted) return;

    if (succes) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.modeleAjouteMessage)));
      return;
    }

    setState(() => _envoiEnCours = false);
    final echec = ref.read(modelesProvider).echec;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(echec?.messageLocalise(context) ?? l10n.erreurServeur)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatDate = DateFormat.yMd(l10n.localeName);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.ajouterModeleTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomControleur,
                decoration: InputDecoration(labelText: l10n.champNomModele),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.champObligatoire : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _versionControleur,
                decoration: InputDecoration(labelText: l10n.champVersionModele),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.champObligatoire : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _algorithmeControleur,
                decoration: InputDecoration(labelText: l10n.modeleAlgorithmeLabel),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.champObligatoire : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _r2Controleur,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.modeleR2Label),
                      validator: (v) => double.tryParse((v ?? '').replaceAll(',', '.')) == null
                          ? l10n.valeurNumeriqueInvalide
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _rmsecvControleur,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.modeleRmsecvLabel),
                      validator: (v) {
                        final valeur = double.tryParse((v ?? '').replaceAll(',', '.'));
                        if (valeur == null) return l10n.valeurNumeriqueInvalide;
                        if (valeur < 0) return l10n.valeurDoitEtrePositive;
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hyperparametresControleur,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.champHyperparametres,
                  helperText: l10n.champHyperparametresAide,
                ),
                validator: (v) {
                  try {
                    final decode = jsonDecode(v == null || v.trim().isEmpty ? '{}' : v);
                    if (decode is! Map) return l10n.jsonInvalide;
                    return null;
                  } catch (_) {
                    return l10n.jsonInvalide;
                  }
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _choisirDateEntrainement,
                icon: const Icon(Icons.event_outlined, size: 18),
                label: Text(
                  _dateEntrainement != null
                      ? formatDate.format(_dateEntrainement!)
                      : l10n.champDateEntrainement,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _choisirFichier,
                icon: const Icon(Icons.upload_file_outlined, size: 18),
                label: Text(
                  _fichierChoisi != null ? _fichierChoisi!.name : l10n.choisirFichierModeleBouton,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.formatsFichierModeleAutorises(_extensionsAutorisees.join(', ')),
                style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vertOlive,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _envoiEnCours ? null : _soumettre,
                  child: _envoiEnCours
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                        )
                      : Text(l10n.enregistrerBouton, style: AppTextStyles.boutonPrincipal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
