// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'OliveIQ';

  @override
  String get sousTitreApp => 'Analyse d\'Huile d\'Olive';

  @override
  String get bienvenue => 'Bienvenue !';

  @override
  String get accedezVotreEspace => 'Connectez-vous pour accéder à votre espace';

  @override
  String get champEmail => 'Email';

  @override
  String get champMotDePasse => 'Mot de passe';

  @override
  String get erreurEmailRequis => 'Email requis';

  @override
  String get erreurEmailFormatInvalide => 'Format email invalide';

  @override
  String get erreurMotDePasseRequis => 'Mot de passe requis';

  @override
  String get motDePasseOublie => 'Mot de passe oublié ?';

  @override
  String get seConnecter => 'Se connecter';

  @override
  String get ou => 'ou';

  @override
  String get modeDemo => 'Mode démo';

  @override
  String get versionApp => 'Version 1.0.0';

  @override
  String get sousTitreEmailReset =>
      'Saisissez l\'email associé à votre compte : nous vous enverrons un code de vérification à 6 chiffres.';

  @override
  String get envoyerCode => 'Envoyer le code';

  @override
  String get entrezLeCode => 'Entrez le code';

  @override
  String codeEnvoyeA(String email) {
    return 'Un code à 6 chiffres a été envoyé à $email';
  }

  @override
  String get erreurCodeRequis => 'Code requis';

  @override
  String get erreurCodeFormat => 'Le code doit contenir 6 chiffres';

  @override
  String get renvoyerLeCode => 'Renvoyer le code';

  @override
  String renvoyerLeCodeCompteur(int secondes) {
    return 'Renvoyer le code (${secondes}s)';
  }

  @override
  String get nouveauCodeEnvoye => 'Un nouveau code a été envoyé.';

  @override
  String get verifier => 'Vérifier';

  @override
  String get nouveauMotDePasse => 'Nouveau mot de passe';

  @override
  String get choisissezNouveauMotDePasse =>
      'Choisissez un nouveau mot de passe pour votre compte.';

  @override
  String get champConfirmerMotDePasse => 'Confirmer le mot de passe';

  @override
  String get erreurMinimum8Caracteres => 'Minimum 8 caractères';

  @override
  String get erreurConfirmationRequise => 'Confirmation requise';

  @override
  String get erreurMotsDePasseNeCorrespondentPas =>
      'Les mots de passe ne correspondent pas';

  @override
  String get reinitialiser => 'Réinitialiser';

  @override
  String get motDePasseReinitialiseSucces =>
      'Mot de passe réinitialisé. Vous pouvez vous reconnecter.';

  @override
  String get erreurIdentifiantsInvalides => 'Email ou mot de passe incorrect.';

  @override
  String get erreurCompteVerrouille =>
      'Compte temporairement bloqué suite à plusieurs tentatives échouées. Réessayez plus tard.';

  @override
  String get erreurCompteDesactive => 'Ce compte est désactivé.';

  @override
  String get erreurReseau =>
      'Impossible de joindre le serveur. Vérifiez votre connexion.';

  @override
  String get erreurServeur => 'Une erreur est survenue. Réessayez plus tard.';

  @override
  String get erreurCodeInvalide => 'Code invalide ou expiré.';

  @override
  String get erreurTropDeDemandes =>
      'Trop de demandes de code. Réessayez plus tard.';

  @override
  String get erreurValidationGenerique =>
      'Erreur de validation. Vérifiez les informations saisies.';

  @override
  String get bonjour => 'Bonjour,';

  @override
  String get etatLaboratoire => 'État du laboratoire';

  @override
  String get operationnel => 'Opérationnel';

  @override
  String get horsLigne => 'Hors ligne';

  @override
  String get appareilConnecteLabel => 'Appareil connecté';

  @override
  String get aucun => 'Aucun';

  @override
  String get connecte => 'Connecté';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get deconnecte => 'Déconnecté';

  @override
  String get batterie => 'Batterie';

  @override
  String get derniereSynchro => 'Dernière synchro.';

  @override
  String aujourdHuiHeure(String heure) {
    return 'Aujourd\'hui, $heure';
  }

  @override
  String dateEtHeure(String date, String heure) {
    return '$date, $heure';
  }

  @override
  String get analysesCeMois => 'Analyses ce mois';

  @override
  String get echantillonsTotaux => 'Échantillons totaux';

  @override
  String get analysesAujourdHui => 'Analyses aujourd\'hui';

  @override
  String get tempsMoyenParAnalyse => 'Temps moyen / analyse';

  @override
  String variationVsMoisDernier(String pourcentage) {
    return '$pourcentage% vs mois dernier';
  }

  @override
  String variationVsHier(String pourcentage) {
    return '$pourcentage% vs hier';
  }

  @override
  String ajoutsCeMois(String nombre) {
    return '+ $nombre ce mois';
  }

  @override
  String dureeMinSec(int min, int sec) {
    return '$min min $sec s';
  }

  @override
  String get analysesRecentesTitre => 'Analyses récentes (7 derniers jours)';

  @override
  String get septJours => '7 jours';

  @override
  String get qualiteHuilesTitre => 'Qualité des huiles (ce mois)';

  @override
  String get total => 'Total';

  @override
  String get voirRepartitionDetaillee => 'Voir la répartition détaillée';

  @override
  String get categorieEvoo => 'Extra Vierge (EVOO)';

  @override
  String get categorieVoo => 'Vierge (VOO)';

  @override
  String get categorieLampante => 'Lampante';

  @override
  String get categorieEvooCourt => 'EVOO';

  @override
  String get categorieVooCourt => 'VOO';

  @override
  String get categorieLampanteCourt => 'Lampante';

  @override
  String get activiteRecente => 'Activité récente';

  @override
  String get aucuneAnalyseRecente => 'Aucune analyse récente.';

  @override
  String get voirToutHistorique => 'Voir tout l\'historique';

  @override
  String get navAccueil => 'Accueil';

  @override
  String get navAnalyse => 'Analyse';

  @override
  String get navHistorique => 'Historique';

  @override
  String get navModeles => 'Modèles';

  @override
  String get navParametres => 'Paramètres';

  @override
  String get modeDemoBanniere =>
      'Mode démo — connecté avec le compte de démonstration.';

  @override
  String get reessayer => 'Réessayer';

  @override
  String get parametresTitre => 'Paramètres';

  @override
  String get langueSectionTitre => 'Langue';

  @override
  String get langueFrancais => 'Français';

  @override
  String get langueAnglais => 'English';

  @override
  String get compteSectionTitre => 'Compte';

  @override
  String get seDeconnecter => 'Se déconnecter';

  @override
  String get quitterModeDemo => 'Quitter le mode démo';

  @override
  String get alertesTitre => 'Alertes';

  @override
  String get aucuneAlerte => 'Aucune alerte.';

  @override
  String get alerteResolue => 'Résolue';

  @override
  String get alerteNonResolue => 'Non résolue';

  @override
  String get niveauInfo => 'Info';

  @override
  String get niveauAvertissement => 'Avertissement';

  @override
  String get niveauCritique => 'Critique';

  @override
  String get aucunResultat => 'Aucun résultat pour l\'instant.';

  @override
  String get conforme => 'Conforme';

  @override
  String get nonConforme => 'Non conforme';

  @override
  String get aucunModele => 'Aucun modèle disponible.';

  @override
  String modeleVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get modeleAlgorithmeLabel => 'Algorithme';

  @override
  String get modeleR2Label => 'R²';

  @override
  String get modeleRmsecvLabel => 'RMSECV';

  @override
  String get modeleActif => 'Actif';

  @override
  String get modeleDeprecie => 'Déprécié';

  @override
  String get detailResultatTitre => 'Détail de l\'analyse';

  @override
  String get acidite => 'Acidité';

  @override
  String get indicePeroxyde => 'Indice de peroxyde';

  @override
  String get dureeAnalyseLabel => 'Durée de l\'analyse';

  @override
  String get dateAnalyseLabel => 'Date de l\'analyse';

  @override
  String get dateCalculLabel => 'Date du résultat';

  @override
  String get commentaireLabel => 'Commentaire';

  @override
  String get analyseEnAttenteTitre => 'En attente du module Bluetooth';

  @override
  String get analyseEnAttenteTexte =>
      'La connexion à l\'analyseur spectroscopique n\'est pas encore disponible. Ce module sera activé avec l\'intégration Bluetooth.';
}
