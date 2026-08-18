import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/local/mode_simulateur_datasource.dart';

/// Interrupteur "Mode simulateur" (Paramètres) : lit/écrit directement
/// [ModeSimulateurDataSource] (persisté localement), seul lu par
/// AnalyseurRepositoryRouter pour choisir entre le simulateur et le
/// Bluetooth réel — jamais de logique de bascule dans la Presentation.
class ModeSimulateurNotifier extends StateNotifier<bool> {
  ModeSimulateurNotifier() : super(sl<ModeSimulateurDataSource>().estActif());

  Future<void> definir(bool actif) async {
    state = actif;
    await sl<ModeSimulateurDataSource>().definir(actif);
  }
}

final modeSimulateurProvider = StateNotifierProvider.autoDispose<ModeSimulateurNotifier, bool>(
  (ref) => ModeSimulateurNotifier(),
);
