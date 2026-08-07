import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profil_entity.dart';
import '../repositories/profil_repository.dart';

class TeleverserPhotoProfilUseCase implements UseCase<ProfilEntity, XFile> {
  final ProfilRepository repository;

  const TeleverserPhotoProfilUseCase(this.repository);

  @override
  Future<Either<Failure, ProfilEntity>> call(XFile params) {
    return repository.televerserPhoto(params);
  }
}
