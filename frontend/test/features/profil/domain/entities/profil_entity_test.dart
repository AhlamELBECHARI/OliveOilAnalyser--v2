import 'package:flutter_test/flutter_test.dart';
import 'package:olive_iq_app/features/profil/domain/entities/profil_entity.dart';

ProfilEntity _profil(String nom) {
  return ProfilEntity(
    id: 1,
    nom: nom,
    email: 'test@example.com',
    role: 'utilisateur',
    telephone: '',
    fonction: '',
    laboratoire: '',
    institution: '',
    dateCreation: DateTime(2026, 1, 1),
  );
}

void main() {
  group('ProfilEntity.initiales', () {
    test('prend la première lettre du premier et du dernier mot du nom', () {
      expect(_profil('Amine El Ouardi').initiales, 'AO');
    });

    test('un seul mot ne renvoie qu\'une lettre', () {
      expect(_profil('Amine').initiales, 'A');
    });

    test('espaces multiples ignorés', () {
      expect(_profil('  Amine   El Ouardi  ').initiales, 'AO');
    });

    test('nom vide renvoie un caractère de repli', () {
      expect(_profil('').initiales, '?');
    });
  });

  group('ProfilEntity.estAdministrateur', () {
    test('vrai uniquement pour le rôle administrateur', () {
      expect(_profil('Test').estAdministrateur, isFalse);
      expect(
        ProfilEntity(
          id: 2,
          nom: 'Admin',
          email: 'admin@example.com',
          role: 'administrateur',
          telephone: '',
          fonction: '',
          laboratoire: '',
          institution: '',
          dateCreation: DateTime(2026, 1, 1),
        ).estAdministrateur,
        isTrue,
      );
    });
  });
}
