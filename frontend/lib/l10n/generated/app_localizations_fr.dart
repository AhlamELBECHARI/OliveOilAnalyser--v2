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
  String get ajouterModeleBouton => 'Ajouter un modèle';

  @override
  String get ajouterModeleTitre => 'Importer un modèle';

  @override
  String get champNomModele => 'Nom';

  @override
  String get champVersionModele => 'Version';

  @override
  String get champObligatoire => 'Ce champ est obligatoire.';

  @override
  String get valeurNumeriqueInvalide => 'Valeur numérique invalide.';

  @override
  String get valeurDoitEtrePositive => 'La valeur doit être positive ou nulle.';

  @override
  String get champHyperparametres => 'Hyperparamètres (JSON)';

  @override
  String get champHyperparametresAide => 'Objet JSON, ex. : n_components 5';

  @override
  String get jsonInvalide => 'JSON invalide.';

  @override
  String get champDateEntrainement => 'Date d\'entraînement';

  @override
  String get choisirFichierModeleBouton => 'Sélectionner le fichier du modèle';

  @override
  String formatsFichierModeleAutorises(String formats) {
    return 'Formats acceptés : $formats';
  }

  @override
  String get modeleAjouteMessage => 'Modèle ajouté.';

  @override
  String get activerModeleAction => 'Activer';

  @override
  String get desactiverModeleAction => 'Désactiver';

  @override
  String get deprecierModeleAction => 'Marquer comme déprécié';

  @override
  String get retirerDepreciationModeleAction => 'Retirer la dépréciation';

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

  @override
  String get erreurStockageLocal =>
      'Impossible d\'enregistrer localement sur cet appareil. Réessayez.';

  @override
  String get nouvelleAnalyseTitre => 'Nouvelle Analyse';

  @override
  String get nouvelleAnalyseSousTitre =>
      'Acquisition et analyse d\'échantillon';

  @override
  String get etatRecherche => 'Recherche...';

  @override
  String get etatErreurConnexion => 'Erreur';

  @override
  String get etapeConnexionLabel => 'Connexion';

  @override
  String get etapeEchantillonLabel => 'Échantillon';

  @override
  String get etapeAnalyseLabel => 'Analyse';

  @override
  String get etapeResultatsLabel => 'Résultats';

  @override
  String get etapeConnexionRechercheTitre => 'Recherche de l\'appareil...';

  @override
  String get etapeConnexionRechercheTexte =>
      'Connexion en cours à l\'analyseur NIR appairé.';

  @override
  String get etapeConnexionEchecTitre => 'Échec de connexion';

  @override
  String get etapeConnexionEchecTexteGenerique =>
      'Bluetooth désactivé, appareil éteint ou hors de portée, ou permissions refusées.';

  @override
  String get continuerBouton => 'Continuer';

  @override
  String get configurerAppareilLien => 'Configurer l\'appareil';

  @override
  String get continuerSansAppareilLien => 'Continuer sans appareil';

  @override
  String get configurationAppareilTitre => 'Configuration de l\'appareil';

  @override
  String get configurationAppareilTexteAide =>
      'Choisissez l\'appareil à utiliser pour la connexion automatique parmi ceux déjà appairés dans les réglages Bluetooth du téléphone.';

  @override
  String get aucunAppareilAppaireTexte =>
      'Aucun appareil appairé. Appairez d\'abord le spectromètre dans les réglages Bluetooth du téléphone.';

  @override
  String get oublierAppareilParDefautBouton => 'Oublier l\'appareil par défaut';

  @override
  String get testerConnexionBouton => 'Tester';

  @override
  String get testConnexionReussi => 'Connexion réussie';

  @override
  String get testConnexionEchoue => 'Échec de la connexion';

  @override
  String get carteInformationsEchantillonTitre => 'Informations Échantillon';

  @override
  String get champIdEchantillon => 'ID Échantillon';

  @override
  String get champProducteur => 'Producteur';

  @override
  String get champVariete => 'Variété';

  @override
  String get champRegion => 'Région';

  @override
  String get champDateRecolte => 'Date de récolte';

  @override
  String get champGps => 'GPS';

  @override
  String get positionActuelleBouton => 'Position actuelle';

  @override
  String get validerInformationsBouton => 'Valider les informations';

  @override
  String get modifierBouton => 'Modifier';

  @override
  String get metadonneesCompletesTitre => 'Métadonnées complètes';

  @override
  String get metadonneesCompletesTexte =>
      'Toutes les informations requises sont renseignées.';

  @override
  String get erreurLocalisationService =>
      'Le GPS est désactivé. Activez la localisation dans les réglages de l\'appareil.';

  @override
  String get erreurLocalisationPermission =>
      'Permission de localisation refusée. Autorisez-la dans les réglages de l\'application.';

  @override
  String get erreurLocalisationGenerique =>
      'Impossible d\'obtenir la position actuelle.';

  @override
  String get gpsNonRenseigne => 'Non renseignée';

  @override
  String get selectionnerDate => 'Sélectionner';

  @override
  String get carteConnexionInstrumentTitre => 'Connexion & Instrument';

  @override
  String get voirDetailsInstrument => 'Voir les détails de l\'instrument';

  @override
  String get aucunInstrumentConnecte => 'Aucun instrument connecté';

  @override
  String get rechercheInstrumentTexte =>
      'Recherche de l\'analyseur en cours...';

  @override
  String get reessayerConnexionBouton => 'Réessayer';

  @override
  String get numeroSerieLabel => 'SN';

  @override
  String get firmwareLabel => 'Firmware';

  @override
  String get carteParametresAcquisitionTitre => 'Paramètres d\'Acquisition';

  @override
  String get parametresAcquisitionIndisponible =>
      'Disponible une fois le protocole du fabricant documenté.';

  @override
  String get carteApercuTempsReelTitre => 'Aperçu en Temps Réel';

  @override
  String get signalQualiteLabel => 'Signal de qualité';

  @override
  String get absorbanceLabel => 'Absorbance';

  @override
  String get longueurOndeLabel => 'Longueur d\'onde (nm)';

  @override
  String get snrLabel => 'SNR';

  @override
  String get intensiteLabel => 'Intensité';

  @override
  String get bruitLabel => 'Bruit';

  @override
  String get qualiteGlobaleLabel => 'Qualité globale';

  @override
  String get demarrerAnalyseBouton => 'Démarrer l\'analyse';

  @override
  String get annulerBouton => 'Annuler';

  @override
  String get analyseTermineeTitre => 'Analyse terminée';

  @override
  String get analyseTermineeTexte =>
      'Le spectre a été acquis et enregistré localement. Il sera synchronisé automatiquement et pris en compte dans l\'historique dès qu\'un résultat sera calculé.';

  @override
  String get nouvelleAnalyseBouton => 'Nouvelle analyse';

  @override
  String enAttenteSynchronisation(int nombre) {
    return '$nombre en attente de synchronisation';
  }

  @override
  String get historiquesTitre => 'Historiques';

  @override
  String get historiquesSousTitre => 'Consultation des analyses';

  @override
  String get rechercherPlaceholder =>
      'Rechercher par ID, producteur, variété, région...';

  @override
  String get filtreTout => 'Tout';

  @override
  String get filtreQualite => 'Qualité';

  @override
  String get filtreVariete => 'Variété';

  @override
  String get filtreRegion => 'Région';

  @override
  String get filtrePlus => 'Plus de filtres';

  @override
  String get apercuTitre => 'Aperçu';

  @override
  String get totalAnalysesLabel => 'Total analyses';

  @override
  String get ceMoisLabel => 'Ce mois';

  @override
  String get chargerPlusAnalyses => 'Charger plus d\'analyses';

  @override
  String get statistiquesRapidesTitre => 'Statistiques rapides';

  @override
  String get tendanceAciditeMoyenneLabel => 'Acidité moyenne';

  @override
  String get meilleureQualiteLabel => 'Meilleure qualité';

  @override
  String get plusForteAciditeLabel => 'Plus forte acidité';

  @override
  String get analysesParJourLabel => 'Analyses / jour';

  @override
  String get exporterBouton => 'Exporter';

  @override
  String get exportLanceMessage =>
      'Export lancé. Vous serez notifié une fois le rapport prêt.';

  @override
  String get exportTitre => 'Exporter';

  @override
  String get exportContenuLabel => 'Quoi exporter';

  @override
  String get exportContenuResultats => 'Résultats';

  @override
  String get exportContenuSpectres => 'Spectres bruts';

  @override
  String get exportContenuLesDeux => 'Les deux';

  @override
  String get exportQuellesAnalysesLabel => 'Quelles analyses';

  @override
  String exportToutesFiltresLabel(int total) {
    return 'Toutes les analyses correspondant aux filtres actifs ($total)';
  }

  @override
  String get exportSelectionManuelleLabel => 'Sélection manuelle';

  @override
  String get exportFormatLabel => 'Format';

  @override
  String get choisirAnalysesBouton => 'Choisir les analyses';

  @override
  String get exportTelechargeMessage => 'Export téléchargé.';

  @override
  String get exportAnnuleMessage => 'Export annulé.';

  @override
  String selectionCompteurTitre(int nombre) {
    return '$nombre sélectionné(s)';
  }

  @override
  String get toutSelectionnerBouton => 'Tout sélectionner';

  @override
  String get validerExportBouton => 'Valider l\'export';

  @override
  String get filtresTitre => 'Filtres';

  @override
  String get appliquerBouton => 'Appliquer';

  @override
  String get reinitialiserBouton => 'Réinitialiser';

  @override
  String get dateDebutLabel => 'Date de début';

  @override
  String get dateFinLabel => 'Date de fin';

  @override
  String get monProfilTitre => 'Mon Profil';

  @override
  String get monProfilSousTitre => 'Informations du compte & préférences';

  @override
  String get roleAdministrateurLabel => 'Administrateur';

  @override
  String get roleUtilisateurLabel => 'Utilisateur';

  @override
  String get champTelephone => 'Téléphone';

  @override
  String get champNom => 'Nom';

  @override
  String get champFonction => 'Fonction';

  @override
  String get champLaboratoire => 'Laboratoire';

  @override
  String get champInstitution => 'Institution';

  @override
  String get membreDepuisLabel => 'Membre depuis';

  @override
  String get changerPhotoProfil => 'Changer la photo de profil';

  @override
  String get informationsPersonnellesTitre => 'Informations personnelles';

  @override
  String get informationsPersonnellesSousTitre =>
      'Gérer vos informations de profil';

  @override
  String get securiteTitre => 'Sécurité';

  @override
  String get securiteSousTitre => 'Mot de passe, authentification';

  @override
  String get sessionsActivesTitre => 'Sessions actives';

  @override
  String get sessionsActivesSousTitre => 'Gérer vos appareils connectés';

  @override
  String sessionsActivesCompteur(int nombre) {
    return '$nombre actives';
  }

  @override
  String get preferencesSectionTitre => 'Préférences';

  @override
  String get preferencesAnalyseTitre => 'Préférences d\'analyse';

  @override
  String get preferencesAnalyseSousTitre =>
      'Unités, seuils, paramètres par défaut';

  @override
  String get notificationsPreferenceTitre => 'Notifications';

  @override
  String get notificationsPreferenceSousTitre =>
      'Gérer les alertes et rapports';

  @override
  String get themeTitre => 'Thème';

  @override
  String get themeClair => 'Clair';

  @override
  String get themeSombreLabel => 'Sombre';

  @override
  String get themeSysteme => 'Système';

  @override
  String get donneesSyncSectionTitre => 'Données & Synchronisation';

  @override
  String get synchronisationCloudTitre => 'Synchronisation cloud';

  @override
  String derniereSyncLabel(String heure) {
    return 'Dernière sync : $heure';
  }

  @override
  String get syncDesactiveeLabel => 'Synchronisation désactivée';

  @override
  String get syncJamaisLabel => 'Jamais synchronisé';

  @override
  String get gestionDonneesTitre => 'Gestion des données';

  @override
  String get gestionDonneesSousTitre =>
      'Exporter, supprimer ou archiver des données';

  @override
  String get espaceStockageTitre => 'Espace de stockage';

  @override
  String get aProposSectionTitre => 'À propos';

  @override
  String get aProposOliveIQTitre => 'À propos d\'OliveIQ';

  @override
  String versionBuildLabel(String version, String build) {
    return 'Version $version • Build $build';
  }

  @override
  String get centreAideTitre => 'Centre d\'aide';

  @override
  String get centreAideSousTitre => 'Documentation et support';

  @override
  String get centreAideContenu =>
      'Pour toute question sur l\'utilisation d\'OliveIQ (acquisition d\'une analyse, lecture des résultats, connexion de l\'analyseur), contactez le support de votre laboratoire ou écrivez à support@olive-iq.local.\n\nUne documentation complète sera ajoutée ici prochainement.';

  @override
  String get mentionsLegalesTitre => 'Mentions légales & Confidentialité';

  @override
  String get mentionsLegalesContenu =>
      'OliveIQ traite les données d\'analyse (échantillons, spectres, résultats) exclusivement dans le cadre du suivi qualité de l\'huile d\'olive, pour le compte de votre organisation.\n\nLes données personnelles du compte (nom, email, téléphone, photo de profil) ne sont utilisées que pour l\'identification et le fonctionnement de l\'application, jamais partagées avec des tiers.\n\nCette section sera complétée avec le texte légal définitif de votre organisation.';

  @override
  String get seDeconnecterConfirmationTitre => 'Se déconnecter ?';

  @override
  String get seDeconnecterConfirmationTexte =>
      'Vous devrez vous reconnecter pour accéder à votre compte.';

  @override
  String get confirmerBouton => 'Confirmer';

  @override
  String get enregistrerBouton => 'Enregistrer';

  @override
  String get profilMisAJourMessage => 'Profil mis à jour.';

  @override
  String get photoProfilMiseAJourMessage => 'Photo de profil mise à jour.';

  @override
  String get ancienMotDePasseLabel => 'Mot de passe actuel';

  @override
  String get changerMotDePasseBouton => 'Changer le mot de passe';

  @override
  String get motDePasseModifieMessage => 'Mot de passe modifié avec succès.';

  @override
  String sessionCreeeLabel(String date) {
    return 'Connectée le $date';
  }

  @override
  String sessionExpireLabel(String date) {
    return 'Expire le $date';
  }

  @override
  String get sessionCouranteLabel => 'Cet appareil';

  @override
  String get revoquerSessionBouton => 'Révoquer';

  @override
  String get revoquerToutesSaufCouranteBouton =>
      'Révoquer toutes les autres sessions';

  @override
  String get aucuneSessionMessage => 'Aucune session active.';

  @override
  String get seuilAciditeConformiteLabel => 'Seuil de conformité — Acidité';

  @override
  String get seuilPeroxydeConformiteLabel =>
      'Seuil de conformité — Indice de peroxyde';

  @override
  String get seuilEvooLabel => 'Seuil Extra Vierge (EVOO)';

  @override
  String get seuilVooLabel => 'Seuil Vierge (VOO)';

  @override
  String get lectureSeuleAdministrateurMessage =>
      'Modifiable uniquement par un administrateur.';

  @override
  String get seuilsMisAJourMessage => 'Seuils mis à jour.';

  @override
  String get exporterMesDonneesBouton => 'Exporter mes données';

  @override
  String get viderCacheBouton => 'Vider le cache local';

  @override
  String get viderCacheConfirmationTitre => 'Vider le cache ?';

  @override
  String get viderCacheConfirmationTexte =>
      'Les fichiers temporaires seront supprimés. Les analyses en attente de synchronisation ne sont jamais affectées.';

  @override
  String get cacheVideMessage => 'Cache vidé.';
}
