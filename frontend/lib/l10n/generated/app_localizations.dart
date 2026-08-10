import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Nom de l'application
  ///
  /// In fr, this message translates to:
  /// **'OliveIQ'**
  String get appName;

  /// No description provided for @sousTitreApp.
  ///
  /// In fr, this message translates to:
  /// **'Analyse d\'Huile d\'Olive'**
  String get sousTitreApp;

  /// No description provided for @bienvenue.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue !'**
  String get bienvenue;

  /// No description provided for @accedezVotreEspace.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour accéder à votre espace'**
  String get accedezVotreEspace;

  /// No description provided for @champEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get champEmail;

  /// No description provided for @champMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get champMotDePasse;

  /// No description provided for @erreurEmailRequis.
  ///
  /// In fr, this message translates to:
  /// **'Email requis'**
  String get erreurEmailRequis;

  /// No description provided for @erreurEmailFormatInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Format email invalide'**
  String get erreurEmailFormatInvalide;

  /// No description provided for @erreurMotDePasseRequis.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe requis'**
  String get erreurMotDePasseRequis;

  /// No description provided for @motDePasseOublie.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get motDePasseOublie;

  /// No description provided for @seConnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get seConnecter;

  /// No description provided for @ou.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get ou;

  /// No description provided for @modeDemo.
  ///
  /// In fr, this message translates to:
  /// **'Mode démo'**
  String get modeDemo;

  /// No description provided for @versionApp.
  ///
  /// In fr, this message translates to:
  /// **'Version 1.0.0'**
  String get versionApp;

  /// No description provided for @sousTitreEmailReset.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez l\'email associé à votre compte : nous vous enverrons un code de vérification à 6 chiffres.'**
  String get sousTitreEmailReset;

  /// No description provided for @envoyerCode.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le code'**
  String get envoyerCode;

  /// No description provided for @entrezLeCode.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code'**
  String get entrezLeCode;

  /// No description provided for @codeEnvoyeA.
  ///
  /// In fr, this message translates to:
  /// **'Un code à 6 chiffres a été envoyé à {email}'**
  String codeEnvoyeA(String email);

  /// No description provided for @erreurCodeRequis.
  ///
  /// In fr, this message translates to:
  /// **'Code requis'**
  String get erreurCodeRequis;

  /// No description provided for @erreurCodeFormat.
  ///
  /// In fr, this message translates to:
  /// **'Le code doit contenir 6 chiffres'**
  String get erreurCodeFormat;

  /// No description provided for @renvoyerLeCode.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get renvoyerLeCode;

  /// No description provided for @renvoyerLeCodeCompteur.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code ({secondes}s)'**
  String renvoyerLeCodeCompteur(int secondes);

  /// No description provided for @nouveauCodeEnvoye.
  ///
  /// In fr, this message translates to:
  /// **'Un nouveau code a été envoyé.'**
  String get nouveauCodeEnvoye;

  /// No description provided for @verifier.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get verifier;

  /// No description provided for @nouveauMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get nouveauMotDePasse;

  /// No description provided for @choisissezNouveauMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un nouveau mot de passe pour votre compte.'**
  String get choisissezNouveauMotDePasse;

  /// No description provided for @champConfirmerMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get champConfirmerMotDePasse;

  /// No description provided for @erreurMinimum8Caracteres.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 8 caractères'**
  String get erreurMinimum8Caracteres;

  /// No description provided for @erreurConfirmationRequise.
  ///
  /// In fr, this message translates to:
  /// **'Confirmation requise'**
  String get erreurConfirmationRequise;

  /// No description provided for @erreurMotsDePasseNeCorrespondentPas.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get erreurMotsDePasseNeCorrespondentPas;

  /// No description provided for @reinitialiser.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get reinitialiser;

  /// No description provided for @motDePasseReinitialiseSucces.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe réinitialisé. Vous pouvez vous reconnecter.'**
  String get motDePasseReinitialiseSucces;

  /// No description provided for @erreurIdentifiantsInvalides.
  ///
  /// In fr, this message translates to:
  /// **'Email ou mot de passe incorrect.'**
  String get erreurIdentifiantsInvalides;

  /// No description provided for @erreurCompteVerrouille.
  ///
  /// In fr, this message translates to:
  /// **'Compte temporairement bloqué suite à plusieurs tentatives échouées. Réessayez plus tard.'**
  String get erreurCompteVerrouille;

  /// No description provided for @erreurCompteDesactive.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte est désactivé.'**
  String get erreurCompteDesactive;

  /// No description provided for @erreurReseau.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur. Vérifiez votre connexion.'**
  String get erreurReseau;

  /// No description provided for @erreurServeur.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez plus tard.'**
  String get erreurServeur;

  /// No description provided for @erreurCodeInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Code invalide ou expiré.'**
  String get erreurCodeInvalide;

  /// No description provided for @erreurTropDeDemandes.
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes de code. Réessayez plus tard.'**
  String get erreurTropDeDemandes;

  /// No description provided for @erreurValidationGenerique.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de validation. Vérifiez les informations saisies.'**
  String get erreurValidationGenerique;

  /// No description provided for @bonjour.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour,'**
  String get bonjour;

  /// No description provided for @etatLaboratoire.
  ///
  /// In fr, this message translates to:
  /// **'État du laboratoire'**
  String get etatLaboratoire;

  /// No description provided for @operationnel.
  ///
  /// In fr, this message translates to:
  /// **'Opérationnel'**
  String get operationnel;

  /// No description provided for @horsLigne.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get horsLigne;

  /// No description provided for @appareilConnecteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Appareil connecté'**
  String get appareilConnecteLabel;

  /// No description provided for @aucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get aucun;

  /// No description provided for @connecte.
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get connecte;

  /// No description provided for @bluetooth.
  ///
  /// In fr, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// No description provided for @deconnecte.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecté'**
  String get deconnecte;

  /// No description provided for @batterie.
  ///
  /// In fr, this message translates to:
  /// **'Batterie'**
  String get batterie;

  /// No description provided for @derniereSynchro.
  ///
  /// In fr, this message translates to:
  /// **'Dernière synchro.'**
  String get derniereSynchro;

  /// No description provided for @aujourdHuiHeure.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui, {heure}'**
  String aujourdHuiHeure(String heure);

  /// No description provided for @dateEtHeure.
  ///
  /// In fr, this message translates to:
  /// **'{date}, {heure}'**
  String dateEtHeure(String date, String heure);

  /// No description provided for @analysesCeMois.
  ///
  /// In fr, this message translates to:
  /// **'Analyses ce mois'**
  String get analysesCeMois;

  /// No description provided for @echantillonsTotaux.
  ///
  /// In fr, this message translates to:
  /// **'Échantillons totaux'**
  String get echantillonsTotaux;

  /// No description provided for @analysesAujourdHui.
  ///
  /// In fr, this message translates to:
  /// **'Analyses aujourd\'hui'**
  String get analysesAujourdHui;

  /// No description provided for @tempsMoyenParAnalyse.
  ///
  /// In fr, this message translates to:
  /// **'Temps moyen / analyse'**
  String get tempsMoyenParAnalyse;

  /// No description provided for @variationVsMoisDernier.
  ///
  /// In fr, this message translates to:
  /// **'{pourcentage}% vs mois dernier'**
  String variationVsMoisDernier(String pourcentage);

  /// No description provided for @variationVsHier.
  ///
  /// In fr, this message translates to:
  /// **'{pourcentage}% vs hier'**
  String variationVsHier(String pourcentage);

  /// No description provided for @ajoutsCeMois.
  ///
  /// In fr, this message translates to:
  /// **'+ {nombre} ce mois'**
  String ajoutsCeMois(String nombre);

  /// No description provided for @dureeMinSec.
  ///
  /// In fr, this message translates to:
  /// **'{min} min {sec} s'**
  String dureeMinSec(int min, int sec);

  /// No description provided for @analysesRecentesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Analyses récentes (7 derniers jours)'**
  String get analysesRecentesTitre;

  /// No description provided for @septJours.
  ///
  /// In fr, this message translates to:
  /// **'7 jours'**
  String get septJours;

  /// No description provided for @qualiteHuilesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Qualité des huiles (ce mois)'**
  String get qualiteHuilesTitre;

  /// No description provided for @total.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @voirRepartitionDetaillee.
  ///
  /// In fr, this message translates to:
  /// **'Voir la répartition détaillée'**
  String get voirRepartitionDetaillee;

  /// No description provided for @categorieEvoo.
  ///
  /// In fr, this message translates to:
  /// **'Extra Vierge (EVOO)'**
  String get categorieEvoo;

  /// No description provided for @categorieVoo.
  ///
  /// In fr, this message translates to:
  /// **'Vierge (VOO)'**
  String get categorieVoo;

  /// No description provided for @categorieLampante.
  ///
  /// In fr, this message translates to:
  /// **'Lampante'**
  String get categorieLampante;

  /// No description provided for @categorieEvooCourt.
  ///
  /// In fr, this message translates to:
  /// **'EVOO'**
  String get categorieEvooCourt;

  /// No description provided for @categorieVooCourt.
  ///
  /// In fr, this message translates to:
  /// **'VOO'**
  String get categorieVooCourt;

  /// No description provided for @categorieLampanteCourt.
  ///
  /// In fr, this message translates to:
  /// **'Lampante'**
  String get categorieLampanteCourt;

  /// No description provided for @activiteRecente.
  ///
  /// In fr, this message translates to:
  /// **'Activité récente'**
  String get activiteRecente;

  /// No description provided for @aucuneAnalyseRecente.
  ///
  /// In fr, this message translates to:
  /// **'Aucune analyse récente.'**
  String get aucuneAnalyseRecente;

  /// No description provided for @voirToutHistorique.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout l\'historique'**
  String get voirToutHistorique;

  /// No description provided for @navAccueil.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navAccueil;

  /// No description provided for @navAnalyse.
  ///
  /// In fr, this message translates to:
  /// **'Analyse'**
  String get navAnalyse;

  /// No description provided for @navHistorique.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get navHistorique;

  /// No description provided for @navModeles.
  ///
  /// In fr, this message translates to:
  /// **'Modèles'**
  String get navModeles;

  /// No description provided for @navParametres.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navParametres;

  /// No description provided for @modeDemoBanniere.
  ///
  /// In fr, this message translates to:
  /// **'Mode démo — connecté avec le compte de démonstration.'**
  String get modeDemoBanniere;

  /// No description provided for @reessayer.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get reessayer;

  /// No description provided for @parametresTitre.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get parametresTitre;

  /// No description provided for @langueSectionTitre.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get langueSectionTitre;

  /// No description provided for @langueFrancais.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get langueFrancais;

  /// No description provided for @langueAnglais.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get langueAnglais;

  /// No description provided for @compteSectionTitre.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get compteSectionTitre;

  /// No description provided for @seDeconnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get seDeconnecter;

  /// No description provided for @quitterModeDemo.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le mode démo'**
  String get quitterModeDemo;

  /// No description provided for @alertesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get alertesTitre;

  /// No description provided for @aucuneAlerte.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte.'**
  String get aucuneAlerte;

  /// No description provided for @alerteResolue.
  ///
  /// In fr, this message translates to:
  /// **'Résolue'**
  String get alerteResolue;

  /// No description provided for @alerteNonResolue.
  ///
  /// In fr, this message translates to:
  /// **'Non résolue'**
  String get alerteNonResolue;

  /// No description provided for @niveauInfo.
  ///
  /// In fr, this message translates to:
  /// **'Info'**
  String get niveauInfo;

  /// No description provided for @niveauAvertissement.
  ///
  /// In fr, this message translates to:
  /// **'Avertissement'**
  String get niveauAvertissement;

  /// No description provided for @niveauCritique.
  ///
  /// In fr, this message translates to:
  /// **'Critique'**
  String get niveauCritique;

  /// No description provided for @aucunResultat.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour l\'instant.'**
  String get aucunResultat;

  /// No description provided for @conforme.
  ///
  /// In fr, this message translates to:
  /// **'Conforme'**
  String get conforme;

  /// No description provided for @nonConforme.
  ///
  /// In fr, this message translates to:
  /// **'Non conforme'**
  String get nonConforme;

  /// No description provided for @aucunModele.
  ///
  /// In fr, this message translates to:
  /// **'Aucun modèle disponible.'**
  String get aucunModele;

  /// No description provided for @modeleVersionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String modeleVersionLabel(String version);

  /// No description provided for @modeleAlgorithmeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Algorithme'**
  String get modeleAlgorithmeLabel;

  /// No description provided for @modeleR2Label.
  ///
  /// In fr, this message translates to:
  /// **'R²'**
  String get modeleR2Label;

  /// No description provided for @modeleRmsecvLabel.
  ///
  /// In fr, this message translates to:
  /// **'RMSECV'**
  String get modeleRmsecvLabel;

  /// No description provided for @modeleActif.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get modeleActif;

  /// No description provided for @modeleDeprecie.
  ///
  /// In fr, this message translates to:
  /// **'Déprécié'**
  String get modeleDeprecie;

  /// No description provided for @ajouterModeleBouton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un modèle'**
  String get ajouterModeleBouton;

  /// No description provided for @ajouterModeleTitre.
  ///
  /// In fr, this message translates to:
  /// **'Importer un modèle'**
  String get ajouterModeleTitre;

  /// No description provided for @champNomModele.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get champNomModele;

  /// No description provided for @champVersionModele.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get champVersionModele;

  /// No description provided for @champObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire.'**
  String get champObligatoire;

  /// No description provided for @valeurNumeriqueInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Valeur numérique invalide.'**
  String get valeurNumeriqueInvalide;

  /// No description provided for @valeurDoitEtrePositive.
  ///
  /// In fr, this message translates to:
  /// **'La valeur doit être positive ou nulle.'**
  String get valeurDoitEtrePositive;

  /// No description provided for @champHyperparametres.
  ///
  /// In fr, this message translates to:
  /// **'Hyperparamètres (JSON)'**
  String get champHyperparametres;

  /// No description provided for @champHyperparametresAide.
  ///
  /// In fr, this message translates to:
  /// **'Objet JSON, ex. : n_components 5'**
  String get champHyperparametresAide;

  /// No description provided for @jsonInvalide.
  ///
  /// In fr, this message translates to:
  /// **'JSON invalide.'**
  String get jsonInvalide;

  /// No description provided for @champDateEntrainement.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'entraînement'**
  String get champDateEntrainement;

  /// No description provided for @choisirFichierModeleBouton.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner le fichier du modèle'**
  String get choisirFichierModeleBouton;

  /// No description provided for @formatsFichierModeleAutorises.
  ///
  /// In fr, this message translates to:
  /// **'Formats acceptés : {formats}'**
  String formatsFichierModeleAutorises(String formats);

  /// No description provided for @modeleAjouteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Modèle ajouté.'**
  String get modeleAjouteMessage;

  /// No description provided for @activerModeleAction.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get activerModeleAction;

  /// No description provided for @desactiverModeleAction.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get desactiverModeleAction;

  /// No description provided for @deprecierModeleAction.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme déprécié'**
  String get deprecierModeleAction;

  /// No description provided for @retirerDepreciationModeleAction.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la dépréciation'**
  String get retirerDepreciationModeleAction;

  /// No description provided for @detailResultatTitre.
  ///
  /// In fr, this message translates to:
  /// **'Détail de l\'analyse'**
  String get detailResultatTitre;

  /// No description provided for @acidite.
  ///
  /// In fr, this message translates to:
  /// **'Acidité'**
  String get acidite;

  /// No description provided for @indicePeroxyde.
  ///
  /// In fr, this message translates to:
  /// **'Indice de peroxyde'**
  String get indicePeroxyde;

  /// No description provided for @dureeAnalyseLabel.
  ///
  /// In fr, this message translates to:
  /// **'Durée de l\'analyse'**
  String get dureeAnalyseLabel;

  /// No description provided for @dateAnalyseLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de l\'analyse'**
  String get dateAnalyseLabel;

  /// No description provided for @dateCalculLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date du résultat'**
  String get dateCalculLabel;

  /// No description provided for @commentaireLabel.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get commentaireLabel;

  /// No description provided for @analyseEnAttenteTitre.
  ///
  /// In fr, this message translates to:
  /// **'En attente du module Bluetooth'**
  String get analyseEnAttenteTitre;

  /// No description provided for @analyseEnAttenteTexte.
  ///
  /// In fr, this message translates to:
  /// **'La connexion à l\'analyseur spectroscopique n\'est pas encore disponible. Ce module sera activé avec l\'intégration Bluetooth.'**
  String get analyseEnAttenteTexte;

  /// No description provided for @erreurStockageLocal.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'enregistrer localement sur cet appareil. Réessayez.'**
  String get erreurStockageLocal;

  /// No description provided for @nouvelleAnalyseTitre.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle Analyse'**
  String get nouvelleAnalyseTitre;

  /// No description provided for @nouvelleAnalyseSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Acquisition et analyse d\'échantillon'**
  String get nouvelleAnalyseSousTitre;

  /// No description provided for @etatRecherche.
  ///
  /// In fr, this message translates to:
  /// **'Recherche...'**
  String get etatRecherche;

  /// No description provided for @etatErreurConnexion.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get etatErreurConnexion;

  /// No description provided for @etapeConnexionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get etapeConnexionLabel;

  /// No description provided for @etapeEchantillonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Échantillon'**
  String get etapeEchantillonLabel;

  /// No description provided for @etapeAnalyseLabel.
  ///
  /// In fr, this message translates to:
  /// **'Analyse'**
  String get etapeAnalyseLabel;

  /// No description provided for @etapeResultatsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Résultats'**
  String get etapeResultatsLabel;

  /// No description provided for @etapeConnexionRechercheTitre.
  ///
  /// In fr, this message translates to:
  /// **'Recherche de l\'appareil...'**
  String get etapeConnexionRechercheTitre;

  /// No description provided for @etapeConnexionRechercheTexte.
  ///
  /// In fr, this message translates to:
  /// **'Connexion en cours à l\'analyseur NIR appairé.'**
  String get etapeConnexionRechercheTexte;

  /// No description provided for @etapeConnexionEchecTitre.
  ///
  /// In fr, this message translates to:
  /// **'Échec de connexion'**
  String get etapeConnexionEchecTitre;

  /// No description provided for @etapeConnexionEchecTexteGenerique.
  ///
  /// In fr, this message translates to:
  /// **'Bluetooth désactivé, appareil éteint ou hors de portée, ou permissions refusées.'**
  String get etapeConnexionEchecTexteGenerique;

  /// No description provided for @continuerBouton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continuerBouton;

  /// No description provided for @configurerAppareilLien.
  ///
  /// In fr, this message translates to:
  /// **'Configurer l\'appareil'**
  String get configurerAppareilLien;

  /// No description provided for @continuerSansAppareilLien.
  ///
  /// In fr, this message translates to:
  /// **'Continuer sans appareil'**
  String get continuerSansAppareilLien;

  /// No description provided for @configurationAppareilTitre.
  ///
  /// In fr, this message translates to:
  /// **'Configuration de l\'appareil'**
  String get configurationAppareilTitre;

  /// No description provided for @configurationAppareilTexteAide.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez l\'appareil à utiliser pour la connexion automatique parmi ceux déjà appairés dans les réglages Bluetooth du téléphone.'**
  String get configurationAppareilTexteAide;

  /// No description provided for @aucunAppareilAppaireTexte.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil appairé. Appairez d\'abord le spectromètre dans les réglages Bluetooth du téléphone.'**
  String get aucunAppareilAppaireTexte;

  /// No description provided for @oublierAppareilParDefautBouton.
  ///
  /// In fr, this message translates to:
  /// **'Oublier l\'appareil par défaut'**
  String get oublierAppareilParDefautBouton;

  /// No description provided for @testerConnexionBouton.
  ///
  /// In fr, this message translates to:
  /// **'Tester'**
  String get testerConnexionBouton;

  /// No description provided for @testConnexionReussi.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie'**
  String get testConnexionReussi;

  /// No description provided for @testConnexionEchoue.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la connexion'**
  String get testConnexionEchoue;

  /// No description provided for @carteInformationsEchantillonTitre.
  ///
  /// In fr, this message translates to:
  /// **'Informations Échantillon'**
  String get carteInformationsEchantillonTitre;

  /// No description provided for @champIdEchantillon.
  ///
  /// In fr, this message translates to:
  /// **'ID Échantillon'**
  String get champIdEchantillon;

  /// No description provided for @champProducteur.
  ///
  /// In fr, this message translates to:
  /// **'Producteur'**
  String get champProducteur;

  /// No description provided for @champVariete.
  ///
  /// In fr, this message translates to:
  /// **'Variété'**
  String get champVariete;

  /// No description provided for @champRegion.
  ///
  /// In fr, this message translates to:
  /// **'Région'**
  String get champRegion;

  /// No description provided for @champDateRecolte.
  ///
  /// In fr, this message translates to:
  /// **'Date de récolte'**
  String get champDateRecolte;

  /// No description provided for @champGps.
  ///
  /// In fr, this message translates to:
  /// **'GPS'**
  String get champGps;

  /// No description provided for @positionActuelleBouton.
  ///
  /// In fr, this message translates to:
  /// **'Position actuelle'**
  String get positionActuelleBouton;

  /// No description provided for @validerInformationsBouton.
  ///
  /// In fr, this message translates to:
  /// **'Valider les informations'**
  String get validerInformationsBouton;

  /// No description provided for @modifierBouton.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get modifierBouton;

  /// No description provided for @metadonneesCompletesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Métadonnées complètes'**
  String get metadonneesCompletesTitre;

  /// No description provided for @metadonneesCompletesTexte.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les informations requises sont renseignées.'**
  String get metadonneesCompletesTexte;

  /// No description provided for @erreurLocalisationService.
  ///
  /// In fr, this message translates to:
  /// **'Le GPS est désactivé. Activez la localisation dans les réglages de l\'appareil.'**
  String get erreurLocalisationService;

  /// No description provided for @erreurLocalisationPermission.
  ///
  /// In fr, this message translates to:
  /// **'Permission de localisation refusée. Autorisez-la dans les réglages de l\'application.'**
  String get erreurLocalisationPermission;

  /// No description provided for @erreurLocalisationGenerique.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'obtenir la position actuelle.'**
  String get erreurLocalisationGenerique;

  /// No description provided for @gpsNonRenseigne.
  ///
  /// In fr, this message translates to:
  /// **'Non renseignée'**
  String get gpsNonRenseigne;

  /// No description provided for @selectionnerDate.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner'**
  String get selectionnerDate;

  /// No description provided for @carteConnexionInstrumentTitre.
  ///
  /// In fr, this message translates to:
  /// **'Connexion & Instrument'**
  String get carteConnexionInstrumentTitre;

  /// No description provided for @voirDetailsInstrument.
  ///
  /// In fr, this message translates to:
  /// **'Voir les détails de l\'instrument'**
  String get voirDetailsInstrument;

  /// No description provided for @aucunInstrumentConnecte.
  ///
  /// In fr, this message translates to:
  /// **'Aucun instrument connecté'**
  String get aucunInstrumentConnecte;

  /// No description provided for @rechercheInstrumentTexte.
  ///
  /// In fr, this message translates to:
  /// **'Recherche de l\'analyseur en cours...'**
  String get rechercheInstrumentTexte;

  /// No description provided for @reessayerConnexionBouton.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get reessayerConnexionBouton;

  /// No description provided for @numeroSerieLabel.
  ///
  /// In fr, this message translates to:
  /// **'SN'**
  String get numeroSerieLabel;

  /// No description provided for @firmwareLabel.
  ///
  /// In fr, this message translates to:
  /// **'Firmware'**
  String get firmwareLabel;

  /// No description provided for @carteParametresAcquisitionTitre.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres d\'Acquisition'**
  String get carteParametresAcquisitionTitre;

  /// No description provided for @parametresAcquisitionIndisponible.
  ///
  /// In fr, this message translates to:
  /// **'Disponible une fois le protocole du fabricant documenté.'**
  String get parametresAcquisitionIndisponible;

  /// No description provided for @carteApercuTempsReelTitre.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu en Temps Réel'**
  String get carteApercuTempsReelTitre;

  /// No description provided for @signalQualiteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Signal de qualité'**
  String get signalQualiteLabel;

  /// No description provided for @absorbanceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Absorbance'**
  String get absorbanceLabel;

  /// No description provided for @longueurOndeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Longueur d\'onde (nm)'**
  String get longueurOndeLabel;

  /// No description provided for @snrLabel.
  ///
  /// In fr, this message translates to:
  /// **'SNR'**
  String get snrLabel;

  /// No description provided for @intensiteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Intensité'**
  String get intensiteLabel;

  /// No description provided for @bruitLabel.
  ///
  /// In fr, this message translates to:
  /// **'Bruit'**
  String get bruitLabel;

  /// No description provided for @qualiteGlobaleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Qualité globale'**
  String get qualiteGlobaleLabel;

  /// No description provided for @demarrerAnalyseBouton.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer l\'analyse'**
  String get demarrerAnalyseBouton;

  /// No description provided for @annulerBouton.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get annulerBouton;

  /// No description provided for @analyseTermineeTitre.
  ///
  /// In fr, this message translates to:
  /// **'Analyse terminée'**
  String get analyseTermineeTitre;

  /// No description provided for @analyseTermineeTexte.
  ///
  /// In fr, this message translates to:
  /// **'Le spectre a été acquis et enregistré localement. Il sera synchronisé automatiquement et pris en compte dans l\'historique dès qu\'un résultat sera calculé.'**
  String get analyseTermineeTexte;

  /// No description provided for @nouvelleAnalyseBouton.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle analyse'**
  String get nouvelleAnalyseBouton;

  /// No description provided for @enAttenteSynchronisation.
  ///
  /// In fr, this message translates to:
  /// **'{nombre} en attente de synchronisation'**
  String enAttenteSynchronisation(int nombre);

  /// No description provided for @historiquesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Historiques'**
  String get historiquesTitre;

  /// No description provided for @historiquesSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Consultation des analyses'**
  String get historiquesSousTitre;

  /// No description provided for @rechercherPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher par ID, producteur, variété, région...'**
  String get rechercherPlaceholder;

  /// No description provided for @filtreTout.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get filtreTout;

  /// No description provided for @filtreQualite.
  ///
  /// In fr, this message translates to:
  /// **'Qualité'**
  String get filtreQualite;

  /// No description provided for @filtreVariete.
  ///
  /// In fr, this message translates to:
  /// **'Variété'**
  String get filtreVariete;

  /// No description provided for @filtreRegion.
  ///
  /// In fr, this message translates to:
  /// **'Région'**
  String get filtreRegion;

  /// No description provided for @filtrePlus.
  ///
  /// In fr, this message translates to:
  /// **'Plus de filtres'**
  String get filtrePlus;

  /// No description provided for @apercuTitre.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get apercuTitre;

  /// No description provided for @totalAnalysesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Total analyses'**
  String get totalAnalysesLabel;

  /// No description provided for @ceMoisLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get ceMoisLabel;

  /// No description provided for @chargerPlusAnalyses.
  ///
  /// In fr, this message translates to:
  /// **'Charger plus d\'analyses'**
  String get chargerPlusAnalyses;

  /// No description provided for @statistiquesRapidesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques rapides'**
  String get statistiquesRapidesTitre;

  /// No description provided for @tendanceAciditeMoyenneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Acidité moyenne'**
  String get tendanceAciditeMoyenneLabel;

  /// No description provided for @meilleureQualiteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Meilleure qualité'**
  String get meilleureQualiteLabel;

  /// No description provided for @plusForteAciditeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Plus forte acidité'**
  String get plusForteAciditeLabel;

  /// No description provided for @analysesParJourLabel.
  ///
  /// In fr, this message translates to:
  /// **'Analyses / jour'**
  String get analysesParJourLabel;

  /// No description provided for @exporterBouton.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get exporterBouton;

  /// No description provided for @exportLanceMessage.
  ///
  /// In fr, this message translates to:
  /// **'Export lancé. Vous serez notifié une fois le rapport prêt.'**
  String get exportLanceMessage;

  /// No description provided for @exportTitre.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get exportTitre;

  /// No description provided for @exportContenuLabel.
  ///
  /// In fr, this message translates to:
  /// **'Quoi exporter'**
  String get exportContenuLabel;

  /// No description provided for @exportContenuResultats.
  ///
  /// In fr, this message translates to:
  /// **'Résultats'**
  String get exportContenuResultats;

  /// No description provided for @exportContenuSpectres.
  ///
  /// In fr, this message translates to:
  /// **'Spectres bruts'**
  String get exportContenuSpectres;

  /// No description provided for @exportContenuLesDeux.
  ///
  /// In fr, this message translates to:
  /// **'Les deux'**
  String get exportContenuLesDeux;

  /// No description provided for @exportQuellesAnalysesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Quelles analyses'**
  String get exportQuellesAnalysesLabel;

  /// No description provided for @exportToutesFiltresLabel.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les analyses correspondant aux filtres actifs ({total})'**
  String exportToutesFiltresLabel(int total);

  /// No description provided for @exportSelectionManuelleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sélection manuelle'**
  String get exportSelectionManuelleLabel;

  /// No description provided for @exportFormatLabel.
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get exportFormatLabel;

  /// No description provided for @choisirAnalysesBouton.
  ///
  /// In fr, this message translates to:
  /// **'Choisir les analyses'**
  String get choisirAnalysesBouton;

  /// No description provided for @exportTelechargeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Export téléchargé.'**
  String get exportTelechargeMessage;

  /// No description provided for @exportAnnuleMessage.
  ///
  /// In fr, this message translates to:
  /// **'Export annulé.'**
  String get exportAnnuleMessage;

  /// No description provided for @selectionCompteurTitre.
  ///
  /// In fr, this message translates to:
  /// **'{nombre} sélectionné(s)'**
  String selectionCompteurTitre(int nombre);

  /// No description provided for @toutSelectionnerBouton.
  ///
  /// In fr, this message translates to:
  /// **'Tout sélectionner'**
  String get toutSelectionnerBouton;

  /// No description provided for @validerExportBouton.
  ///
  /// In fr, this message translates to:
  /// **'Valider l\'export'**
  String get validerExportBouton;

  /// No description provided for @filtresTitre.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filtresTitre;

  /// No description provided for @appliquerBouton.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get appliquerBouton;

  /// No description provided for @reinitialiserBouton.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get reinitialiserBouton;

  /// No description provided for @dateDebutLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de début'**
  String get dateDebutLabel;

  /// No description provided for @dateFinLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de fin'**
  String get dateFinLabel;

  /// No description provided for @monProfilTitre.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get monProfilTitre;

  /// No description provided for @monProfilSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Informations du compte & préférences'**
  String get monProfilSousTitre;

  /// No description provided for @roleAdministrateurLabel.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get roleAdministrateurLabel;

  /// No description provided for @roleUtilisateurLabel.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get roleUtilisateurLabel;

  /// No description provided for @champTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get champTelephone;

  /// No description provided for @champNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get champNom;

  /// No description provided for @champFonction.
  ///
  /// In fr, this message translates to:
  /// **'Fonction'**
  String get champFonction;

  /// No description provided for @champLaboratoire.
  ///
  /// In fr, this message translates to:
  /// **'Laboratoire'**
  String get champLaboratoire;

  /// No description provided for @champInstitution.
  ///
  /// In fr, this message translates to:
  /// **'Institution'**
  String get champInstitution;

  /// No description provided for @membreDepuisLabel.
  ///
  /// In fr, this message translates to:
  /// **'Membre depuis'**
  String get membreDepuisLabel;

  /// No description provided for @changerPhotoProfil.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo de profil'**
  String get changerPhotoProfil;

  /// No description provided for @informationsPersonnellesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get informationsPersonnellesTitre;

  /// No description provided for @informationsPersonnellesSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Gérer vos informations de profil'**
  String get informationsPersonnellesSousTitre;

  /// No description provided for @securiteTitre.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get securiteTitre;

  /// No description provided for @securiteSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe, authentification'**
  String get securiteSousTitre;

  /// No description provided for @sessionsActivesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Sessions actives'**
  String get sessionsActivesTitre;

  /// No description provided for @sessionsActivesSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Gérer vos appareils connectés'**
  String get sessionsActivesSousTitre;

  /// No description provided for @sessionsActivesCompteur.
  ///
  /// In fr, this message translates to:
  /// **'{nombre} actives'**
  String sessionsActivesCompteur(int nombre);

  /// No description provided for @preferencesSectionTitre.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get preferencesSectionTitre;

  /// No description provided for @preferencesAnalyseTitre.
  ///
  /// In fr, this message translates to:
  /// **'Préférences d\'analyse'**
  String get preferencesAnalyseTitre;

  /// No description provided for @preferencesAnalyseSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Unités, seuils, paramètres par défaut'**
  String get preferencesAnalyseSousTitre;

  /// No description provided for @notificationsPreferenceTitre.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsPreferenceTitre;

  /// No description provided for @notificationsPreferenceSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les alertes et rapports'**
  String get notificationsPreferenceSousTitre;

  /// No description provided for @themeTitre.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get themeTitre;

  /// No description provided for @themeClair.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeClair;

  /// No description provided for @themeSombreLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeSombreLabel;

  /// No description provided for @themeSysteme.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSysteme;

  /// No description provided for @donneesSyncSectionTitre.
  ///
  /// In fr, this message translates to:
  /// **'Données & Synchronisation'**
  String get donneesSyncSectionTitre;

  /// No description provided for @synchronisationCloudTitre.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation cloud'**
  String get synchronisationCloudTitre;

  /// No description provided for @derniereSyncLabel.
  ///
  /// In fr, this message translates to:
  /// **'Dernière sync : {heure}'**
  String derniereSyncLabel(String heure);

  /// No description provided for @syncDesactiveeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation désactivée'**
  String get syncDesactiveeLabel;

  /// No description provided for @syncJamaisLabel.
  ///
  /// In fr, this message translates to:
  /// **'Jamais synchronisé'**
  String get syncJamaisLabel;

  /// No description provided for @gestionDonneesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des données'**
  String get gestionDonneesTitre;

  /// No description provided for @gestionDonneesSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Exporter, supprimer ou archiver des données'**
  String get gestionDonneesSousTitre;

  /// No description provided for @espaceStockageTitre.
  ///
  /// In fr, this message translates to:
  /// **'Espace de stockage'**
  String get espaceStockageTitre;

  /// No description provided for @aProposSectionTitre.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get aProposSectionTitre;

  /// No description provided for @aProposOliveIQTitre.
  ///
  /// In fr, this message translates to:
  /// **'À propos d\'OliveIQ'**
  String get aProposOliveIQTitre;

  /// No description provided for @versionBuildLabel.
  ///
  /// In fr, this message translates to:
  /// **'Version {version} • Build {build}'**
  String versionBuildLabel(String version, String build);

  /// No description provided for @centreAideTitre.
  ///
  /// In fr, this message translates to:
  /// **'Centre d\'aide'**
  String get centreAideTitre;

  /// No description provided for @centreAideSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Documentation et support'**
  String get centreAideSousTitre;

  /// No description provided for @centreAideContenu.
  ///
  /// In fr, this message translates to:
  /// **'Pour toute question sur l\'utilisation d\'OliveIQ (acquisition d\'une analyse, lecture des résultats, connexion de l\'analyseur), contactez le support de votre laboratoire ou écrivez à support@olive-iq.local.\n\nUne documentation complète sera ajoutée ici prochainement.'**
  String get centreAideContenu;

  /// No description provided for @mentionsLegalesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Mentions légales & Confidentialité'**
  String get mentionsLegalesTitre;

  /// No description provided for @mentionsLegalesContenu.
  ///
  /// In fr, this message translates to:
  /// **'OliveIQ traite les données d\'analyse (échantillons, spectres, résultats) exclusivement dans le cadre du suivi qualité de l\'huile d\'olive, pour le compte de votre organisation.\n\nLes données personnelles du compte (nom, email, téléphone, photo de profil) ne sont utilisées que pour l\'identification et le fonctionnement de l\'application, jamais partagées avec des tiers.\n\nCette section sera complétée avec le texte légal définitif de votre organisation.'**
  String get mentionsLegalesContenu;

  /// No description provided for @seDeconnecterConfirmationTitre.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get seDeconnecterConfirmationTitre;

  /// No description provided for @seDeconnecterConfirmationTexte.
  ///
  /// In fr, this message translates to:
  /// **'Vous devrez vous reconnecter pour accéder à votre compte.'**
  String get seDeconnecterConfirmationTexte;

  /// No description provided for @confirmerBouton.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirmerBouton;

  /// No description provided for @enregistrerBouton.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get enregistrerBouton;

  /// No description provided for @profilMisAJourMessage.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour.'**
  String get profilMisAJourMessage;

  /// No description provided for @photoProfilMiseAJourMessage.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil mise à jour.'**
  String get photoProfilMiseAJourMessage;

  /// No description provided for @ancienMotDePasseLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get ancienMotDePasseLabel;

  /// No description provided for @changerMotDePasseBouton.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changerMotDePasseBouton;

  /// No description provided for @motDePasseModifieMessage.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié avec succès.'**
  String get motDePasseModifieMessage;

  /// No description provided for @sessionCreeeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Connectée le {date}'**
  String sessionCreeeLabel(String date);

  /// No description provided for @sessionExpireLabel.
  ///
  /// In fr, this message translates to:
  /// **'Expire le {date}'**
  String sessionExpireLabel(String date);

  /// No description provided for @sessionCouranteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Cet appareil'**
  String get sessionCouranteLabel;

  /// No description provided for @revoquerSessionBouton.
  ///
  /// In fr, this message translates to:
  /// **'Révoquer'**
  String get revoquerSessionBouton;

  /// No description provided for @revoquerToutesSaufCouranteBouton.
  ///
  /// In fr, this message translates to:
  /// **'Révoquer toutes les autres sessions'**
  String get revoquerToutesSaufCouranteBouton;

  /// No description provided for @aucuneSessionMessage.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session active.'**
  String get aucuneSessionMessage;

  /// No description provided for @seuilAciditeConformiteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Seuil de conformité — Acidité'**
  String get seuilAciditeConformiteLabel;

  /// No description provided for @seuilPeroxydeConformiteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Seuil de conformité — Indice de peroxyde'**
  String get seuilPeroxydeConformiteLabel;

  /// No description provided for @seuilEvooLabel.
  ///
  /// In fr, this message translates to:
  /// **'Seuil Extra Vierge (EVOO)'**
  String get seuilEvooLabel;

  /// No description provided for @seuilVooLabel.
  ///
  /// In fr, this message translates to:
  /// **'Seuil Vierge (VOO)'**
  String get seuilVooLabel;

  /// No description provided for @lectureSeuleAdministrateurMessage.
  ///
  /// In fr, this message translates to:
  /// **'Modifiable uniquement par un administrateur.'**
  String get lectureSeuleAdministrateurMessage;

  /// No description provided for @seuilsMisAJourMessage.
  ///
  /// In fr, this message translates to:
  /// **'Seuils mis à jour.'**
  String get seuilsMisAJourMessage;

  /// No description provided for @exporterMesDonneesBouton.
  ///
  /// In fr, this message translates to:
  /// **'Exporter mes données'**
  String get exporterMesDonneesBouton;

  /// No description provided for @viderCacheBouton.
  ///
  /// In fr, this message translates to:
  /// **'Vider le cache local'**
  String get viderCacheBouton;

  /// No description provided for @viderCacheConfirmationTitre.
  ///
  /// In fr, this message translates to:
  /// **'Vider le cache ?'**
  String get viderCacheConfirmationTitre;

  /// No description provided for @viderCacheConfirmationTexte.
  ///
  /// In fr, this message translates to:
  /// **'Les fichiers temporaires seront supprimés. Les analyses en attente de synchronisation ne sont jamais affectées.'**
  String get viderCacheConfirmationTexte;

  /// No description provided for @cacheVideMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cache vidé.'**
  String get cacheVideMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
