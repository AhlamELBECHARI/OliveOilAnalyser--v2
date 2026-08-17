import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/raison_message_login.dart';
import '../../domain/usecases/consommer_raison_message_login_usecase.dart';

/// Message informatif à afficher une seule fois sur l'écran de connexion
/// (session hors ligne expirée après 30 jours, déconnexion volontaire hors
/// ligne...) — lu puis effacé localement au premier affichage, jamais
/// reproposé après (voir ConsommerRaisonMessageLoginUseCase).
final raisonMessageLoginProvider = FutureProvider.autoDispose<RaisonMessageLogin>((ref) async {
  final resultat = await sl<ConsommerRaisonMessageLoginUseCase>()(const NoParams());
  return resultat.fold((_) => RaisonMessageLogin.aucune, (valeur) => valeur);
});
