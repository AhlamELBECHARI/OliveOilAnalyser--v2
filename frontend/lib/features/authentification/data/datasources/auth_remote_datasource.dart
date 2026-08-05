import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> demanderResetMotDePasse({required String email});

  Future<void> verifierCodeReset({required String email, required String code});

  Future<void> confirmerResetMotDePasse({
    required String email,
    required String code,
    required String nouveauMotDePasse,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  const AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final reponse = await dio.post(
        '/auth/login/',
        data: {'email': email, 'password': password},
      );
      return LoginResponseModel.fromJson(reponse.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<void> demanderResetMotDePasse({required String email}) async {
    try {
      await dio.post('/auth/reset-password/', data: {'email': email});
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<void> verifierCodeReset({
    required String email,
    required String code,
  }) async {
    try {
      await dio.post(
        '/auth/reset-password/verify/',
        data: {'email': email, 'code': code},
      );
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }

  @override
  Future<void> confirmerResetMotDePasse({
    required String email,
    required String code,
    required String nouveauMotDePasse,
  }) async {
    try {
      await dio.post(
        '/auth/reset-password/confirm/',
        data: {
          'email': email,
          'code': code,
          'nouveau_mot_de_passe': nouveauMotDePasse,
        },
      );
    } on DioException catch (e) {
      throw traduireDioException(e);
    }
  }
}
