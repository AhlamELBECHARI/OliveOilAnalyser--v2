import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../local_storage/local_database.dart';
import '../network/connectivity_service.dart';
import '../network/token_refresher.dart';

const _cleSyncActivee = 'olive_iq_sync_activee';
const _cleDerniereSynchronisation = 'olive_iq_derniere_synchronisation';
const _delaiBackoffMax = Duration(minutes: 5);

/// Service de synchronisation hors ligne : pousse vers l'API tout
/// échantillon/spectre écrit localement (voir LocalDatabase) mais pas
/// encore confirmé par le serveur. Ne contient aucune logique UI — c'est le
/// seul endroit qui décide QUAND synchroniser (démarrage de l'app,
/// changement de connectivité, ou juste après une écriture locale) : voir
/// features/nouvelle_analyse/data/repositories/nouvelle_analyse_repository_impl.dart
/// pour l'appelant. La Presentation ne fait jamais de requête réseau
/// elle-même pour la synchronisation.
class SynchronisationService {
  final LocalDatabase _base;
  final Dio _dio;
  final ConnectivityService _connectivite;
  final TokenRefresher _tokenRefresher;
  final SharedPreferences _preferences;

  StreamSubscription<bool>? _abonnementConnectivite;
  bool _synchronisationEnCours = false;
  int _echecsConsecutifs = 0;
  DateTime? _prochaineTentativeAutorisee;
  final _elementsEnAttenteController = StreamController<int>.broadcast();
  final _derniereSynchronisationController = StreamController<DateTime?>.broadcast();
  final _enCoursController = StreamController<bool>.broadcast();

  SynchronisationService({
    required LocalDatabase base,
    required Dio dio,
    required SharedPreferences preferences,
    required ConnectivityService connectivite,
    required TokenRefresher tokenRefresher,
  })  : _base = base,
        _dio = dio,
        _preferences = preferences,
        _connectivite = connectivite,
        _tokenRefresher = tokenRefresher;

  /// Nombre d'échantillons/spectres écrits localement mais pas encore
  /// confirmés par l'API — alimente l'indicateur visible "en attente de
  /// synchronisation" (Partie C du cahier des charges).
  Stream<int> get flusElementsEnAttente => _elementsEnAttenteController.stream;

  /// Date de la dernière synchronisation réussie (tout était à jour à la
  /// fin d'une passe), persistée localement — voir Partie B, section
  /// "Données & Synchronisation".
  Stream<DateTime?> get flusDerniereSynchronisation => _derniereSynchronisationController.stream;

  /// Vrai pendant qu'une passe de synchronisation est en cours — alimente
  /// l'indicateur global en ligne/hors ligne/synchronisation (Partie C).
  Stream<bool> get flusSynchronisationEnCours => _enCoursController.stream;

  DateTime? get derniereSynchronisation {
    final valeur = _preferences.getString(_cleDerniereSynchronisation);
    return valeur == null ? null : DateTime.tryParse(valeur);
  }

  /// Interrupteur "Synchronisation cloud" (Partie B) : quand désactivé, les
  /// données restent écrites en local (voir NouvelleAnalyseRepositoryImpl,
  /// qui écrit toujours en local en premier) sans jamais être envoyées au
  /// serveur — [synchroniser] devient un no-op tant qu'il reste désactivé.
  bool get estActivee => _preferences.getBool(_cleSyncActivee) ?? true;

  Future<void> definirActivee(bool activee) async {
    await _preferences.setBool(_cleSyncActivee, activee);
    if (activee) unawaited(synchroniser(forcer: true));
  }

  /// À appeler une fois au démarrage de l'app (voir injection_container) :
  /// tente une synchronisation immédiate puis se ré-abonne aux changements
  /// de connectivité pour re-synchroniser dès qu'une connexion réapparaît.
  /// Un retour de réseau est toujours un événement neuf : il ignore le
  /// délai de backoff (voir [synchroniser]).
  void demarrerEcoute() {
    unawaited(synchroniser());
    _abonnementConnectivite ??= _connectivite.flusEnLigne.listen((enLigne) {
      if (enLigne) unawaited(synchroniser(forcer: true));
    });
  }

  void arreterEcoute() {
    _abonnementConnectivite?.cancel();
    _abonnementConnectivite = null;
  }

