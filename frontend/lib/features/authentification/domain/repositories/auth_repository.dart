import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_session_entity.dart';
import '../entities/etat_session_locale.dart';
import '../entities/raison_message_login.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSessionEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> demanderResetMotDePasse({
    required String email,
  });

  Future<Either<Failure, Unit>> verifierCodeReset({
    required String email,
    required String code,
  });

  Future<Either<Failure, Unit>> confirmerResetMotDePasse({
    required String email,
    required String code,
    required String nouveauMotDePasse,
  });

  /// État de la session stockée localement (absente / valide / expirée hors
  /// ligne depuis plus de 30 jours) — voir EtatSessionLocale. Ne fait aucun
  /// appel réseau : utilisé au démarrage de l'app pour entrer directement,
  /// y compris hors ligne (voir main.dart).
  Future<EtatSessionLocale> obtenirEtatSessionLocale();

  /// Rôle persisté au dernier login réussi ('utilisateur'/'administrateur'),
  /// ou `null` si aucune session — utilisé au démarrage de l'app pour
  /// choisir la coquille de navigation (utilisateur/admin) sans appel
  /// réseau (voir main.dart).
  Future<String?> obtenirRoleSession();

  /// Déconnexion volontaire. Si l'appareil est hors ligne au moment de
  /// l'appel, enregistre [RaisonMessageLogin.deconnexionHorsLigne] pour que
  /// l'écran de connexion prévienne l'utilisateur qu'une reconnexion en
  /// ligne sera nécessaire.
  Future<void> deconnecter();

  /// Lit puis efface la raison en attente d'un message à afficher sur
  /// l'écran de connexion (session expirée hors ligne, déconnexion hors
  /// ligne...). Voir AuthLocalDataSourceImpl.consommerRaisonMessageLogin.
  Future<RaisonMessageLogin> consommerRaisonMessageLogin();
}
