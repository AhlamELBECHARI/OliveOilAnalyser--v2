import 'dart:async';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../analyseur/domain/entities/commande_analyseur.dart';
import '../../../analyseur/domain/entities/etat_connexion_analyseur_entity.dart';
import '../../../analyseur/domain/entities/info_appareil_analyseur_entity.dart';
import '../../../analyseur/domain/entities/qualite_signal_entity.dart';
import '../../../analyseur/domain/entities/resultat_scan_entity.dart';
import '../../../analyseur/domain/entities/spectre_entity.dart';
import '../../../analyseur/domain/services/calculateur_qualite_signal.dart';
import '../../../analyseur/domain/usecases/connecter_automatiquement_usecase.dart';
import '../../../analyseur/domain/usecases/envoyer_commande_usecase.dart';
import '../../../analyseur/domain/usecases/observer_etat_connexion_usecase.dart';
import '../../../analyseur/domain/usecases/observer_resultat_scan_usecase.dart';
import '../../../analyseur/domain/usecases/observer_spectre_usecase.dart';
import '../../../analyseur/domain/usecases/obtenir_info_appareil_usecase.dart';
import '../../../configuration/domain/entities/configuration_entity.dart';
import '../../../configuration/domain/usecases/obtenir_configuration_usecase.dart';
import '../../../modeles/domain/entities/modele_entity.dart';
import '../../../modeles/domain/usecases/lister_modeles_usecase.dart';
import '../../domain/entities/nouvel_echantillon_entity.dart';
import '../../domain/entities/resultat_a_creer_entity.dart';
import '../../domain/services/repartiteur_predictions.dart';
import '../../domain/usecases/enregistrer_echantillon_usecase.dart';
import '../../domain/usecases/enregistrer_resultat_usecase.dart';
import '../../domain/usecases/enregistrer_spectre_usecase.dart';

enum EtapeAnalyse { connexion, echantillon, analyse, resultats }

enum ModeCarteEchantillon { formulaire, consultation }

const _uuid = Uuid();

/// Format `SMP-AAAA-NNNNN` (voir Partie A du cahier des charges) : proposé
/// par défaut mais toujours modifiable par l'utilisateur dans le formulaire.
String genererNumeroEchantillon() {
  final annee = DateTime.now().year;
  final suffixe = math.Random().nextInt(100000).toString().padLeft(5, '0');
  return 'SMP-$annee-$suffixe';
}

NouvelEchantillonEntity _nouveauBrouillon() {
  return NouvelEchantillonEntity(
    id: _uuid.v4(),
    numero: genererNumeroEchantillon(),
    dateAnalyse: DateTime.now(),
  );
}

class NouvelleAnalyseState extends Equatable {
  final ModeCarteEchantillon modeCarteEchantillon;
  final NouvelEchantillonEntity brouillon;
  final NouvelEchantillonEntity? echantillonValide;
  final EtatConnexionAnalyseurEntity etatConnexion;
  final InfoAppareilAnalyseurEntity? infoAppareil;
  final bool acquisitionEnCours;
  final bool acquisitionTerminee;
  final SpectreBrutEntity? dernierSpectre;
  final QualiteSignalEntity? qualiteSignal;
  final bool enregistrementEnCours;
  final Failure? echecEnregistrement;
  final bool positionEnCoursDeChargement;
  final String? echecPosition;
  final bool etapeConnexionFranchie;
  final String? resultatId;
  final ResultatACreerEntity? resultatCree;
  // Modèles/seuils utilisés pour calculer [resultatCree], conservés pour
  // que l'étape Résultats puisse afficher nom/version/type de chaque
  // modèle et la catégorie commerciale sans nouvel appel réseau.
  final List<ModeleEntity> modelesResultat;
  final ConfigurationEntity? configurationResultat;
  final bool calculResultatEnCours;
  // `true` si le scan est terminé mais qu'aucun modèle de régression actif
  // pour l'acidité n'est enregistré côté backend : aucun Resultat ne peut
  // alors être créé (modele_utilise est obligatoire côté API) — voir
  // ResultatACreerEntity.peutEtreEnregistre.
  final bool aucunModeleActifPourResultat;

