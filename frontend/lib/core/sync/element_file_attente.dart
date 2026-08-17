import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/injection_container.dart';
import '../local_storage/local_database.dart';
import 'synchronisation_service.dart';

enum TypeElementFileAttente { echantillon, spectre, resultat }

/// Une ligne de l'écran "File d'attente de synchronisation" (Paramètres) —
/// vue agrégée, en lecture seule, des trois tables de file d'attente de
/// [LocalDatabase] (jamais une nouvelle table : ces trois-là restent la
/// seule source de vérité de ce qui reste à envoyer).
class ElementFileAttente extends Equatable {
  final TypeElementFileAttente type;
  final String id;
  final String libelle;
  final String statutSync;
  final String? messageErreur;
  final int nombreTentatives;
  final DateTime dateCreationLocale;

  const ElementFileAttente({
    required this.type,
    required this.id,
    required this.libelle,
    required this.statutSync,
    required this.messageErreur,
    required this.nombreTentatives,
    required this.dateCreationLocale,
  });

  bool get enErreur => statutSync == 'erreur';

  @override
  List<Object?> get props =>
      [type, id, libelle, statutSync, messageErreur, nombreTentatives, dateCreationLocale];
}

Future<List<ElementFileAttente>> _chargerElementsFileAttente(LocalDatabase base) async {
  final echantillons = await base.obtenirEchantillonsEnAttente();
  final spectres = await base.obtenirSpectresEnAttente();
  final resultats = await base.obtenirResultatsEnAttente();

  final elements = [
    for (final e in echantillons)
      ElementFileAttente(
        type: TypeElementFileAttente.echantillon,
        id: e.id,
        libelle: e.numero,
        statutSync: e.statutSync,
        messageErreur: e.messageErreurSync,
        nombreTentatives: e.nombreTentativesSync,
        dateCreationLocale: e.dateCreationLocale,
      ),
    for (final s in spectres)
      ElementFileAttente(
        type: TypeElementFileAttente.spectre,
        id: s.id,
        libelle: s.echantillonId,
        statutSync: s.statutSync,
        messageErreur: s.messageErreurSync,
        nombreTentatives: s.nombreTentativesSync,
        dateCreationLocale: s.dateCreationLocale,
      ),
    for (final r in resultats)
      ElementFileAttente(
        type: TypeElementFileAttente.resultat,
        id: r.id,
        libelle: r.echantillonId,
        statutSync: r.statutSync,
        messageErreur: r.messageErreurSync,
        nombreTentatives: r.nombreTentativesSync,
        dateCreationLocale: r.dateCreationLocale,
      ),
  ];
  elements.sort((a, b) => b.dateCreationLocale.compareTo(a.dateCreationLocale));
  return elements;
}

/// Se réabonne à [SynchronisationService.flusElementsEnAttente] pour
/// rester à jour en direct pendant/juste après une passe de synchronisation
/// — jamais de polling.
final elementsFileAttenteProvider = StreamProvider.autoDispose<List<ElementFileAttente>>((ref) {
  final base = sl<LocalDatabase>();
  final controller = StreamController<List<ElementFileAttente>>();

  Future<void> charger() async {
    if (controller.isClosed) return;
    controller.add(await _chargerElementsFileAttente(base));
  }

  charger();
  final abonnement = sl<SynchronisationService>().flusElementsEnAttente.listen((_) => charger());
  ref.onDispose(() {
    abonnement.cancel();
    controller.close();
  });
  return controller.stream;
});
