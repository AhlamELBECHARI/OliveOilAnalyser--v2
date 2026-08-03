import 'package:equatable/equatable.dart';

/// Types d'échec métier renvoyés par les repositories au domain, indépendants
/// de toute origine technique (Dio, storage...). La couche Presentation ne
/// manipule jamais d'exception brute, uniquement ces [Failure].
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Identifiants invalides (401) : volontairement générique, ne précise
/// jamais si c'est l'email ou le mot de passe qui est erroné.
class IdentifiantsInvalidesFailure extends Failure {
  const IdentifiantsInvalidesFailure()
      : super('Email ou mot de passe incorrect.');
}

/// Compte temporairement verrouillé suite à trop de tentatives échouées.
class CompteVerrouilleFailure extends Failure {
  const CompteVerrouilleFailure()
      : super('Compte temporairement bloqué suite à plusieurs tentatives échouées. Réessayez plus tard.');
}

/// Serveur injoignable ou pas de connexion réseau.
class ErreurReseauFailure extends Failure {
  const ErreurReseauFailure()
      : super('Impossible de joindre le serveur. Vérifiez votre connexion.');
}

/// Erreur serveur inattendue (5xx) ou réponse imprévue.
class ErreurServeurFailure extends Failure {
  const ErreurServeurFailure([super.message = 'Une erreur est survenue. Réessayez plus tard.']);
}

/// Erreur de validation locale ou renvoyée par l'API (400).
class ErreurValidationFailure extends Failure {
  const ErreurValidationFailure(super.message);
}
