import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../models/profil_model.dart';
import '../models/session_model.dart';

abstract class ProfilRemoteDataSource {
  Future<ProfilModel> obtenirProfil();
  Future<ProfilModel> modifierProfil(Map<String, dynamic> champs);
  Future<ProfilModel> televerserPhoto(XFile fichier);
  Future<void> changerMotDePasse({required String ancien, required String nouveau});
  Future<List<SessionModel>> listerSessions({String? jtiCourant});
  Future<void> revoquerSession(int id);
}

class ProfilRemoteDataSourceImpl implements ProfilRemoteDataSource {
  final Dio dio;

  const ProfilRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProfilModel> obtenirProfil() async {
    try {
      final reponse = await dio.get('/utilisateurs/moi/');
      return ProfilModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<ProfilModel> modifierProfil(Map<String, dynamic> champs) async {
    try {
      final reponse = await dio.patch('/utilisateurs/moi/', data: champs);
      return ProfilModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<ProfilModel> televerserPhoto(XFile fichier) async {
    try {
      final donnees = FormData.fromMap({
        'photo_profil': await MultipartFile.fromFile(fichier.path, filename: fichier.name),
      });
      final reponse = await dio.patch('/utilisateurs/moi/', data: donnees);
      return ProfilModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<void> changerMotDePasse({required String ancien, required String nouveau}) async {
    try {
      await dio.post('/auth/changer-mot-de-passe/', data: {
        'ancien_mot_de_passe': ancien,
        'nouveau_mot_de_passe': nouveau,
      });
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<List<SessionModel>> listerSessions({String? jtiCourant}) async {
    try {
      final reponse = await dio.get(
        '/auth/sessions/',
        queryParameters: jtiCourant == null ? null : {'jti_courant': jtiCourant},
      );
      return (reponse.data as List)
          .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<void> revoquerSession(int id) async {
    try {
      await dio.delete('/auth/sessions/$id/');
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }
}
