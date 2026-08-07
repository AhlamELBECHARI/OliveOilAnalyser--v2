import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failures.dart';
import '../entities/profil_entity.dart';
import '../entities/session_entity.dart';

abstract class ProfilRepository {
  Future<Either<Failure, ProfilEntity>> obtenirProfil();

  Future<Either<Failure, ProfilEntity>> modifierProfil({
    String? nom,
    String? telephone,
    String? fonction,
    String? laboratoire,
    String? institution,
  });

  Future<Either<Failure, ProfilEntity>> televerserPhoto(XFile fichier);

  Future<Either<Failure, void>> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  });

  Future<Either<Failure, List<SessionEntity>>> listerSessions();

  Future<Either<Failure, void>> revoquerSession(int id);
}
