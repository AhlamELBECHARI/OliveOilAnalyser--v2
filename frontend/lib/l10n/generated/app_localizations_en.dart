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
  String get modeleActif => 'Active';

  @override
  String get modeleDeprecie => 'Deprecated';

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
  String get etapeEchantillonLabel => 'Sample';

  @override
  String get etapeAnalyseLabel => 'Analysis';

  @override
  String get etapeResultatsLabel => 'Results';

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
  String get filtresTitre => 'Filters';

  @override
  String get appliquerBouton => 'Apply';

  @override
  String get reinitialiserBouton => 'Reset';

  @override
  String get dateDebutLabel => 'Start date';

  @override
  String get dateFinLabel => 'End date';
}
