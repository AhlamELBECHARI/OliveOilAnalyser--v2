import 'package:equatable/equatable.dart';

class ResultatHistoriqueEntity extends Equatable {
  final String id;
  final String numeroEchantillon;
  final String varieteEchantillon;
  final String origineEchantillon;
  final double acidite;
  final double indicePeroxyde;
  final int? dureeAnalyseSecondes;
  final DateTime dateCalcul;
  final bool conforme;
  final String commentaire;

  const ResultatHistoriqueEntity({
    required this.id,
    required this.numeroEchantillon,
    required this.varieteEchantillon,
    required this.origineEchantillon,
    required this.acidite,
    required this.indicePeroxyde,
    required this.dureeAnalyseSecondes,
    required this.dateCalcul,
    required this.conforme,
    required this.commentaire,
  });

  @override
  List<Object?> get props => [
        id,
        numeroEchantillon,
        varieteEchantillon,
        origineEchantillon,
        acidite,
        indicePeroxyde,
        dureeAnalyseSecondes,
        dateCalcul,
        conforme,
        commentaire,
      ];
}
