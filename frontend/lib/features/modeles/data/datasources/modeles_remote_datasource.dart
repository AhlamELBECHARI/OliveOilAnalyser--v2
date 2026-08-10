import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../models/modele_model.dart';

abstract class ModelesRemoteDataSource {
  Future<List<ModeleModel>> listerModeles();

  Future<ModeleModel> creerModele({
    required String nom,
    required String version,
    required String algorithme,
    required Map<String, dynamic> hyperparametres,
    required double r2,
    required double rmsecv,
    DateTime? dateEntrainement,
  });

  Future<ModeleModel> televerserFichierModele({
    required int modeleId,
    required String cheminFichier,
    required String nomFichier,
  });

  Future<ModeleModel> modifierStatutModele({
    required int modeleId,
    bool? estActif,
    bool? estDeprecie,
  });
}

class ModelesRemoteDataSourceImpl implements ModelesRemoteDataSource {
  final Dio dio;

  const ModelesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ModeleModel>> listerModeles() async {
    try {
      final reponse = await dio.get('/modeles/');
      final resultats = (reponse.data as Map<String, dynamic>)['results'] as List;
      return resultats.map((e) => ModeleModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<ModeleModel> creerModele({
    required String nom,
    required String version,
    required String algorithme,
    required Map<String, dynamic> hyperparametres,
    required double r2,
    required double rmsecv,
    DateTime? dateEntrainement,
  }) async {
    try {
      final reponse = await dio.post('/modeles/', data: {
        'nom': nom,
        'version': version,
        'algorithme': algorithme,
        'hyperparametres': hyperparametres,
        'r2': r2,
        'rmsecv': rmsecv,
        if (dateEntrainement != null) 'date_entrainement': dateEntrainement.toIso8601String(),
      });
      return ModeleModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<ModeleModel> televerserFichierModele({
    required int modeleId,
    required String cheminFichier,
    required String nomFichier,
  }) async {
    try {
      final donnees = FormData.fromMap({
        'fichier': await MultipartFile.fromFile(cheminFichier, filename: nomFichier),
      });
      final reponse = await dio.patch('/modeles/$modeleId/', data: donnees);
      return ModeleModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<ModeleModel> modifierStatutModele({
    required int modeleId,
    bool? estActif,
    bool? estDeprecie,
  }) async {
    try {
      final reponse = await dio.patch('/modeles/$modeleId/', data: {
        if (estActif != null) 'est_actif': estActif,
        if (estDeprecie != null) 'est_deprecie': estDeprecie,
      });
      return ModeleModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }
}
