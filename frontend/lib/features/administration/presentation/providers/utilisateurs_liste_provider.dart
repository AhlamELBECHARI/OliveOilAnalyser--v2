import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/utilisateur_admin_entity.dart';
import '../../domain/usecases/lister_utilisateurs_admin_usecase.dart';

class FiltresUtilisateursAdmin extends Equatable {
  final String? recherche;
  final String? role;
  final bool? actif;
  final bool? verrouille;

  const FiltresUtilisateursAdmin({this.recherche, this.role, this.actif, this.verrouille});

  bool get estVide => recherche == null && role == null && actif == null && verrouille == null;

  @override
  List<Object?> get props => [recherche, role, actif, verrouille];
}

class UtilisateursListeState extends Equatable {
  final bool enChargement;
  final bool chargementPageSuivante;
  final Failure? echec;
  final List<UtilisateurAdminEntity>? utilisateurs;
  final bool aPageSuivante;
  final int page;
  final FiltresUtilisateursAdmin filtres;

  const UtilisateursListeState({
    this.enChargement = false,
    this.chargementPageSuivante = false,
    this.echec,
    this.utilisateurs,
    this.aPageSuivante = false,
    this.page = 1,
    this.filtres = const FiltresUtilisateursAdmin(),
  });

  UtilisateursListeState copierAvec({
    bool? enChargement,
    bool? chargementPageSuivante,
    Failure? echec,
    List<UtilisateurAdminEntity>? utilisateurs,
    bool? aPageSuivante,
    int? page,
    FiltresUtilisateursAdmin? filtres,
    bool effacerErreur = false,
  }) {
    return UtilisateursListeState(
      enChargement: enChargement ?? this.enChargement,
      chargementPageSuivante: chargementPageSuivante ?? this.chargementPageSuivante,
      echec: effacerErreur ? null : (echec ?? this.echec),
      utilisateurs: utilisateurs ?? this.utilisateurs,
      aPageSuivante: aPageSuivante ?? this.aPageSuivante,
      page: page ?? this.page,
      filtres: filtres ?? this.filtres,
    );
  }

  @override
  List<Object?> get props =>
      [enChargement, chargementPageSuivante, echec, utilisateurs, aPageSuivante, page, filtres];
}

class UtilisateursListeNotifier extends StateNotifier<UtilisateursListeState> {
  final ListerUtilisateursAdminUseCase _listerUtilisateurs;

  UtilisateursListeNotifier(this._listerUtilisateurs) : super(const UtilisateursListeState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true, page: 1);
    final resultat = await _listerUtilisateurs(ListerUtilisateursAdminParams(
      page: 1,
      recherche: state.filtres.recherche,
      role: state.filtres.role,
      actif: state.filtres.actif,
      verrouille: state.filtres.verrouille,
    ));
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (page) => state = state.copierAvec(
        enChargement: false,
        utilisateurs: page.utilisateurs,
        aPageSuivante: page.aPageSuivante,
      ),
    );
  }

  Future<void> chargerPageSuivante() async {
    if (!state.aPageSuivante || state.chargementPageSuivante) return;
    state = state.copierAvec(chargementPageSuivante: true);
    final pageSuivante = state.page + 1;
    final resultat = await _listerUtilisateurs(ListerUtilisateursAdminParams(
      page: pageSuivante,
      recherche: state.filtres.recherche,
      role: state.filtres.role,
      actif: state.filtres.actif,
      verrouille: state.filtres.verrouille,
    ));
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(chargementPageSuivante: false, echec: failure),
      (page) => state = state.copierAvec(
        chargementPageSuivante: false,
        page: pageSuivante,
        utilisateurs: [...?state.utilisateurs, ...page.utilisateurs],
        aPageSuivante: page.aPageSuivante,
      ),
    );
  }

  void appliquerFiltres(FiltresUtilisateursAdmin filtres) {
    state = state.copierAvec(filtres: filtres);
    charger();
  }
}

final utilisateursListeProvider =
    StateNotifierProvider.autoDispose<UtilisateursListeNotifier, UtilisateursListeState>(
  (ref) => UtilisateursListeNotifier(sl<ListerUtilisateursAdminUseCase>()),
);
