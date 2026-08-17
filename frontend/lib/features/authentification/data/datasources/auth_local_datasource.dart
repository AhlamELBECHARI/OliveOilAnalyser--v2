import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/token_storage_service.dart';
import '../../domain/entities/etat_session_locale.dart';
import '../../domain/entities/raison_message_login.dart';

abstract class AuthLocalDataSource {
  Future<void> enregistrerSession({
    required String accessToken,
    required String refreshToken,
    required String role,
  });

  /// État de la session stockée localement — voir EtatSessionLocale. Aucun
  /// appel réseau : c'est ce qui permet à main.dart de router directement
  /// vers l'app hors ligne, sans attendre quoi que ce soit du serveur. Une
  /// session dont la dernière authentification réelle dépasse 30 jours est
  /// effacée et signalée via [enregistrerRaisonMessageLogin].
  Future<EtatSessionLocale> obtenirEtatSessionLocale();

  Future<String?> obtenirRoleSession();

  Future<void> supprimerSession();

  Future<void> enregistrerRaisonMessageLogin(RaisonMessageLogin raison);

  /// Lit puis efface la raison en attente : ne doit être affichée qu'une
  /// seule fois, au tout premier rendu de l'écran de connexion qui suit.
  Future<RaisonMessageLogin> consommerRaisonMessageLogin();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final TokenStorageService tokenStorage;
  final SharedPreferences preferences;

  const AuthLocalDataSourceImpl({required this.tokenStorage, required this.preferences});

  static const _cleRaisonMessageLogin = 'olive_iq_raison_message_login';
  static const _dureeValiditeHorsLigne = Duration(days: 30);

  @override
  Future<void> enregistrerSession({
    required String accessToken,
    required String refreshToken,
    required String role,
  }) async {
    await tokenStorage.enregistrerTokens(accessToken: accessToken, refreshToken: refreshToken);
    await tokenStorage.enregistrerRole(role);
    await tokenStorage.enregistrerDerniereAuthentification(DateTime.now());
  }

  @override
  Future<EtatSessionLocale> obtenirEtatSessionLocale() async {
    final possedeTokens = await tokenStorage.possedeTokens();
    if (!possedeTokens) return EtatSessionLocale.absente;

    final derniereAuth = await tokenStorage.lireDerniereAuthentification();
    if (derniereAuth == null) {
      // Session créée avant l'introduction de cet horodatage : on lui
      // accorde le bénéfice du doute une seule fois plutôt que de
      // déconnecter silencieusement un utilisateur déjà connecté.
      await tokenStorage.enregistrerDerniereAuthentification(DateTime.now());
      return EtatSessionLocale.valide;
    }

    final expiree = DateTime.now().difference(derniereAuth) > _dureeValiditeHorsLigne;
    if (!expiree) return EtatSessionLocale.valide;

    await tokenStorage.supprimerTokens();
    await enregistrerRaisonMessageLogin(RaisonMessageLogin.sessionExpireeHorsLigne);
    return EtatSessionLocale.expireeHorsLigne;
  }

  @override
  Future<String?> obtenirRoleSession() => tokenStorage.lireRole();

  @override
  Future<void> supprimerSession() => tokenStorage.supprimerTokens();

  @override
  Future<void> enregistrerRaisonMessageLogin(RaisonMessageLogin raison) =>
      preferences.setString(_cleRaisonMessageLogin, raison.name);

  @override
  Future<RaisonMessageLogin> consommerRaisonMessageLogin() async {
    final valeur = preferences.getString(_cleRaisonMessageLogin);
    if (valeur != null) await preferences.remove(_cleRaisonMessageLogin);
    return RaisonMessageLogin.values.firstWhere(
      (raison) => raison.name == valeur,
      orElse: () => RaisonMessageLogin.aucune,
    );
  }
}
