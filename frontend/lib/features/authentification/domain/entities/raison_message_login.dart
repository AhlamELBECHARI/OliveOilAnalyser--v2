/// Raison d'un message informatif à afficher une seule fois sur l'écran de
/// connexion, persistée localement au moment où l'événement se produit (voir
/// AuthLocalDataSourceImpl) puis consommée (lue et effacée) au premier
/// affichage de [LoginScreen] — fonctionne aussi bien pour une redirection
/// programmatique (session expirée, détectée avant même la construction du
/// router) qu'une navigation explicite (déconnexion volontaire).
enum RaisonMessageLogin {
  aucune,

  /// La session hors ligne dépassait 30 jours sans authentification réelle
  /// auprès du serveur (voir EtatSessionLocale.expireeHorsLigne).
  sessionExpireeHorsLigne,

  /// L'utilisateur s'est déconnecté volontairement alors que l'appareil
  /// était hors ligne.
  deconnexionHorsLigne,
}