  NouvelleAnalyseState({
    this.modeCarteEchantillon = ModeCarteEchantillon.formulaire,
    NouvelEchantillonEntity? brouillon,
    this.echantillonValide,
    this.etatConnexion = const EtatConnexionAnalyseurEntity.deconnecte(),
    this.infoAppareil,
    this.acquisitionEnCours = false,
    this.acquisitionTerminee = false,
    this.dernierSpectre,
    this.qualiteSignal,
    this.enregistrementEnCours = false,
    this.echecEnregistrement,
    this.positionEnCoursDeChargement = false,
    this.echecPosition,
    this.etapeConnexionFranchie = false,
    this.resultatId,
    this.resultatCree,
    this.modelesResultat = const [],
    this.configurationResultat,
    this.calculResultatEnCours = false,
    this.aucunModeleActifPourResultat = false,
  }) : brouillon = brouillon ?? _nouveauBrouillon();

  /// L'écran est un unique scroll par étape (pas un assistant paginé au sens
  /// strict) : l'étape affichée par le stepper en haut est dérivée de
  /// l'avancement réel, jamais un compteur manipulé indépendamment de l'état
  /// des cartes. [etapeConnexionFranchie] reste vraie une fois passée (voir
  /// NouvelleAnalyseNotifier._initialiser et .continuerSansAppareil) : une
  /// coupure Bluetooth en cours de saisie ne doit jamais ramener l'écran à
  /// l'étape Connexion et faire perdre le travail en cours.
  EtapeAnalyse get etapeCourante {
    if (acquisitionTerminee) return EtapeAnalyse.resultats;
    if (echantillonValide != null) return EtapeAnalyse.analyse;
    if (etapeConnexionFranchie) return EtapeAnalyse.echantillon;
    return EtapeAnalyse.connexion;
  }

  bool get peutDemarrerAnalyse =>
      echantillonValide != null && etatConnexion.estConnecte && !acquisitionEnCours;

  NouvelleAnalyseState copierAvec({
    ModeCarteEchantillon? modeCarteEchantillon,
    NouvelEchantillonEntity? brouillon,
    NouvelEchantillonEntity? echantillonValide,
    EtatConnexionAnalyseurEntity? etatConnexion,
    InfoAppareilAnalyseurEntity? infoAppareil,
    bool? acquisitionEnCours,
    bool? acquisitionTerminee,
    SpectreBrutEntity? dernierSpectre,
    QualiteSignalEntity? qualiteSignal,
    bool? enregistrementEnCours,
    Failure? echecEnregistrement,
    bool? positionEnCoursDeChargement,
    String? echecPosition,
    bool? etapeConnexionFranchie,
    String? resultatId,
    ResultatACreerEntity? resultatCree,
    List<ModeleEntity>? modelesResultat,
    ConfigurationEntity? configurationResultat,
    bool? calculResultatEnCours,
    bool? aucunModeleActifPourResultat,
    bool effacerEchecEnregistrement = false,
    bool effacerEchecPosition = false,
    bool effacerSpectre = false,
    bool effacerResultat = false,
  }) {
    return NouvelleAnalyseState(
      modeCarteEchantillon: modeCarteEchantillon ?? this.modeCarteEchantillon,
      brouillon: brouillon ?? this.brouillon,
      echantillonValide: echantillonValide ?? this.echantillonValide,
      etatConnexion: etatConnexion ?? this.etatConnexion,
      infoAppareil: infoAppareil ?? this.infoAppareil,
      acquisitionEnCours: acquisitionEnCours ?? this.acquisitionEnCours,
      acquisitionTerminee: acquisitionTerminee ?? this.acquisitionTerminee,
      dernierSpectre: effacerSpectre ? null : (dernierSpectre ?? this.dernierSpectre),
      qualiteSignal: effacerSpectre ? null : (qualiteSignal ?? this.qualiteSignal),
      enregistrementEnCours: enregistrementEnCours ?? this.enregistrementEnCours,
      echecEnregistrement:
          effacerEchecEnregistrement ? null : (echecEnregistrement ?? this.echecEnregistrement),
      positionEnCoursDeChargement: positionEnCoursDeChargement ?? this.positionEnCoursDeChargement,
      echecPosition: effacerEchecPosition ? null : (echecPosition ?? this.echecPosition),
      etapeConnexionFranchie: etapeConnexionFranchie ?? this.etapeConnexionFranchie,
      resultatId: effacerResultat ? null : (resultatId ?? this.resultatId),
      resultatCree: effacerResultat ? null : (resultatCree ?? this.resultatCree),
      modelesResultat: effacerResultat ? const [] : (modelesResultat ?? this.modelesResultat),
      configurationResultat:
          effacerResultat ? null : (configurationResultat ?? this.configurationResultat),
      calculResultatEnCours: calculResultatEnCours ?? this.calculResultatEnCours,
      aucunModeleActifPourResultat:
          effacerResultat ? false : (aucunModeleActifPourResultat ?? this.aucunModeleActifPourResultat),
    );
  }