  /// Pousse tous les échantillons puis spectres en attente vers l'API, après
  /// avoir renouvelé le token d'accès si besoin. Réentrant : un appel
  /// pendant qu'une synchronisation est déjà en cours est ignoré
  /// silencieusement (le prochain déclencheur la relancera). Jamais appelée
  /// depuis la Presentation directement — toujours en arrière-plan, sans
  /// jamais bloquer un écran ni faire échouer une action utilisateur pour
  /// une simple absence de réseau. No-op tant que [estActivee] est faux.
  ///
  /// [forcer] ignore le backoff progressif (voir _echecsConsecutifs) :
  /// utilisé pour un retour de réseau détecté, l'activation du réglage, ou
  /// une relance manuelle depuis l'écran "File d'attente" — jamais pour les
  /// déclenchements opportunistes après une simple écriture locale, qui
  /// doivent rester silencieusement freinés après des échecs répétés pour
  /// ne jamais boucler indéfiniment sur un serveur qui refuse.
  Future<void> synchroniser({bool forcer = false}) async {
    // Toujours à jour, y compris hors ligne ou avant même de savoir si une
    // tentative réseau aura lieu : c'est une simple lecture locale, jamais
    // une preuve de synchronisation réussie (voir _publierElementsEnAttente,
    // seul endroit qui horodate "dernière synchronisation"). Sans ceci, un
    // élément créé hors ligne resterait invisible dans l'indicateur global
    // et l'écran "File d'attente" tant qu'aucune passe complète n'a eu lieu.
    unawaited(_publierCompteEnAttente());

    if (_synchronisationEnCours || !estActivee) return;
    if (!forcer &&
        _prochaineTentativeAutorisee != null &&
        DateTime.now().isBefore(_prochaineTentativeAutorisee!)) {
      return;
    }
    // Vérification locale (pas de requête réseau) : évite de payer le délai
    // d'expiration de chaque appel Dio quand l'absence de réseau est déjà
    // connue de l'OS (cahier des charges, Partie A, section 7).
    if (!await _connectivite.estEnLigne()) return;

    _synchronisationEnCours = true;
    if (!_enCoursController.isClosed) _enCoursController.add(true);
    try {
      final rafraichissement = await _tokenRefresher.rafraichir();
      // Une session hors ligne expirée (sessionInvalide) laisse la file
      // d'attente intacte : elle sera rejouée après reconnexion — jamais de
      // perte de données locales pour un problème d'authentification.
      if (rafraichissement == ResultatRafraichissement.sessionInvalide) return;

      await _synchroniserEchantillons();
      // Un spectre ne peut être accepté par l'API que si son échantillon
      // parent l'est déjà (contrainte de clé étrangère côté serveur) :
      // toujours synchroniser les échantillons avant les spectres.
      await _synchroniserSpectres();
      // Même contrainte pour les résultats (FK vers l'échantillon).
      await _synchroniserResultats();

      final enAttente = await _base.compterElementsEnAttente();
      if (enAttente == 0) {
        _echecsConsecutifs = 0;
        _prochaineTentativeAutorisee = null;
      } else {
        _echecsConsecutifs++;
        final secondes = math.min(
          _delaiBackoffMax.inSeconds,
          math.pow(2, _echecsConsecutifs).toInt(),
        );
        _prochaineTentativeAutorisee = DateTime.now().add(Duration(seconds: secondes));
      }
    } finally {
      _synchronisationEnCours = false;
      if (!_enCoursController.isClosed) _enCoursController.add(false);
      await _publierElementsEnAttente();
    }
  }

  /// Republie uniquement le compte (lecture locale pure, jamais un indice de
  /// succès réseau) — voir l'appel en tête de [synchroniser].
  Future<void> _publierCompteEnAttente() async {
    final enAttente = await _base.compterElementsEnAttente();
    if (!_elementsEnAttenteController.isClosed) {
      _elementsEnAttenteController.add(enAttente);
    }
  }

  Future<void> _publierElementsEnAttente() async {
    final enAttente = await _base.compterElementsEnAttente();
    if (!_elementsEnAttenteController.isClosed) {
      _elementsEnAttenteController.add(enAttente);
    }
    // Plus rien en attente à la fin de cette passe : tout est réellement à
    // jour côté serveur, c'est le seul moment honnête pour horodater "la
    // dernière synchronisation" (jamais à chaque simple tentative, qui
    // pourrait n'avoir rencontré que des échecs réseau).
    if (enAttente == 0) {
      final maintenant = DateTime.now();
      await _preferences.setString(_cleDerniereSynchronisation, maintenant.toIso8601String());
      if (!_derniereSynchronisationController.isClosed) {
        _derniereSynchronisationController.add(maintenant);
      }
    }
  }

