import 'dart:typed_data';

import '../../domain/entities/commande_analyseur.dart';
import '../../domain/entities/spectre_entity.dart';

/// ============================================================================
/// PROTOCOLE DU SPECTROMÈTRE — À CORRIGER DÈS RÉCEPTION DE LA DOCUMENTATION
/// CONSTRUCTEUR.
///
/// Tout ce fichier repose sur des hypothèses raisonnables mais NON
/// vérifiées (nom de l'appareil, trames binaires, délimiteurs, ordre des
/// octets). Il isole volontairement ces hypothèses ici, dans un seul
/// fichier clairement identifié, pour qu'une correction future (une fois
/// le protocole réel documenté) ne touche qu'à ce fichier — jamais
/// analyseur_bluetooth_impl.dart, ni a fortiori le Domain ou l'UI.
/// ============================================================================

// --- Identification de l'appareil (connexion automatique) ---

/// Nom Bluetooth attendu de l'appareil déjà appairé. La connexion
/// automatique (voir AnalyseurBluetoothImpl.connecterAutomatiquement)
/// recherche ce nom parmi les appareils appairés du téléphone — jamais une
/// liste affichée à l'utilisateur.
const String nomAppareilAttendu = 'UM6P-Spectrometer-01';

/// UUID du service SPP (Serial Port Profile) standard. Valeur standard
/// Bluetooth Classic, à conserver sauf indication contraire du fabricant.
const String uuidServiceSpp = '00001101-0000-1000-8000-00805F9B34FB';

// --- Trames de commande (hypothétiques) ---

/// Chaque commande est envoyée comme une ligne ASCII terminée par
/// [suffixeTrame]. Hypothèse la plus simple/courante pour du SPP série ; à
/// remplacer par le format binaire réel si le fabricant en impose un.
const String suffixeTrame = '\r\n';

String _encoderCommandeTexte(String commande) => '$commande$suffixeTrame';

/// Traduit une [CommandeAnalyseur] du Domain (protocole-agnostique) en
/// octets à écrire sur le port série SPP.
Uint8List encoderCommande(CommandeAnalyseur commande) {
  final texte = switch (commande) {
    CommandeAnalyseur.demarrerAcquisition => _encoderCommandeTexte('START_SCAN'),
    CommandeAnalyseur.annulerAcquisition => _encoderCommandeTexte('CANCEL'),
  };
  return Uint8List.fromList(texte.codeUnits);
}

/// Commande envoyée pour demander les informations de l'appareil (nom,
/// numéro de série, firmware, batterie). Réponse attendue : une ligne
/// "INFO,<numeroSerie>,<firmware>,<batterie>".
Uint8List encoderCommandeInfoAppareil() => Uint8List.fromList(_encoderCommandeTexte('GET_INFO').codeUnits);

// --- Parsing du flux binaire entrant ---

/// Préfixe attendu d'une ligne contenant un point de spectre :
/// "SPEC,<longueurOndeNm>,<absorbance>". Hypothèse : le point est envoyé
/// au fur et à mesure de l'acquisition (permet le rendu "temps réel" côté
/// AnalyseurRepository.flusSpectre) plutôt qu'un unique bloc final.
const String prefixeLignePoint = 'SPEC,';

/// Ligne signalant la fin d'un scan : "SPEC_END".
const String ligneFinScan = 'SPEC_END';

/// Tampon accumulant les octets reçus jusqu'à trouver [suffixeTrame], pour
/// gérer le cas où une trame arrive découpée sur plusieurs paquets
/// Bluetooth (comportement courant du SPP).
class TamponTrames {
  final StringBuffer _tampon = StringBuffer();

  /// Ajoute des octets reçus et renvoie la liste des lignes complètes
  /// désormais disponibles (peut être vide si la trame n'est pas terminée).
  List<String> ajouter(Uint8List octets) {
    _tampon.write(String.fromCharCodes(octets));
    final contenu = _tampon.toString();
    final lignes = contenu.split(suffixeTrame);
    if (lignes.isEmpty) return const [];

    // Le dernier élément est soit vide (trame complète), soit un reste
    // partiel à conserver pour le prochain paquet.
    final reste = lignes.removeLast();
    _tampon
      ..clear()
      ..write(reste);
    return lignes.where((ligne) => ligne.isNotEmpty).toList();
  }
}

/// Parse une ligne "SPEC,<longueurOndeNm>,<absorbance>" en [PointSpectreEntity].
/// Renvoie `null` si la ligne ne correspond pas au format attendu (ligne de
/// contrôle, trame corrompue...) plutôt que de lever une exception —
/// l'appelant journalise et ignore.
PointSpectreEntity? parserLignePoint(String ligne) {
  if (!ligne.startsWith(prefixeLignePoint)) return null;
  final valeurs = ligne.substring(prefixeLignePoint.length).split(',');
  if (valeurs.length != 2) return null;

  final longueurOnde = double.tryParse(valeurs[0]);
  final absorbance = double.tryParse(valeurs[1]);
  if (longueurOnde == null || absorbance == null) return null;

  return PointSpectreEntity(longueurOndeNm: longueurOnde, absorbance: absorbance);
}

/// Parse une ligne "INFO,<numeroSerie>,<firmware>,<batterie>". Renvoie
/// `null` si le format ne correspond pas.
({String numeroSerie, String firmware, int? batterie})? parserLigneInfo(String ligne) {
  if (!ligne.startsWith('INFO,')) return null;
  final valeurs = ligne.substring('INFO,'.length).split(',');
  if (valeurs.length != 3) return null;

  return (
    numeroSerie: valeurs[0],
    firmware: valeurs[1],
    batterie: int.tryParse(valeurs[2]),
  );
}