  @override
  List<Object?> get props => [
        modeCarteEchantillon,
        brouillon,
        echantillonValide,
        etatConnexion,
        infoAppareil,
        acquisitionEnCours,
        acquisitionTerminee,
        dernierSpectre,
        qualiteSignal,
        enregistrementEnCours,
        echecEnregistrement,
        positionEnCoursDeChargement,
        echecPosition,
        etapeConnexionFranchie,
        resultatId,
        resultatCree,
        modelesResultat,
        configurationResultat,
        calculResultatEnCours,
        aucunModeleActifPourResultat,
      ];
}

class NouvelleAnalyseNotifier extends StateNotifier<NouvelleAnalyseState> {
  final ConnecterAutomatiquementUseCase _connecterAutomatiquement;
  final ObserverEtatConnexionUseCase _observerEtatConnexion;
  final ObserverSpectreUseCase _observerSpectre;
  final ObserverResultatScanUseCase _observerResultatScan;
  final ObtenirInfoAppareilUseCase _obtenirInfoAppareil;
  final EnvoyerCommandeUseCase _envoyerCommande;
  final EnregistrerEchantillonUseCase _enregistrerEchantillon;
  final EnregistrerSpectreUseCase _enregistrerSpectre;
  final EnregistrerResultatUseCase _enregistrerResultat;
  final ListerModelesUseCase _listerModeles;
  final ObtenirConfigurationUseCase _obtenirConfiguration;

  StreamSubscription<EtatConnexionAnalyseurEntity>? _abonnementEtat;
  StreamSubscription<SpectreBrutEntity>? _abonnementSpectre;
  StreamSubscription<ResultatScanEntity>? _abonnementResultat;

  NouvelleAnalyseNotifier({
    required ConnecterAutomatiquementUseCase connecterAutomatiquement,
    required ObserverEtatConnexionUseCase observerEtatConnexion,
    required ObserverSpectreUseCase observerSpectre,
    required ObserverResultatScanUseCase observerResultatScan,
    required ObtenirInfoAppareilUseCase obtenirInfoAppareil,
    required EnvoyerCommandeUseCase envoyerCommande,
    required EnregistrerEchantillonUseCase enregistrerEchantillon,
    required EnregistrerSpectreUseCase enregistrerSpectre,
    required EnregistrerResultatUseCase enregistrerResultat,
    required ListerModelesUseCase listerModeles,
    required ObtenirConfigurationUseCase obtenirConfiguration,
  })  : _connecterAutomatiquement = connecterAutomatiquement,
        _observerEtatConnexion = observerEtatConnexion,
        _observerSpectre = observerSpectre,
        _observerResultatScan = observerResultatScan,
        _obtenirInfoAppareil = obtenirInfoAppareil,
        _envoyerCommande = envoyerCommande,
        _enregistrerEchantillon = enregistrerEchantillon,
        _enregistrerSpectre = enregistrerSpectre,
        _enregistrerResultat = enregistrerResultat,
        _listerModeles = listerModeles,
        _obtenirConfiguration = obtenirConfiguration,
        super(NouvelleAnalyseState()) {
    _initialiser();
  }

  void _initialiser() {
    _abonnementEtat = _observerEtatConnexion().listen((etat) {
      state = state.copierAvec(etatConnexion: etat);
      if (etat.estConnecte) _rafraichirInfoAppareil();
    });
    _abonnementSpectre = _observerSpectre().listen((spectre) {
      state = state.copierAvec(
        dernierSpectre: spectre,
        qualiteSignal: calculerQualiteSignal(spectre),
      );
    });
    _abonnementResultat = _observerResultatScan().listen(_creerResultat);
    unawaited(_connecterAutomatiquement(const NoParams()));
  }

  Future<void> _rafraichirInfoAppareil() async {
    final resultat = await _obtenirInfoAppareil(const NoParams());
    if (!mounted) return;
    resultat.fold((_) {}, (info) => state = state.copierAvec(infoAppareil: info));
  }