  Future<void> _synchroniserEchantillons() async {
    final enAttente = await _base.obtenirEchantillonsEnAttente();
    for (final echantillon in enAttente) {
      try {
        await _dio.post('/echantillons/', data: {
          'id': echantillon.id,
          'numero': echantillon.numero,
          'date_analyse': echantillon.dateAnalyse.toUtc().toIso8601String(),
          'origine': echantillon.origine,
          'variete': echantillon.variete,
          'producteur': echantillon.producteur,
          'region': echantillon.region,
          if (echantillon.dateRecolte != null)
            'date_recolte': _formaterDate(echantillon.dateRecolte!),
          'latitude': echantillon.latitude,
          'longitude': echantillon.longitude,
          'notes': echantillon.notes,
        });
        await _base.marquerEchantillonSynchronise(echantillon.id);
      } catch (e) {
        await _base.incrementerTentativesEchantillon(echantillon.id);
        await _base.marquerEchantillonErreur(echantillon.id, _messageErreur(e));
      }
    }
  }

  Future<void> _synchroniserSpectres() async {
    final enAttente = await _base.obtenirSpectresEnAttente();
    for (final spectre in enAttente) {
      final echantillon = await _base.obtenirEchantillon(spectre.echantillonId);
      final echantillonSynchronise = echantillon != null && echantillon.statutSync == 'synchronise';
      if (!echantillonSynchronise) continue;

      try {
        await _dio.post('/spectres/', data: {
          'id': spectre.id,
          'echantillon': spectre.echantillonId,
          'valeurs_x': jsonDecode(spectre.valeursXJson),
          'valeurs_y': jsonDecode(spectre.valeursYJson),
          'nombre_series': spectre.nombreSeries,
          'date_acquisition': spectre.dateAcquisition.toUtc().toIso8601String(),
          'checksum': spectre.checksum,
          if (spectre.tailleDonnees != null) 'taille_donnees': spectre.tailleDonnees,
        });
        await _base.marquerSpectreSynchronise(spectre.id);
      } catch (e) {
        await _base.incrementerTentativesSpectre(spectre.id);
        await _base.marquerSpectreErreur(spectre.id, _messageErreur(e));
      }
    }
  }

  /// Un résultat sans `modele_utilise`/`acidite` ne devrait jamais être
  /// écrit localement (voir ResultatACreerEntity.peutEtreEnregistre,
  /// vérifié avant l'écriture) — protection défensive seulement, pour ne
  /// jamais poster un payload incomplet que l'API rejetterait de toute
  /// façon.
  Future<void> _synchroniserResultats() async {
    final enAttente = await _base.obtenirResultatsEnAttente();
    for (final resultat in enAttente) {
      final echantillon = await _base.obtenirEchantillon(resultat.echantillonId);
      final echantillonSynchronise = echantillon != null && echantillon.statutSync == 'synchronise';
      if (!echantillonSynchronise) continue;
      if (resultat.modeleUtiliseId == null || resultat.acidite == null) continue;

      try {
        final predictions = await _base.obtenirPredictionsPourResultat(resultat.id);
        await _dio.post('/resultats/', data: {
          'id': resultat.id,
          'echantillon': resultat.echantillonId,
          'modele_utilise': resultat.modeleUtiliseId,
          'acidite': resultat.acidite,
          'indice_peroxyde': resultat.indicePeroxyde ?? 0,
          'conforme': resultat.conforme ?? true,
          if (resultat.dureeAnalyseSecondes != null)
            'duree_analyse_secondes': resultat.dureeAnalyseSecondes,
          'commentaire': resultat.commentaire,
          'predictions': [
            for (final prediction in predictions)
              {
                'modele': prediction.modeleId,
                if (prediction.valeurNumerique != null)
                  'valeur_numerique': prediction.valeurNumerique,
                if (prediction.classePredite.isNotEmpty) 'classe_predite': prediction.classePredite,
                if (prediction.scoreConfiance != null) 'score_confiance': prediction.scoreConfiance,
              },
          ],
        });
        await _base.marquerResultatSynchronise(resultat.id);
      } catch (e) {
        await _base.incrementerTentativesResultat(resultat.id);
        await _base.marquerResultatErreur(resultat.id, _messageErreur(e));
      }
    }
  }

  String _formaterDate(DateTime date) => date.toIso8601String().split('T').first;

  String _messageErreur(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] is String) return data['detail'] as String;
      return e.message ?? 'Erreur réseau';
    }
    return e.toString();
  }

  Future<void> disposer() async {
    arreterEcoute();
    await _elementsEnAttenteController.close();
    await _derniereSynchronisationController.close();
    await _enCoursController.close();
  }
}
