import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> demanderResetMotDePasse({required String email});
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
      throw _traduireErreur(e);
    }
  }

  @override
  Future<void> demanderResetMotDePasse({required String email}) async {
    try {
      await dio.post('/auth/reset-password/', data: {'email': email});
    } on DioException catch (e) {
      throw _traduireErreur(e);
    }
  }

  /// Le backend renvoie 401 aussi bien pour des identifiants invalides que
  /// pour un compte verrouillé (voir comptes/services.py::login) : le seul
  /// moyen de les distinguer est le texte du champ "detail".
  Exception _traduireErreur(DioException e) {
    final statusCode = e.response?.statusCode;

    if (statusCode == 401) {
      final detail = _extraireDetail(e.response?.data);
      if (detail != null && detail.toLowerCase().contains('verrouill')) {
        return const CompteVerrouilleException();
      }
      return const IdentifiantsInvalidesException();
    }

    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return ErreurValidationException(
        _extraireDetail(e.response?.data) ?? 'Requête invalide.',
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return const ErreurServeurException();
    }

    return const ErreurReseauException();
  }

  String? _extraireDetail(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) return detail;

      for (final valeur in data.values) {
        if (valeur is List && valeur.isNotEmpty) {
          return valeur.first.toString();
        }
        if (valeur is String) return valeur;
      }
    }
    return null;
  }
}