  void reessayerConnexion() {
    unawaited(_connecterAutomatiquement(const NoParams()));
  }

  /// Fait passer l'écran de l'étape Connexion à l'étape Échantillon —
  /// utilisé aussi bien par le bouton "Continuer" (une fois l'appareil
  /// connecté) que par le lien "Continuer sans appareil" (saisie hors ligne
  /// des métadonnées, pour analyser plus tard). Ne dispense jamais d'une
  /// vraie connexion pour démarrer l'acquisition elle-même (voir
  /// peutDemarrerAnalyse, toujours conditionné à etatConnexion.estConnecte).
  void validerEtapeConnexion() {
    state = state.copierAvec(etapeConnexionFranchie: true);
  }

  // --- Carte "Informations Échantillon" ---

  void mettreAJourNumero(String numero) =>
      state = state.copierAvec(brouillon: state.brouillon.copierAvec(numero: numero));

  void mettreAJourProducteur(String producteur) =>
      state = state.copierAvec(brouillon: state.brouillon.copierAvec(producteur: producteur));

  void mettreAJourVariete(String variete) =>
      state = state.copierAvec(brouillon: state.brouillon.copierAvec(variete: variete));

  void mettreAJourRegion(String region) =>
      state = state.copierAvec(brouillon: state.brouillon.copierAvec(region: region));

  void mettreAJourDateRecolte(DateTime date) =>
      state = state.copierAvec(brouillon: state.brouillon.copierAvec(dateRecolte: date));

