/// Données factices utilisées UNIQUEMENT par le Mode démo (contournement
/// frontend de l'authentification, aucun appel réseau).
///
/// ATTENTION : ce dossier `core/demo/` est volontairement isolé du reste de
/// l'application pour pouvoir être supprimé intégralement, sans effet de
/// bord, le jour où le Mode démo sera retiré du produit. N'y ajoutez rien
/// qui soit référencé depuis les couches domain/data/presentation réelles.
class DemoFakeData {
  const DemoFakeData._();

  static const String nomUtilisateurDemo = 'Utilisateur Démo';
  static const String emailUtilisateurDemo = 'demo@olive-iq.local';
  static const int nombreEchantillonsDemo = 12;
  static const int nombreAlertesDemo = 2;
}
