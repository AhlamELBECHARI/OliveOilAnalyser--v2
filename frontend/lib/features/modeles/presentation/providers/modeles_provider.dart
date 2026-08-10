import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/modele_entity.dart';
import '../../domain/usecases/creer_modele_usecase.dart';
import '../../domain/usecases/lister_modeles_usecase.dart';
import '../../domain/usecases/modifier_statut_modele_usecase.dart';
import '../../domain/usecases/televerser_fichier_modele_usecase.dart';

class ModelesState extends Equatable {
  final bool enChargement;
  final bool enregistrementEnCours;
  final Failure? echec;
  final List<ModeleEntity>? modeles;

  const ModelesState({
    this.enChargement = false,
    this.enregistrementEnCours = false,
    this.echec,
    this.modeles,
  });

  ModelesState copierAvec({
    bool? enChargement,
    bool? enregistrementEnCours,
    Failure? echec,
    List<ModeleEntity>? modeles,
    bool effacerErreur = false,
  }) {
    return ModelesState(
      enChargement: enChargement ?? this.enChargement,
      enregistrementEnCours: enregistrementEnCours ?? this.enregistrementEnCours,
      echec: effacerErreur ? null : (echec ?? this.echec),
      modeles: modeles ?? this.modeles,
    );
  }

  @override
  List<Object?> get props => [enChargement, enregistrementEnCours, echec, modeles];
}

class ModelesNotifier extends StateNotifier<ModelesState> {
  final ListerModelesUseCase _listerModelesUseCase;
  final CreerModeleUseCase _creerModeleUseCase;
  final TeleverserFichierModeleUseCase _televerserFichierUseCase;
  final ModifierStatutModeleUseCase _modifierStatutUseCase;

  ModelesNotifier(
    this._listerModelesUseCase,
    this._creerModeleUseCase,
    this._televerserFichierUseCase,
    this._modifierStatutUseCase,
  ) : super(const ModelesState()) {
    charger();
  }

  Future<void> charger() async {
    state = state.copierAvec(enChargement: true, effacerErreur: true);
    final resultat = await _listerModelesUseCase(const NoParams());
    // Voir AlertesNotifier.charger : évite "Bad state: ... after dispose"
    // si l'écran a été fermé (provider autoDispose libéré) pendant l'appel.
    if (!mounted) return;
    resultat.fold(
      (failure) => state = state.copierAvec(enChargement: false, echec: failure),
      (modeles) => state = state.copierAvec(enChargement: false, modeles: modeles),
    );
  }

  /// Crée le modèle (métadonnées) puis, si un fichier a été sélectionné,
  /// l'associe dans un second appel (PATCH multipart) : deux requêtes
  /// distinctes plutôt qu'un seul multipart, pour que `hyperparametres`
  /// (JSON imbriqué) reste correctement typé côté backend — un JSONField
  /// reçu en multipart serait stocké comme chaîne brute, pas comme objet.
  Future<bool> creerModele({
    required String nom,
    required String version,
    required String algorithme,
    required Map<String, dynamic> hyperparametres,
    required double r2,
    required double rmsecv,
    DateTime? dateEntrainement,
    String? cheminFichier,
    String? nomFichier,
  }) async {
    state = state.copierAvec(enregistrementEnCours: true, effacerErreur: true);

    final resultatCreation = await _creerModeleUseCase(CreerModeleParams(
      nom: nom,
      version: version,
      algorithme: algorithme,
      hyperparametres: hyperparametres,
      r2: r2,
      rmsecv: rmsecv,
      dateEntrainement: dateEntrainement,
    ));

    final resultat = await resultatCreation.fold<Future<Either<Failure, void>>>(
      (failure) async => Left(failure),
      (modele) async {
        if (cheminFichier == null || nomFichier == null) return const Right(null);
        final resultatFichier = await _televerserFichierUseCase(TeleverserFichierModeleParams(
          modeleId: modele.id,
          cheminFichier: cheminFichier,
          nomFichier: nomFichier,
        ));
        return resultatFichier.fold((f) => Left(f), (_) => const Right(null));
      },
    );

    if (!mounted) return false;
    final succes = resultat.isRight();
    resultat.fold(
      (failure) => state = state.copierAvec(enregistrementEnCours: false, echec: failure),
      (_) => state = state.copierAvec(enregistrementEnCours: false),
    );
    if (succes) await charger();
    return succes;
  }

  Future<bool> modifierStatut(int modeleId, {bool? estActif, bool? estDeprecie}) async {
    final resultat = await _modifierStatutUseCase(
      ModifierStatutModeleParams(modeleId: modeleId, estActif: estActif, estDeprecie: estDeprecie),
    );
    if (!mounted) return false;
    return resultat.fold(
      (failure) {
        state = state.copierAvec(echec: failure);
        return false;
      },
      (_) {
        charger();
        return true;
      },
    );
  }
}

final modelesProvider = StateNotifierProvider.autoDispose<ModelesNotifier, ModelesState>(
  (ref) => ModelesNotifier(
    sl<ListerModelesUseCase>(),
    sl<CreerModeleUseCase>(),
    sl<TeleverserFichierModeleUseCase>(),
    sl<ModifierStatutModeleUseCase>(),
  ),
);
