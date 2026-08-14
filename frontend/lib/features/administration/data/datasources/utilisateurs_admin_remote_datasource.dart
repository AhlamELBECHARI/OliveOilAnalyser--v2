import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../../../profil/data/models/session_model.dart';
import '../models/utilisateur_admin_model.dart';

abstract class UtilisateursAdminRemoteDataSource {
  Future<({List<UtilisateurAdminModel> utilisateurs, bool aPageSuivante, int total})>
      listerUtilisateurs({
    required int page,
    String? recherche,
    String? role,
    bool? actif,
    bool? verrouille,
  });
  Future<UtilisateurAdminModel> obtenirUtilisateur(int id);
  Future<UtilisateurAdminModel> creerUtilisateur({
    required String nom,
    required String email,
    required String password,
    required String role,
  });
  Future<UtilisateurAdminModel> changerRole(int id, String role);
  Future<UtilisateurAdminModel> definirActivation(int id, bool actif);
  Future<UtilisateurAdminModel> deverrouiller(int id);
  Future<void> declencherResetMotDePasse(int id);
  Future<List<SessionModel>> listerSessions(int id);
  Future<void> revoquerSession(int utilisateurId, int sessionId);
}

class UtilisateursAdminRemoteDataSourceImpl implements UtilisateursAdminRemoteDataSource {
  final Dio dio;

  const UtilisateursAdminRemoteDataSourceImpl({required this.dio});

  @override
  Future<({List<UtilisateurAdminModel> utilisateurs, bool aPageSuivante, int total})>
      listerUtilisateurs({
    required int page,
    String? recherche,
    String? role,
    bool? actif,
    bool? verrouille,
  }) async {
    try {
      final reponse = await dio.get('/admin/utilisateurs/', queryParameters: {
        'page': page,
        if (recherche != null && recherche.isNotEmpty) 'recherche': recherche,
        if (role != null) 'role': role,
        if (actif != null) 'actif': actif.toString(),
        if (verrouille != null) 'verrouille': verrouille.toString(),
      });
      final data = reponse.data as Map<String, dynamic>;
      final utilisateurs = (data['results'] as List)
          .map((e) => UtilisateurAdminModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return (utilisateurs: utilisateurs, aPageSuivante: data['next'] != null, total: data['count'] as int);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<UtilisateurAdminModel> obtenirUtilisateur(int id) async {
    try {
      final reponse = await dio.get('/admin/utilisateurs/$id/');
      return UtilisateurAdminModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<UtilisateurAdminModel> creerUtilisateur({
    required String nom,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final reponse = await dio.post('/admin/utilisateurs/', data: {
        'nom': nom,
        'email': email,
        'password': password,
        'password2': password,
        'role': role,
      });
      return UtilisateurAdminModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<UtilisateurAdminModel> changerRole(int id, String role) async {
    try {
      final reponse = await dio.patch('/admin/utilisateurs/$id/role/', data: {'role': role});
      return UtilisateurAdminModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<UtilisateurAdminModel> definirActivation(int id, bool actif) async {
    try {
      final reponse =
          await dio.patch('/admin/utilisateurs/$id/activation/', data: {'actif': actif});
      return UtilisateurAdminModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<UtilisateurAdminModel> deverrouiller(int id) async {
    try {
      final reponse = await dio.post('/admin/utilisateurs/$id/deverrouiller/');
      return UtilisateurAdminModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<void> declencherResetMotDePasse(int id) async {
    try {
      await dio.post('/admin/utilisateurs/$id/reset-mot-de-passe/');
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<List<SessionModel>> listerSessions(int id) async {
    try {
      final reponse = await dio.get('/admin/utilisateurs/$id/sessions/');
      return (reponse.data as List).map((e) => SessionModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<void> revoquerSession(int utilisateurId, int sessionId) async {
    try {
      await dio.delete('/admin/utilisateurs/$utilisateurId/sessions/$sessionId/');
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }
}
