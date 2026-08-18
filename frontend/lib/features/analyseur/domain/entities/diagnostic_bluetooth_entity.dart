import 'package:equatable/equatable.dart';

enum EtatAdaptateurBluetooth { actif, inactif, inconnu }

enum EtatPermission { accordee, refusee, refuseeDefinitivement }

/// Permissions pertinentes pour la découverte/connexion Bluetooth Classic —
/// voir AndroidManifest.xml. [localisation] n'est réellement EXIGÉE que sur
/// Android 11 et antérieur (voir DiagnosticBluetoothEntity.localisationRequise) ;
/// elle est tout de même toujours diagnostiquée, car sa valeur reste
/// informative même quand elle n'est pas bloquante.
enum PermissionBluetooth { bluetoothScan, bluetoothConnect, localisation }

class PermissionDiagnostiquee extends Equatable {
  final PermissionBluetooth type;
  final EtatPermission etat;

  const PermissionDiagnostiquee({required this.type, required this.etat});

  @override
  List<Object?> get props => [type, etat];
}

/// Photographie complète de l'état Bluetooth au moment de l'appel — alimente
/// l'écran de diagnostic (cahier des charges, section 5) : jamais besoin de
/// lire les journaux pour comprendre pourquoi aucun appareil n'apparaît.
class DiagnosticBluetoothEntity extends Equatable {
  final EtatAdaptateurBluetooth etatAdaptateur;
  final List<PermissionDiagnostiquee> permissions;
  final bool serviceLocalisationActif;

  /// Vrai uniquement sur Android 11 (API 30) et antérieur — sur Android 12+,
  /// la découverte Bluetooth Classic ne dépend plus du service de
  /// localisation (voir android:usesPermissionFlags="neverForLocation" dans
  /// le manifeste).
  final bool localisationRequise;

  final int nombreAppareilsClassicDetectes;
  final DateTime? dateDernierBalayage;

  const DiagnosticBluetoothEntity({
    required this.etatAdaptateur,
    required this.permissions,
    required this.serviceLocalisationActif,
    required this.localisationRequise,
    required this.nombreAppareilsClassicDetectes,
    this.dateDernierBalayage,
  });

  bool get toutEstOperationnel =>
      etatAdaptateur == EtatAdaptateurBluetooth.actif &&
      permissions.every((p) => p.etat == EtatPermission.accordee) &&
      (!localisationRequise || serviceLocalisationActif);

  @override
  List<Object?> get props => [
        etatAdaptateur,
        permissions,
        serviceLocalisationActif,
        localisationRequise,
        nombreAppareilsClassicDetectes,
        dateDernierBalayage,
      ];
}
