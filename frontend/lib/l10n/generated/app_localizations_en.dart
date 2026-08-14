// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'OliveIQ';

  @override
  String get sousTitreApp => 'Olive Oil Analysis';

  @override
  String get bienvenue => 'Welcome!';

  @override
  String get accedezVotreEspace => 'Log in to access your workspace';

  @override
  String get champEmail => 'Email';

  @override
  String get champMotDePasse => 'Password';

  @override
  String get erreurEmailRequis => 'Email is required';

  @override
  String get erreurEmailFormatInvalide => 'Invalid email format';

  @override
  String get erreurMotDePasseRequis => 'Password is required';

  @override
  String get motDePasseOublie => 'Forgot password?';

  @override
  String get seConnecter => 'Log in';

  @override
  String get ou => 'or';

  @override
  String get modeDemo => 'Demo mode';

  @override
  String get versionApp => 'Version 1.0.0';

  @override
  String get sousTitreEmailReset =>
      'Enter the email linked to your account: we\'ll send you a 6-digit verification code.';

  @override
  String get envoyerCode => 'Send code';

  @override
  String get entrezLeCode => 'Enter the code';

  @override
  String codeEnvoyeA(String email) {
    return 'A 6-digit code has been sent to $email';
  }

  @override
  String get erreurCodeRequis => 'Code is required';

  @override
  String get erreurCodeFormat => 'The code must contain 6 digits';

  @override
  String get renvoyerLeCode => 'Resend code';

  @override
  String renvoyerLeCodeCompteur(int secondes) {
    return 'Resend code (${secondes}s)';
  }

  @override
  String get nouveauCodeEnvoye => 'A new code has been sent.';

  @override
  String get verifier => 'Verify';

  @override
  String get nouveauMotDePasse => 'New password';

  @override
  String get choisissezNouveauMotDePasse =>
      'Choose a new password for your account.';

  @override
  String get champConfirmerMotDePasse => 'Confirm password';

  @override
  String get erreurMinimum8Caracteres => 'Minimum 8 characters';

  @override
  String get erreurConfirmationRequise => 'Confirmation is required';

  @override
  String get erreurMotsDePasseNeCorrespondentPas => 'Passwords do not match';

  @override
  String get reinitialiser => 'Reset';

  @override
  String get motDePasseReinitialiseSucces =>
      'Password reset. You can now log back in.';

  @override
  String get erreurIdentifiantsInvalides => 'Incorrect email or password.';

  @override
  String get erreurCompteVerrouille =>
      'Account temporarily locked after several failed attempts. Try again later.';

  @override
  String get erreurCompteDesactive => 'This account has been disabled.';

  @override
  String get erreurReseau =>
      'Unable to reach the server. Check your connection.';

  @override
  String get erreurServeur => 'Something went wrong. Try again later.';

  @override
  String get erreurCodeInvalide => 'Invalid or expired code.';

  @override
  String get erreurTropDeDemandes => 'Too many code requests. Try again later.';

  @override
  String get erreurValidationGenerique =>
      'Validation error. Check the information you entered.';

  @override
  String get erreurAutoModificationInterdite =>
      'You cannot perform this action on your own account.';

  @override
  String get erreurDernierAdministrateur =>
      'Cannot do this: at least one active administrator must remain.';

  @override
  String get bonjour => 'Hello,';

  @override
  String get etatLaboratoire => 'Lab status';

  @override
  String get operationnel => 'Operational';

  @override
  String get horsLigne => 'Offline';

  @override
  String get appareilConnecteLabel => 'Connected device';

  @override
  String get aucun => 'None';

  @override
  String get connecte => 'Connected';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get deconnecte => 'Disconnected';

  @override
  String get batterie => 'Battery';

  @override
  String get derniereSynchro => 'Last sync';

  @override
  String aujourdHuiHeure(String heure) {
    return 'Today, $heure';
  }

  @override
  String dateEtHeure(String date, String heure) {
    return '$date, $heure';
  }

  @override
  String get analysesCeMois => 'Analyses this month';

  @override
  String get echantillonsTotaux => 'Total samples';

  @override
  String get analysesAujourdHui => 'Analyses today';

  @override
  String get tempsMoyenParAnalyse => 'Avg. time / analysis';

  @override
  String variationVsMoisDernier(String pourcentage) {
    return '$pourcentage% vs last month';
  }

  @override
  String variationVsHier(String pourcentage) {
    return '$pourcentage% vs yesterday';
  }

  @override
  String ajoutsCeMois(String nombre) {
    return '+ $nombre this month';
  }

  @override
  String dureeMinSec(int min, int sec) {
    return '$min min $sec s';
  }

  @override
  String get analysesRecentesTitre => 'Recent analyses (last 7 days)';

  @override
  String get septJours => '7 days';

  @override
  String get qualiteHuilesTitre => 'Oil quality (this month)';

  @override
  String get total => 'Total';

  @override
  String get voirRepartitionDetaillee => 'View detailed breakdown';

  @override
  String get categorieEvoo => 'Extra Virgin (EVOO)';

  @override
  String get categorieVoo => 'Virgin (VOO)';

  @override
  String get categorieLampante => 'Lampante';

  @override
  String get categorieEvooCourt => 'EVOO';

  @override
  String get categorieVooCourt => 'VOO';

  @override
  String get categorieLampanteCourt => 'Lampante';

  @override
  String get activiteRecente => 'Recent activity';

  @override
  String get aucuneAnalyseRecente => 'No recent analyses.';

  @override
  String get voirToutHistorique => 'View full history';

  @override
  String get navAccueil => 'Home';

  @override
  String get navAnalyse => 'Analysis';

  @override
  String get navHistorique => 'History';

  @override
  String get navModeles => 'Models';

  @override
  String get navParametres => 'Settings';

  @override
  String get navSupervision => 'Supervision';

  @override
  String get navUtilisateurs => 'Users';

  @override
  String get navAnalyses => 'Analyses';

  @override
  String get navAdministration => 'Administration';

  @override
  String get supervisionTitre => 'Supervision';

  @override
  String get etatSystemeTitre => 'System status';

  @override
  String get apiLabel => 'API';

  @override
  String get baseDeDonneesLabel => 'Database';

  @override
  String get tailleBaseLabel => 'Database size';

  @override
  String get derniereSauvegardeLabel => 'Last backup';

  @override
  String get analyseursRecentsLabel => 'Recent analyzers';

  @override
  String get nonDisponibleLabel => 'Not available';

  @override
  String get disponibleLabel => 'Available';

  @override
  String get indisponibleLabel => 'Unavailable';

  @override
  String get activiteJourTitre => 'Today\'s activity';

  @override
  String get utilisateursConnectesLabel => 'Connected users';

  @override
  String get sessionsActivesLabel => 'Active sessions';

  @override
  String get analysesAujourdHuiLabel => 'Analyses today';

  @override
  String get analysesSemaineLabel => 'Analyses this week';

  @override
  String get alertesNonResoluesTitre => 'Unresolved alerts';

  @override
  String get aucuneAlerteNonResolueTexte => 'No unresolved alerts.';

  @override
  String get activiteOperateurTitre => 'Activity by operator';

  @override
  String get aucuneActiviteOperateurTexte => 'No activity recorded yet.';

  @override
  String get anomaliesTitre => 'Anomalies to watch';

  @override
  String get comptesVerrouillesLabel => 'Locked accounts';

  @override
  String get modelesDepreciesUtilisesLabel => 'Deprecated models still used';

  @override
  String get resoudreBouton => 'Resolve';

  @override
  String get ecranAdminBientotDisponibleTexte =>
      'This screen will be available soon.';

  @override
  String get rechercherUtilisateurPlaceholder => 'Search by name, email...';

  @override
  String get filtreRoleLabel => 'Role';

  @override
  String get filtreStatutLabel => 'Status';

  @override
  String get filtreVerrouilleLabel => 'Locked';

  @override
  String get roleUtilisateurLabel => 'User';

  @override
  String get roleAdministrateurLabel => 'Administrator';

  @override
  String get statutActifLabel => 'Active';

  @override
  String get statutInactifLabel => 'Inactive';

  @override
  String get aucunUtilisateurTexte => 'No users found.';

  @override
  String get creerCompteBouton => 'Create account';

  @override
  String get creerCompteTitre => 'Create account';

  @override
  String get champNomUtilisateur => 'Name';

  @override
  String get champRoleLabel => 'Role';

  @override
  String get creerBouton => 'Create';

  @override
  String get dateDerniereConnexionLabel => 'Last login';

  @override
  String get dateInscriptionLabel => 'Joined';

  @override
  String get nombreAnalysesLabel => 'Number of analyses';

  @override
  String get tentativesEchoueesLabel => 'Failed attempts';

  @override
  String get modifierRoleAction => 'Change role';

  @override
  String get activerCompteAction => 'Activate account';

  @override
  String get desactiverCompteAction => 'Deactivate account';

  @override
  String get deverrouillerCompteAction => 'Unlock account';

  @override
  String get declencherResetAction => 'Send reset code';

  @override
  String get resetDeclencheMessage => 'Reset code sent.';

  @override
  String get voirAnalysesUtilisateurAction => 'View analyses';

  @override
  String get jamaisConnecteLabel => 'Never logged in';

  @override
  String get confirmerDesactivationTexte =>
      'Deactivate this account? The user will no longer be able to log in, but their analyses are kept.';

  @override
  String get confirmerChangerRoleAdminTexte =>
      'Grant administrator role to this user?';

  @override
  String get confirmerRetrograderTexte =>
      'Remove administrator role from this user?';

  @override
  String get journalAuditTitre => 'Audit log';

  @override
  String get aucuneEntreeJournalTexte => 'No entries yet.';

  @override
  String get gestionDonneesAdminTitre => 'Data management';

  @override
  String get statistiquesOccupationTitre => 'Database usage';

  @override
  String get exportGlobalBouton => 'Export all analyses';

  @override
  String get purgeTitre => 'Purge data';

  @override
  String get purgeDescriptionTexte =>
      'Permanently deletes samples (and their spectra/results) older than the chosen date.';

  @override
  String get choisirDateLimitePurge => 'Choose the cutoff date';

  @override
  String get previsualiserPurgeBouton => 'Preview';

  @override
  String get purgeApercuTitre => 'Will be deleted:';

  @override
  String get confirmerPurgeBouton => 'Confirm purge';

  @override
  String get purgeIrreversibleAvertissement => 'This action is irreversible.';

  @override
  String get purgeReussieMessage => 'Purge completed.';

  @override
  String get administrationTitre => 'Administration';

  @override
  String get journalAuditSousTitre => 'History of sensitive actions';

  @override
  String get gestionDonneesSousTitreAdmin => 'Global export, purge, usage';

  @override
  String get configurationSousTitreAdmin =>
      'Compliance and classification thresholds';

  @override
  String get monProfilAdminSousTitre => 'Personal profile, log out';

  @override
  String get modeDemoBanniere => 'Demo mode — connected with the demo account.';

  @override
  String get reessayer => 'Try again';

  @override
  String get parametresTitre => 'Settings';

  @override
  String get langueSectionTitre => 'Language';

  @override
  String get langueFrancais => 'Français';

  @override
  String get langueAnglais => 'English';

  @override
  String get compteSectionTitre => 'Account';

  @override
  String get seDeconnecter => 'Log out';

  @override
  String get quitterModeDemo => 'Exit demo mode';

  @override
  String get alertesTitre => 'Alerts';

  @override
  String get aucuneAlerte => 'No alerts.';

  @override
  String get alerteResolue => 'Resolved';

  @override
  String get alerteNonResolue => 'Unresolved';

  @override
  String get niveauInfo => 'Info';

  @override
  String get niveauAvertissement => 'Warning';

  @override
  String get niveauCritique => 'Critical';

  @override
  String get aucunResultat => 'No results yet.';

  @override
  String get conforme => 'Compliant';

  @override
  String get nonConforme => 'Non-compliant';

  @override
  String get aucunModele => 'No models available.';

  @override
  String modeleVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get modeleAlgorithmeLabel => 'Algorithm';

  @override
  String get modeleR2Label => 'R²';

  @override
  String get modeleRmsecvLabel => 'RMSECV';

  @override
  String get modeleExactitudeLabel => 'Accuracy';

  @override
  String get modelePrecisionLabel => 'Precision';

  @override
  String get typeModeleRegressionLabel => 'Regression';

  @override
  String get typeModeleClassificationLabel => 'Classification';

  @override
  String get modeleReferenceLabel => 'Reference model';

  @override
  String get modeleActif => 'Active';

  @override
  String get modeleDeprecie => 'Deprecated';

  @override
  String get ajouterModeleBouton => 'Add a model';

  @override
  String get ajouterModeleTitre => 'Import a model';

  @override
  String get champNomModele => 'Name';

  @override
  String get champVersionModele => 'Version';

  @override
  String get champObligatoire => 'This field is required.';

  @override
  String get valeurNumeriqueInvalide => 'Invalid numeric value.';

  @override
  String get valeurDoitEtrePositive => 'The value must be zero or positive.';

  @override
  String get champHyperparametres => 'Hyperparameters (JSON)';

  @override
  String get champHyperparametresAide => 'JSON object, e.g. n_components 5';

  @override
  String get jsonInvalide => 'Invalid JSON.';

  @override
  String get champDateEntrainement => 'Training date';

  @override
  String get choisirFichierModeleBouton => 'Select the model file';

  @override
  String formatsFichierModeleAutorises(String formats) {
    return 'Accepted formats: $formats';
  }

  @override
  String get modeleAjouteMessage => 'Model added.';

  @override
  String get activerModeleAction => 'Activate';

  @override
  String get desactiverModeleAction => 'Deactivate';

  @override
  String get deprecierModeleAction => 'Mark as deprecated';

  @override
  String get retirerDepreciationModeleAction => 'Remove deprecation';

  @override
  String get detailResultatTitre => 'Analysis detail';

  @override
  String get acidite => 'Acidity';

  @override
  String get indicePeroxyde => 'Peroxide index';

  @override
  String get dureeAnalyseLabel => 'Analysis duration';

  @override
  String get dateAnalyseLabel => 'Analysis date';

  @override
  String get dateCalculLabel => 'Result date';

  @override
  String get commentaireLabel => 'Comment';

  @override
  String get ongletResultatsLabel => 'Results';

  @override
  String get ongletSpectreLabel => 'Spectrum';

  @override
  String replicatLabel(int numero) {
    return 'Replicate $numero';
  }

  @override
  String get blocComparaisonLaboTitre => 'Comparison with lab reference';

  @override
  String get valeurPrediteLabel => 'Predicted value';

  @override
  String get valeurReferenceLabel => 'Lab reference';

  @override
  String get ecartLabel => 'Deviation';

  @override
  String get authenticiteReferenceLabel => 'Actual nature';

  @override
  String get nombrePointsLabel => 'Number of points';

  @override
  String get exporterSpectreBouton => 'Export this spectrum';

  @override
  String get aucuneDonneeSpectreTexte =>
      'No spectrum synced for this sample yet.';

  @override
  String get analyseEnAttenteTitre => 'Waiting for the Bluetooth module';

  @override
  String get analyseEnAttenteTexte =>
      'Connecting to the spectroscopic analyzer isn\'t available yet. This module will be enabled once Bluetooth integration ships.';

  @override
  String get erreurStockageLocal =>
      'Couldn\'t save locally on this device. Please try again.';

  @override
  String get nouvelleAnalyseTitre => 'New Analysis';

  @override
  String get nouvelleAnalyseSousTitre => 'Sample acquisition and analysis';

  @override
  String get etatRecherche => 'Searching...';

  @override
  String get etatErreurConnexion => 'Error';

  @override
  String get etapeConnexionLabel => 'Connection';

  @override
  String get etapeEchantillonLabel => 'Sample';

  @override
  String get etapeAnalyseLabel => 'Analysis';

  @override
  String get etapeResultatsLabel => 'Results';

  @override
  String get etapeConnexionRechercheTitre => 'Searching for device...';

  @override
  String get etapeConnexionRechercheTexte =>
      'Connecting to the paired NIR analyzer.';

  @override
  String get etapeConnexionEchecTitre => 'Connection failed';

  @override
  String get etapeConnexionEchecTexteGenerique =>
      'Bluetooth disabled, device off or out of range, or permissions denied.';

  @override
  String get continuerBouton => 'Continue';

  @override
  String get configurerAppareilLien => 'Configure device';

  @override
  String get continuerSansAppareilLien => 'Continue without a device';

  @override
  String get configurationAppareilTitre => 'Device configuration';

  @override
  String get configurationAppareilTexteAide =>
      'Choose the device to use for automatic connection among those already paired in the phone\'s Bluetooth settings.';

  @override
  String get aucunAppareilAppaireTexte =>
      'No paired device. Pair the spectrometer first in the phone\'s Bluetooth settings.';

  @override
  String get oublierAppareilParDefautBouton => 'Forget default device';

  @override
  String get testerConnexionBouton => 'Test';

  @override
  String get testConnexionReussi => 'Connection successful';

  @override
  String get testConnexionEchoue => 'Connection failed';

  @override
  String get carteInformationsEchantillonTitre => 'Sample Information';

  @override
  String get champIdEchantillon => 'Sample ID';

  @override
  String get champProducteur => 'Producer';

  @override
  String get champVariete => 'Variety';

  @override
  String get champRegion => 'Region';

  @override
  String get champDateRecolte => 'Harvest date';

  @override
  String get champGps => 'GPS';

  @override
  String get positionActuelleBouton => 'Current position';

  @override
  String get validerInformationsBouton => 'Validate information';

  @override
  String get modifierBouton => 'Edit';

  @override
  String get metadonneesCompletesTitre => 'Metadata complete';

  @override
  String get metadonneesCompletesTexte =>
      'All required information has been provided.';

  @override
  String get erreurLocalisationService =>
      'GPS is disabled. Enable location in the device settings.';

  @override
  String get erreurLocalisationPermission =>
      'Location permission denied. Allow it in the app settings.';

  @override
  String get erreurLocalisationGenerique =>
      'Couldn\'t get the current position.';

  @override
  String get gpsNonRenseigne => 'Not set';

  @override
  String get selectionnerDate => 'Select';

  @override
  String get carteConnexionInstrumentTitre => 'Connection & Instrument';

  @override
  String get voirDetailsInstrument => 'View instrument details';

  @override
  String get aucunInstrumentConnecte => 'No instrument connected';

  @override
  String get rechercheInstrumentTexte => 'Searching for the analyzer...';

  @override
  String get reessayerConnexionBouton => 'Retry';

  @override
  String get numeroSerieLabel => 'SN';

  @override
  String get firmwareLabel => 'Firmware';

  @override
  String get carteParametresAcquisitionTitre => 'Acquisition Settings';

  @override
  String get parametresAcquisitionIndisponible =>
      'Available once the manufacturer\'s protocol is documented.';

  @override
  String get carteApercuTempsReelTitre => 'Real-Time Preview';

  @override
  String get signalQualiteLabel => 'Signal quality';

  @override
  String get absorbanceLabel => 'Absorbance';

  @override
  String get longueurOndeLabel => 'Wavelength (nm)';

  @override
  String get snrLabel => 'SNR';

  @override
  String get intensiteLabel => 'Intensity';

  @override
  String get bruitLabel => 'Noise';

  @override
  String get qualiteGlobaleLabel => 'Overall quality';

  @override
  String get demarrerAnalyseBouton => 'Start analysis';

  @override
  String get annulerBouton => 'Cancel';

  @override
  String get analyseTermineeTitre => 'Analysis complete';

  @override
  String get analyseTermineeTexte =>
      'The spectrum was acquired and saved locally. It will sync automatically and appear in the history once a result is computed.';

  @override
  String get nouvelleAnalyseBouton => 'New analysis';

  @override
  String get calculResultatEnCoursTexte => 'Computing result…';

  @override
  String get resultatDateScanLabel => 'Scan date';

  @override
  String get blocPredictionsAciditeTitre => 'Acidity predictions';

  @override
  String get blocAuthenticiteTitre => 'Authenticity detection';

  @override
  String get huilePureLabel => 'Pure oil';

  @override
  String get melangeDetecteLabel => 'Blend detected';

  @override
  String scoreConfianceLabel(int pourcentage) {
    return 'Confidence $pourcentage%';
  }

  @override
  String get categorieEvooLabel => 'Extra Virgin (EVOO)';

  @override
  String get categorieVooLabel => 'Virgin (VOO)';

  @override
  String get categorieLampanteLabel => 'Lampante';

  @override
  String get blocSpectreAcquisTitre => 'Acquired spectrum';

  @override
  String get indicateurSyncEnAttenteTexte => 'Awaiting synchronization';

  @override
  String get indicateurSyncSynchroniseTexte => 'Synced with server';

  @override
  String get indicateurSyncErreurTexte => 'Synchronization failed';

  @override
  String get aucunModeleActifTexte =>
      'No active model is registered on the server for acidity: the result could not be computed. The sample and spectrum are still saved.';

  @override
  String get exporterResultatBouton => 'Export this result';

  @override
  String get voirDansHistoriqueBouton => 'View in history';

  @override
  String enAttenteSynchronisation(int nombre) {
    return '$nombre pending synchronization';
  }

  @override
  String get historiquesTitre => 'History';

  @override
  String get historiquesSousTitre => 'Analysis records';

  @override
  String get rechercherPlaceholder =>
      'Search by ID, producer, variety, region...';

  @override
  String get filtreTout => 'All';

  @override
  String get filtreQualite => 'Quality';

  @override
  String get filtreVariete => 'Variety';

  @override
  String get filtreRegion => 'Region';

  @override
  String get filtrePlus => 'More filters';

  @override
  String get apercuTitre => 'Overview';

  @override
  String get totalAnalysesLabel => 'Total analyses';

  @override
  String get ceMoisLabel => 'This month';

  @override
  String get chargerPlusAnalyses => 'Load more analyses';

  @override
  String get statistiquesRapidesTitre => 'Quick statistics';

  @override
  String get tendanceAciditeMoyenneLabel => 'Average acidity';

  @override
  String get meilleureQualiteLabel => 'Best quality';

  @override
  String get plusForteAciditeLabel => 'Highest acidity';

  @override
  String get analysesParJourLabel => 'Analyses / day';

  @override
  String get exporterBouton => 'Export';

  @override
  String get exportLanceMessage =>
      'Export started. You\'ll be notified once the report is ready.';

  @override
  String get exportTitre => 'Export';

  @override
  String get exportContenuLabel => 'What to export';

  @override
  String get exportContenuResultats => 'Results';

  @override
  String get exportContenuSpectres => 'Raw spectra';

  @override
  String get exportContenuLesDeux => 'Both';

  @override
  String get exportQuellesAnalysesLabel => 'Which analyses';

  @override
  String exportToutesFiltresLabel(int total) {
    return 'All analyses matching the active filters ($total)';
  }

  @override
  String get exportSelectionManuelleLabel => 'Manual selection';

  @override
  String get exportFormatLabel => 'Format';

  @override
  String get choisirAnalysesBouton => 'Choose analyses';

  @override
  String get exportTelechargeMessage => 'Export downloaded.';

  @override
  String get exportAnnuleMessage => 'Export cancelled.';

  @override
  String selectionCompteurTitre(int nombre) {
    return '$nombre selected';
  }

  @override
  String get toutSelectionnerBouton => 'Select all';

  @override
  String get validerExportBouton => 'Confirm export';

  @override
  String get filtresTitre => 'Filters';

  @override
  String get appliquerBouton => 'Apply';

  @override
  String get reinitialiserBouton => 'Reset';

  @override
  String get dateDebutLabel => 'Start date';

  @override
  String get dateFinLabel => 'End date';

  @override
  String get monProfilTitre => 'My Profile';

  @override
  String get monProfilSousTitre => 'Account information & preferences';

  @override
  String get champTelephone => 'Phone';

  @override
  String get champNom => 'Name';

  @override
  String get champFonction => 'Role/Title';

  @override
  String get champLaboratoire => 'Laboratory';

  @override
  String get champInstitution => 'Institution';

  @override
  String get membreDepuisLabel => 'Member since';

  @override
  String get changerPhotoProfil => 'Change profile photo';

  @override
  String get informationsPersonnellesTitre => 'Personal information';

  @override
  String get informationsPersonnellesSousTitre =>
      'Manage your profile information';

  @override
  String get securiteTitre => 'Security';

  @override
  String get securiteSousTitre => 'Password, authentication';

  @override
  String get sessionsActivesTitre => 'Active sessions';

  @override
  String get sessionsActivesSousTitre => 'Manage your connected devices';

  @override
  String sessionsActivesCompteur(int nombre) {
    return '$nombre active';
  }

  @override
  String get preferencesSectionTitre => 'Preferences';

  @override
  String get preferencesAnalyseTitre => 'Analysis preferences';

  @override
  String get preferencesAnalyseSousTitre =>
      'Units, thresholds, default settings';

  @override
  String get notificationsPreferenceTitre => 'Notifications';

  @override
  String get notificationsPreferenceSousTitre => 'Manage alerts and reports';

  @override
  String get themeTitre => 'Theme';

  @override
  String get themeClair => 'Light';

  @override
  String get themeSombreLabel => 'Dark';

  @override
  String get themeSysteme => 'System';

  @override
  String get donneesSyncSectionTitre => 'Data & Sync';

  @override
  String get synchronisationCloudTitre => 'Cloud sync';

  @override
  String derniereSyncLabel(String heure) {
    return 'Last sync: $heure';
  }

  @override
  String get syncDesactiveeLabel => 'Sync disabled';

  @override
  String get syncJamaisLabel => 'Never synced';

  @override
  String get gestionDonneesTitre => 'Data management';

  @override
  String get gestionDonneesSousTitre => 'Export, delete or archive data';

  @override
  String get espaceStockageTitre => 'Storage usage';

  @override
  String get aProposSectionTitre => 'About';

  @override
  String get aProposOliveIQTitre => 'About OliveIQ';

  @override
  String versionBuildLabel(String version, String build) {
    return 'Version $version • Build $build';
  }

  @override
  String get centreAideTitre => 'Help center';

  @override
  String get centreAideSousTitre => 'Documentation and support';

  @override
  String get centreAideContenu =>
      'For any question about using OliveIQ (running an analysis, reading results, connecting the analyzer), contact your lab\'s support or write to support@olive-iq.local.\n\nFull documentation will be added here soon.';

  @override
  String get mentionsLegalesTitre => 'Legal & Privacy';

  @override
  String get mentionsLegalesContenu =>
      'OliveIQ processes analysis data (samples, spectra, results) exclusively for your organization\'s olive oil quality tracking.\n\nPersonal account data (name, email, phone, profile photo) is only used to identify you and operate the app, and is never shared with third parties.\n\nThis section will be completed with your organization\'s final legal text.';

  @override
  String get seDeconnecterConfirmationTitre => 'Log out?';

  @override
  String get seDeconnecterConfirmationTexte =>
      'You\'ll need to log back in to access your account.';

  @override
  String get confirmerBouton => 'Confirm';

  @override
  String get enregistrerBouton => 'Save';

  @override
  String get profilMisAJourMessage => 'Profile updated.';

  @override
  String get photoProfilMiseAJourMessage => 'Profile photo updated.';

  @override
  String get ancienMotDePasseLabel => 'Current password';

  @override
  String get changerMotDePasseBouton => 'Change password';

  @override
  String get motDePasseModifieMessage => 'Password changed successfully.';

  @override
  String sessionCreeeLabel(String date) {
    return 'Connected on $date';
  }

  @override
  String sessionExpireLabel(String date) {
    return 'Expires on $date';
  }

  @override
  String get sessionCouranteLabel => 'This device';

  @override
  String get revoquerSessionBouton => 'Revoke';

  @override
  String get revoquerToutesSaufCouranteBouton => 'Revoke all other sessions';

  @override
  String get aucuneSessionMessage => 'No active sessions.';

  @override
  String get seuilAciditeConformiteLabel => 'Compliance threshold — Acidity';

  @override
  String get seuilPeroxydeConformiteLabel =>
      'Compliance threshold — Peroxide index';

  @override
  String get seuilEvooLabel => 'Extra Virgin threshold (EVOO)';

  @override
  String get seuilVooLabel => 'Virgin threshold (VOO)';

  @override
  String get lectureSeuleAdministrateurMessage =>
      'Only an administrator can change this.';

  @override
  String get seuilsMisAJourMessage => 'Thresholds updated.';

  @override
  String get exporterMesDonneesBouton => 'Export my data';

  @override
  String get viderCacheBouton => 'Clear local cache';

  @override
  String get viderCacheConfirmationTitre => 'Clear cache?';

  @override
  String get viderCacheConfirmationTexte =>
      'Temporary files will be deleted. Analyses waiting to sync are never affected.';

  @override
  String get cacheVideMessage => 'Cache cleared.';
}
