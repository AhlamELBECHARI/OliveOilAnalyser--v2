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
