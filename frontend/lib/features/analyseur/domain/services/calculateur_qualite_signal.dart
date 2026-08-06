import 'dart:math' as math;

import '../entities/qualite_signal_entity.dart';
import '../entities/spectre_entity.dart';

/// Calcule les indicateurs de qualité (SNR, intensité, bruit, qualité
/// globale) à partir du spectre réellement reçu — jamais de valeur en dur.
///
/// La formule exacte (poids, normalisation) est une estimation raisonnable
/// en l'absence de documentation constructeur sur le rapport signal/bruit
/// natif de l'instrument ; à ajuster une fois cette documentation
/// disponible, sans changer la signature ni les appelants (voir
/// data/protocole/protocole_spectrometre.dart pour la même réserve côté
/// protocole).
QualiteSignalEntity calculerQualiteSignal(SpectreBrutEntity spectre) {
  final valeurs = spectre.points.map((point) => point.absorbance).toList();
  if (valeurs.isEmpty) {
    return const QualiteSignalEntity(
      snrDb: 0,
      intensitePourcentage: 0,
      bruit: 0,
      qualiteGlobalePourcentage: 0,
    );
  }

  final moyenne = valeurs.reduce((a, b) => a + b) / valeurs.length;
  final pic = valeurs.reduce(math.max);

  // Bruit approximé par la variation moyenne point-à-point (proxy simple
  // d'un bruit haute fréquence), plutôt qu'un écart-type global qui
  // confondrait bruit et forme réelle du spectre.
  double sommeVariations = 0;
  for (var i = 1; i < valeurs.length; i++) {
    sommeVariations += (valeurs[i] - valeurs[i - 1]).abs();
  }
  final bruit = valeurs.length > 1 ? sommeVariations / (valeurs.length - 1) : 0.0;

  final snrDb = bruit > 0 ? 20 * math.log(pic.abs() / bruit) / math.ln10 : 60.0;

  // Intensité normalisée sur une amplitude d'absorbance plausible (0-1.5),
  // bornée à 100 %.
  final intensitePourcentage = ((pic - moyenne).abs() / 1.5 * 100).clamp(0, 100).toDouble();

  // Qualité globale : combinaison simple SNR + faible bruit, bornée 0-100.
  final scoreSnr = (snrDb / 40 * 100).clamp(0, 100);
  final scoreBruit = (100 - bruit / 0.05 * 100).clamp(0, 100);
  final qualiteGlobalePourcentage = ((scoreSnr + scoreBruit) / 2).toDouble();

  return QualiteSignalEntity(
    snrDb: double.parse(snrDb.toStringAsFixed(1)),
    intensitePourcentage: double.parse(intensitePourcentage.toStringAsFixed(0)),
    bruit: double.parse(bruit.toStringAsFixed(3)),
    qualiteGlobalePourcentage: double.parse(qualiteGlobalePourcentage.toStringAsFixed(0)),
  );
}
