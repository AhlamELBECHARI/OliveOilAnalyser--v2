import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/profil_entity.dart';
import '../../domain/usecases/modifier_profil_usecase.dart';
import '../../domain/usecases/obtenir_profil_usecase.dart';
import '../../domain/usecases/televerser_photo_profil_usecase.dart';

class ProfilState extends Equatable {
  final bool enChargement;
  final bool enregistrementEnCours;
  final Failure? echec;
  final ProfilEntity? profil;

  const ProfilState({
    this.enChargement = false,
    this.enregistrementEnCours = false,
    this.echec,
    this.profil,
  });

  ProfilState copierAvec({
    bool? enChargement,
    bool? enregistrementEnCours,
    Failure? echec,
    ProfilEntity? profil,
    bool effacerErreur = false,
  }) {
    return ProfilState(
      enChargement: enChargement ?? this.enChargement,
      enregistrementEnCours: enregistrementEnCours ?? this.enregistrementEnCours,
      echec: effacerErreur ? null : (echec ?? this.echec),
      profil: profil ?? this.profil,
    );
  }

  @override
  List<Object?> get props => [enChargement, enregistrementEnCours, echec, profil];
}

class ProfilNotifier extends StateNotifier<ProfilState> {
  final ObtenirProfilUseCase _obtenirProfilUseCase;
  final ModifierProfilUseCase _modifierProfilUseCase;
  final TeleverserPhotoProfilUseCase _televerserPhotoUseCase;

  ProfilNotifier(
    this._obtenirProfilUseCase,
    this._modifierProfilUseCase,
    this._televerserPhotoUseCase,
  ) : super(const ProfilState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true);
    final resultat = await _obtenirProfilUseCase(const NoParams());
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (profil) => state = state.copierAvec(enChargement: false, profil: profil),
    );
  }

  Future<Either<Failure, void>> modifierProfil(ModifierProfilParams params) async {
    state = state.copierAvec(enregistrementEnCours: true, effacerErreur: true);
    final resultat = await _modifierProfilUseCase(params);
    if (!mounted) return const Right(null);
    return resultat.fold(
      (failure) {
        state = state.copierAvec(enregistrementEnCours: false, echec: failure);
        return Left(failure);
      },
      (profil) {
        state = state.copierAvec(enregistrementEnCours: false, profil: profil);
        return const Right(null);
      },
    );
  }

  Future<Either<Failure, void>> televerserPhoto(XFile fichier) async {
    state = state.copierAvec(enregistrementEnCours: true, effacerErreur: true);
    final resultat = await _televerserPhotoUseCase(fichier);
    if (!mounted) return const Right(null);
    return resultat.fold(
      (failure) {
        state = state.copierAvec(enregistrementEnCours: false, echec: failure);
        return Left(failure);
      },
      (profil) {
        state = state.copierAvec(enregistrementEnCours: false, profil: profil);
        return const Right(null);
      },
    );
  }
}

final profilProvider = StateNotifierProvider.autoDispose<ProfilNotifier, ProfilState>(
  (ref) => ProfilNotifier(
    sl<ObtenirProfilUseCase>(),
    sl<ModifierProfilUseCase>(),
    sl<TeleverserPhotoProfilUseCase>(),
  ),
);
