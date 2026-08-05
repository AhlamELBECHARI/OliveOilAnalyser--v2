import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vrai lorsque la session en cours a été ouverte via le bouton "Mode démo"
/// de l'écran de connexion, plutôt qu'avec des identifiants saisis à la
/// main. Purement cosmétique (bannière "Mode démo", libellé du bouton de
/// déconnexion dans Paramètres) : dans les deux cas, la session est une
/// vraie connexion JWT et l'application appelle les mêmes API réelles.
///
/// Isolé dans core/demo/ pour suppression facile le jour où le mode démo
/// sera retiré.
final demoModeProvider = StateProvider<bool>((ref) => false);
