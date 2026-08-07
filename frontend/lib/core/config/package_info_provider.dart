import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Version et numéro de build RÉELS de l'app (Partie B, "À propos
/// d'OliveIQ"), lus dynamiquement — jamais écrits en dur dans un widget.
final packageInfoProvider = FutureProvider.autoDispose<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});
