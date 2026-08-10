import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Enregistre des octets déjà téléchargés dans un fichier choisi par
/// l'utilisateur. Sur mobile, `FilePicker.saveFile` écrit directement les
/// `bytes` fournis ; sur desktop (Windows/Linux/macOS), il ne fait
/// qu'ouvrir la boîte de dialogue et renvoyer le chemin choisi — c'est à
/// l'appelant d'y écrire les octets, d'où l'écriture manuelle ci-dessous.
class TelechargeurFichier {
  const TelechargeurFichier._();

  /// Renvoie `true` si le fichier a bien été enregistré, `false` si
  /// l'utilisateur a annulé la boîte de dialogue.
  static Future<bool> enregistrer({
    required String nomFichier,
    required List<int> octets,
  }) async {
    final octetsTypes = Uint8List.fromList(octets);
    final chemin = await FilePicker.platform.saveFile(
      fileName: nomFichier,
      bytes: octetsTypes,
    );
    if (chemin == null) return false;

    final estBureau = !Platform.isAndroid && !Platform.isIOS;
    if (estBureau) {
      final fichier = File(chemin);
      if (!(await fichier.exists()) || await fichier.length() == 0) {
        await fichier.writeAsBytes(octetsTypes);
      }
    }
    return true;
  }
}
