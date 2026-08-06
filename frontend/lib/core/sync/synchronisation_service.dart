import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../local_storage/local_database.dart';

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
  final Connectivity _connectivite;

  StreamSubscription<List<ConnectivityResult>>? _abonnementConnectivite;
  bool _synchronisationEnCours = false;
  final _elementsEnAttenteController = StreamController<int>.broadcast();

  SynchronisationService({
    required LocalDatabase base,
    required Dio dio,
    Connectivity? connectivite,
  })  : _base = base,
        _dio = dio,
        _connectivite = connectivite ?? Connectivity();

  /// Nombre d'échantillons/spectres écrits localement mais pas encore
  /// confirmés par l'API — alimente l'indicateur visible "en attente de
  /// synchronisation" (Partie C du cahier des charges).
  Stream<int> get flusElementsEnAttente => _elementsEnAttenteController.stream;

  /// À appeler une fois au démarrage de l'app (voir injection_container) :
  /// tente une synchronisation immédiate puis se ré-abonne aux changements
  /// de connectivité pour re-synchroniser dès qu'une connexion réapparaît.
  void demarrerEcoute() {
    unawaited(synchroniser());
    _abonnementConnectivite ??= _connectivite.onConnectivityChanged.listen((resultats) {
      if (resultats.any((resultat) => resultat != ConnectivityResult.none)) {
        unawaited(synchroniser());
      }
    });
  }

  void arreterEcoute() {
    _abonnementConnectivite?.cancel();
    _abonnementConnectivite = null;
  }

  /// Pousse tous les échantillons puis spectres en attente vers l'API.
  /// Réentrant : un appel pendant qu'une synchronisation est déjà en cours
  /// est ignoré silencieusement (le prochain déclencheur la relancera).
  /// Jamais appelée depuis la Presentation directement — toujours en
  /// arrière-plan, sans jamais bloquer un écran ni faire échouer une
  /// action utilisateur pour une simple absence de réseau.
  Future<void> synchroniser() async {
    if (_synchronisationEnCours) return;
    _synchronisationEnCours = true;
    try {
      await _synchroniserEchantillons();
      // Un spectre ne peut être accepté par l'API que si son échantillon
      // parent l'est déjà (contrainte de clé étrangère côté serveur) :
      // toujours synchroniser les échantillons avant les spectres.
      await _synchroniserSpectres();
    } finally {
      _synchronisationEnCours = false;
      await _publierElementsEnAttente();
    }
  }

  Future<void> _publierElementsEnAttente() async {
    if (_elementsEnAttenteController.isClosed) return;
    _elementsEnAttenteController.add(await _base.compterElementsEnAttente());
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
  }
}
