import 'package:flutter/widgets.dart';

import '../error/failures.dart';
import 'build_context_l10n_extension.dart';

/// Traduit une [Failure] en message affichable, via les fichiers ARB. Seul
/// point de contact entre les types [Failure] et le texte utilisateur : la
/// Presentation ne lit jamais un message d'erreur directement depuis une
/// réponse HTTP.
extension FailureLocalizer on Failure {
  String messageLocalise(BuildContext context) {
    final l10n = context.l10n;
    final failure = this;
    if (failure is IdentifiantsInvalidesFailure) return l10n.erreurIdentifiantsInvalides;
    if (failure is CompteVerrouilleFailure) return l10n.erreurCompteVerrouille;
    if (failure is CompteDesactiveFailure) return l10n.erreurCompteDesactive;
    if (failure is ErreurReseauFailure) return l10n.erreurReseau;
    if (failure is CodeResetInvalideFailure) return l10n.erreurCodeInvalide;
    if (failure is TropDeDemandesFailure) return l10n.erreurTropDeDemandes;
    if (failure is ErreurValidationFailure) return l10n.erreurValidationGenerique;
    if (failure is ErreurStockageLocalFailure) return l10n.erreurStockageLocal;
    return l10n.erreurServeur;
  }
}
