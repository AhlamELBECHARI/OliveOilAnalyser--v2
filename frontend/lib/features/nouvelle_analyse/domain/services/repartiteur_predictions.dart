import 'dart:math' as math;

import '../../../analyseur/domain/entities/resultat_scan_entity.dart';
import '../../../configuration/domain/entities/configuration_entity.dart';
import '../../../modeles/domain/entities/modele_entity.dart';
import '../entities/resultat_a_creer_entity.dart';

/// Répartit le résultat "brut" d'un scan (une prédiction par grandeur, voir
/// analyseur.ResultatScanEntity) sur les modèles ACTIFS réellement
/// enregistrés côté backend pour cette grandeur/ce type — c'est ici, et
/// nulle part ailleurs, que "un scan est évalué par plusieurs modèles
/// simultanément" (M5/M7, Mixing1/Mixing11 du fichier de référence) prend
/// forme : une ligne de PredictionModele par modèle actif correspondant.
///
/// Le modèle marqué `estReference` (voir modeles.services côté backend)
/// devient `modele_utilise` et fournit la valeur de synthèse retenue sans
/// perturbation ; les autres modèles actifs de la même grandeur reçoivent
/// une légère variation déterministe (dérivée de leur id) pour rester
/// crédibles sans être strictement identiques — n'a AUCUNE valeur
/// scientifique tant que le pipeline de scoring réel n'existe pas (voir
/// AnalyseurSimuleImpl._genererResultatSimule).
ResultatACreerEntity repartirPredictionsSurModeles({
  required ResultatScanEntity resultatScan,
  required List<ModeleEntity> modelesActifs,
  required ConfigurationEntity? configuration,
}) {
  final predictions = <PredictionAEnregistrer>[];
  double? acidite;
  int? modeleUtiliseId;
  double indicePeroxyde = 0;

  for (final brute in resultatScan.predictions) {
    final grandeur = grandeurPrediteDepuisCode(brute.grandeurPredite);
    final type = typeModeleDepuisCode(brute.typeModele);
    final candidats = modelesActifs
        .where((m) => m.estActif && m.grandeurPredite == grandeur && m.typeModele == type)
        .toList();

    if (grandeur == GrandeurPredite.indicePeroxyde && brute.valeurNumerique != null) {
      // Ne dépend d'aucun modèle particulier côté API (contrairement à
      // acidité, qui exige modele_utilise) : la valeur brute sert de
      // secours même si aucun modèle actif ne la couvre encore.
      indicePeroxyde = brute.valeurNumerique!;
    }

    if (candidats.isEmpty) continue;

    // Boucle manuelle plutôt que `firstWhere(orElse:)` : avec une liste dont
    // le type d'exécution est plus précis que le type statique déclaré ici
    // (ModeleModel vs ModeleEntity), la fermeture `orElse` est vérifiée
    // contre le type d'exécution et lève une TypeError — piège classique de
    // variance générique en Dart, confirmé en testant sur appareil physique.
    var modeleCible = candidats.first;
    for (final candidat in candidats) {
      if (candidat.estReference) {
        modeleCible = candidat;
        break;
      }
    }

    for (final modele in candidats) {
      final estCible = modele.id == modeleCible.id;
      final valeurNumerique = brute.valeurNumerique == null
          ? null
          : _valeurPourModele(brute.valeurNumerique!, modele.id, estCible: estCible);

      predictions.add(PredictionAEnregistrer(
        modeleId: modele.id,
        valeurNumerique: valeurNumerique,
        classePredite: brute.classePredite,
        scoreConfiance: brute.scoreConfiance,
      ));

      if (estCible) {
        if (grandeur == GrandeurPredite.acidite) {
          acidite = valeurNumerique;
          modeleUtiliseId = modele.id;
        } else if (grandeur == GrandeurPredite.indicePeroxyde && valeurNumerique != null) {
          indicePeroxyde = valeurNumerique;
        }
      }
    }
  }

  return ResultatACreerEntity(
    acidite: acidite,
    modeleUtiliseId: modeleUtiliseId,
    indicePeroxyde: indicePeroxyde,
    conforme: _estConforme(
      acidite: acidite,
      indicePeroxyde: indicePeroxyde,
      configuration: configuration,
    ),
    dureeAnalyseSecondes: resultatScan.dureeAnalyseSecondes,
    predictions: predictions,
  );
}

double _valeurPourModele(double valeurBase, int modeleId, {required bool estCible}) {
  if (estCible) return double.parse(valeurBase.toStringAsFixed(3));
  final aleatoire = math.Random(modeleId);
  final facteur = 0.97 + aleatoire.nextDouble() * 0.06;
  return double.parse((valeurBase * facteur).toStringAsFixed(3));
}

bool _estConforme({
  required double? acidite,
  required double indicePeroxyde,
  required ConfigurationEntity? configuration,
}) {
  if (acidite == null) return true;
  if (configuration == null) return true;
  return acidite <= configuration.seuilConformiteAcidite &&
      indicePeroxyde <= configuration.seuilConformitePeroxyde;
}