  Future<void> definirPositionActuelle() async {
    state = state.copierAvec(positionEnCoursDeChargement: true, effacerEchecPosition: true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const _LocalisationIndisponibleException('service');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const _LocalisationIndisponibleException('permission');
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      state = state.copierAvec(
        brouillon: state.brouillon.copierAvec(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
        positionEnCoursDeChargement: false,
      );
    } on _LocalisationIndisponibleException catch (e) {
      if (!mounted) return;
      state = state.copierAvec(positionEnCoursDeChargement: false, echecPosition: e.raison);
    } catch (_) {
      if (!mounted) return;
      state = state.copierAvec(positionEnCoursDeChargement: false, echecPosition: 'erreur');
    }
  }

  Future<void> validerEchantillon() async {
    state = state.copierAvec(enregistrementEnCours: true, effacerEchecEnregistrement: true);
    final resultat = await _enregistrerEchantillon(state.brouillon);
    if (!mounted) return;
    resultat.fold(
      (failure) =>
          state = state.copierAvec(enregistrementEnCours: false, echecEnregistrement: failure),
      (_) => state = state.copierAvec(
        enregistrementEnCours: false,
        echantillonValide: state.brouillon,
        modeCarteEchantillon: ModeCarteEchantillon.consultation,
      ),
    );
  }

  void modifierEchantillon() {
    state = state.copierAvec(modeCarteEchantillon: ModeCarteEchantillon.formulaire);
  }

  // --- Acquisition ---

  Future<void> demarrerAnalyse() async {
    if (!state.peutDemarrerAnalyse) return;
    state = state.copierAvec(
      acquisitionEnCours: true,
      acquisitionTerminee: false,
      effacerSpectre: true,
      effacerEchecEnregistrement: true,
      effacerResultat: true,
    );

    final resultat = await _envoyerCommande(CommandeAnalyseur.demarrerAcquisition);
    if (!mounted) return;
    // `Either.fold` exige un seul type de retour pour ses deux branches :
    // l'enregistrement du spectre (asynchrone) ne peut donc pas vivre dans
    // la branche `Right` de fold — il est fait séparément ci-dessous, une
    // fois l'échec éventuel écarté.
    final echec = resultat.fold<Failure?>((failure) => failure, (_) => null);
    if (echec != null) {
      state = state.copierAvec(acquisitionEnCours: false, echecEnregistrement: echec);
      return;
    }

    state = state.copierAvec(acquisitionEnCours: false, acquisitionTerminee: true);
    final spectre = state.dernierSpectre;
    final echantillon = state.echantillonValide;
    if (spectre != null && echantillon != null) {
      await _enregistrerSpectre(
        EnregistrerSpectreParams(echantillonId: echantillon.id, spectre: spectre),
      );
    }
  }

  /// Appelé quand [AnalyseurRepository.flusResultat] émet (voir
  /// _initialiser) : répartit le résultat "brut" du scan sur les modèles
  /// actifs réels (voir repartirPredictionsSurModeles), puis l'enregistre
  /// localement — jamais directement sur le réseau, comme le reste de cet
  /// écran (voir NouvelleAnalyseRepositoryImpl).
  Future<void> _creerResultat(ResultatScanEntity resultatScan) async {
    final echantillon = state.echantillonValide;
    if (echantillon == null) return;

    state = state.copierAvec(calculResultatEnCours: true);

    final modelesResultat = await _listerModeles(const NoParams());
    if (!mounted) return;
    final modelesActifs = modelesResultat.fold((_) => const <ModeleEntity>[], (liste) => liste);

    final configurationResultat = await _obtenirConfiguration(const NoParams());
    if (!mounted) return;
    final configuration = configurationResultat.fold((_) => null, (c) => c);

    final resultatACreer = repartirPredictionsSurModeles(
      resultatScan: resultatScan,
      modelesActifs: modelesActifs,
      configuration: configuration,
    );

    if (!resultatACreer.peutEtreEnregistre) {
      state = state.copierAvec(
        calculResultatEnCours: false,
        aucunModeleActifPourResultat: true,
      );
      return;
    }

    final resultatId = _uuid.v4();
    await _enregistrerResultat(EnregistrerResultatParams(
      resultatId: resultatId,
      echantillonId: echantillon.id,
      resultat: resultatACreer,
    ));
    if (!mounted) return;
    state = state.copierAvec(
      calculResultatEnCours: false,
      resultatId: resultatId,
      resultatCree: resultatACreer,
      modelesResultat: modelesActifs,
      configurationResultat: configuration,
    );
  }

  /// Le bouton "Annuler" de l'écran (et "Nouvelle analyse" une fois une
  /// acquisition terminée) ne quitte jamais l'écran — Analyse est un onglet
  /// permanent, pas un écran qu'on ferme (voir Partie A du cahier des
  /// charges) : il réinitialise seulement le formulaire en cours, avec un
  /// nouvel identifiant d'échantillon. L'état de connexion réel à
  /// l'instrument est préservé, lui, puisqu'il ne dépend pas du formulaire.
  Future<void> reinitialiser() async {
    if (state.acquisitionEnCours) {
      await _envoyerCommande(CommandeAnalyseur.annulerAcquisition);
    }
    if (!mounted) return;
    state = NouvelleAnalyseState(
      etatConnexion: state.etatConnexion,
      infoAppareil: state.infoAppareil,
      etapeConnexionFranchie: state.etapeConnexionFranchie,
    );
  }

  /// Bouton "Nouvelle analyse" de l'étape Résultats : contrairement à
  /// [reinitialiser] (utilisé par "Annuler" plus tôt dans le parcours, qui
  /// ne remonte qu'à l'étape Échantillon), celui-ci ramène explicitement à
  /// l'étape 1 (Connexion) — voir EtapeAnalyse.etapeCourante, dérivée de
  /// etapeConnexionFranchie, laissé à false ici.
  void demarrerNouvelleAnalyse() {
    state = NouvelleAnalyseState(etatConnexion: state.etatConnexion, infoAppareil: state.infoAppareil);
  }

  @override
  void dispose() {
    // Ne libère JAMAIS AnalyseurRepository ici : c'est un singleton get_it
    // partagé avec la carte "État du laboratoire" du dashboard — seuls les
    // abonnements propres à cet écran sont annulés.
    _abonnementEtat?.cancel();
    _abonnementSpectre?.cancel();
    _abonnementResultat?.cancel();
    super.dispose();
  }
}

class _LocalisationIndisponibleException implements Exception {
  final String raison;
  const _LocalisationIndisponibleException(this.raison);
}

final nouvelleAnalyseProvider =
    StateNotifierProvider.autoDispose<NouvelleAnalyseNotifier, NouvelleAnalyseState>((ref) {
  return NouvelleAnalyseNotifier(
    connecterAutomatiquement: sl(),
    observerEtatConnexion: sl(),
    observerSpectre: sl(),
    observerResultatScan: sl(),
    obtenirInfoAppareil: sl(),
    envoyerCommande: sl(),
    enregistrerEchantillon: sl(),
    enregistrerSpectre: sl(),
    enregistrerResultat: sl(),
    listerModeles: sl(),
    obtenirConfiguration: sl(),
  );
});
