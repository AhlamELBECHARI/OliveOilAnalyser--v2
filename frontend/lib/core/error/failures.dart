import 'package:equatable/equatable.dart';

/// Types d'échec métier renvoyés par les repositories au domain, indépendants
/// de toute origine technique (Dio, storage...). Une Failure ne porte aucun
/// texte : le message affiché est résolu par la Presentation via les
/// fichiers ARB (voir core/localization/failure_localizer.dart), pour que
/// chaque échec soit traduisible et jamais lu directement depuis la réponse
/// HTTP du serveur.
abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

/// Identifiants invalides (401) : volontairement générique, ne précise
/// jamais si c'est l'email ou le mot de passe qui est erroné.
class IdentifiantsInvalidesFailure extends Failure {
  const IdentifiantsInvalidesFailure();
}

/// Compte temporairement verrouillé suite à trop de tentatives échouées.
class CompteVerrouilleFailure extends Failure {
  const CompteVerrouilleFailure();
}

/// Compte désactivé (est_actif=False côté backend).
class CompteDesactiveFailure extends Failure {
  const CompteDesactiveFailure();
}

/// Serveur injoignable ou pas de connexion réseau.
class ErreurReseauFailure extends Failure {
  const ErreurReseauFailure();
}

/// Erreur serveur inattendue (5xx) ou réponse imprévue.
class ErreurServeurFailure extends Failure {
  const ErreurServeurFailure();
}

/// Code de réinitialisation de mot de passe invalide ou expiré.
class CodeResetInvalideFailure extends Failure {
  const CodeResetInvalideFailure();
}

/// Trop de demandes de code de réinitialisation (anti-abus, 429).
class TropDeDemandesFailure extends Failure {
  const TropDeDemandesFailure();
}

/// Erreur de validation non couverte par un code métier stable connu.
/// Cas résiduel : un message générique est affiché, jamais le detail brut
/// renvoyé par le serveur.
class ErreurValidationFailure extends Failure {
  const ErreurValidationFailure();
}

/// Échec d'écriture dans la base locale (Drift/SQLite) — distinct d'une
/// erreur réseau : contrairement à celle-ci, elle n'est jamais résorbée par
/// une resynchronisation automatique (voir core/sync/synchronisation_service.dart),
/// puisque l'enregistrement n'a même pas pu être mis en file d'attente.
class ErreurStockageLocalFailure extends Failure {
  const ErreurStockageLocalFailure();
}

/// Garde-fou admin : un administrateur ne peut pas modifier son propre rôle
/// ni désactiver son propre compte (voir espace admin, écran Utilisateurs).
class AutoModificationInterditeFailure extends Failure {
  const AutoModificationInterditeFailure();
}

/// Garde-fou admin : l'action rendrait le système sans administrateur actif.
class DernierAdministrateurFailure extends Failure {
  const DernierAdministrateurFailure();
}
