import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vrai lorsque l'utilisateur est entré dans l'application via le bouton
/// "Mode démo" : dans cet état, aucun appel API ne doit jamais être déclenché.
///
/// Isolé dans core/demo/ (voir demo_fake_data.dart) pour suppression facile.
final demoModeProvider = StateProvider<bool>((ref) => false);
