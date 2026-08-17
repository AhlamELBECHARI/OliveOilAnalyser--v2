/// État d'une session déjà stockée localement, déterminé sans aucun appel
/// réseau (voir AuthLocalDataSourceImpl.obtenirEtatSessionLocale) — utilisé
/// au démarrage de l'app pour décider si l'utilisateur entre directement
/// (hors ligne y compris) ou doit repasser par l'écran de connexion.
enum EtatSessionLocale {
  /// Aucun token stocké : jamais connecté, ou déconnexion volontaire.
  absente,

  /// Tokens présents et authentification réelle (login ou refresh réussi)
  /// il y a moins de 30 jours : utilisable hors ligne sans réauthentification.
  valide,

  /// Tokens présents mais la dernière authentification réelle remonte à
  /// plus de 30 jours : la session hors ligne a expiré, une reconnexion en
  /// ligne est exigée (voir cahier des charges, Partie A "Hors ligne").
  expireeHorsLigne,
}
