import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/analyse_historique_entity.dart';

/// Barre de recherche (débouncée) + chips de filtre rapide de
/// design/4-historiques.png. Aucun filtrage local : chaque changement
/// remonte vers HistoriqueNotifier.appliquerFiltres, qui relance la requête
/// serveur (voir analyses.services.rechercher_historique).
class BarreRechercheFiltres extends StatefulWidget {
  final FiltresHistorique filtres;
  final ValueChanged<FiltresHistorique> onChangerFiltres;
  final VoidCallback onOuvrirPlusDeFiltres;

  const BarreRechercheFiltres({
    super.key,
    required this.filtres,
    required this.onChangerFiltres,
    required this.onOuvrirPlusDeFiltres,
  });

  @override
  State<BarreRechercheFiltres> createState() => _BarreRechercheFiltresState();
}

class _BarreRechercheFiltresState extends State<BarreRechercheFiltres> {
  late final TextEditingController _controleur;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controleur = TextEditingController(text: widget.filtres.recherche ?? '');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controleur.dispose();
    super.dispose();
  }

  void _onChangerRecherche(String valeur) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onChangerFiltres(widget.filtres.copierAvec(recherche: valeur));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controleur,
          onChanged: _onChangerRecherche,
          decoration: InputDecoration(
            hintText: l10n.rechercherPlaceholder,
            prefixIcon: const Icon(Icons.search, color: AppColors.grisMoyen),
            filled: true,
            fillColor: AppColors.blanc,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grisLigne),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _Chip(
                libelle: l10n.filtreTout,
                actif: widget.filtres.estVide,
                onTap: () => widget.onChangerFiltres(const FiltresHistorique()),
              ),
              const SizedBox(width: 8),
              _Chip(
                libelle: l10n.filtreQualite,
                actif: widget.filtres.qualite != null,
                onTap: widget.onOuvrirPlusDeFiltres,
              ),
              const SizedBox(width: 8),
              _Chip(
                libelle: l10n.filtreVariete,
                actif: (widget.filtres.variete ?? '').isNotEmpty,
                onTap: widget.onOuvrirPlusDeFiltres,
              ),
              const SizedBox(width: 8),
              _Chip(
                libelle: l10n.filtreRegion,
                actif: (widget.filtres.region ?? '').isNotEmpty,
                onTap: widget.onOuvrirPlusDeFiltres,
              ),
              const SizedBox(width: 8),
              _Chip(
                libelle: l10n.filtrePlus,
                actif: widget.filtres.dateDebut != null || widget.filtres.dateFin != null,
                icone: Icons.tune,
                onTap: widget.onOuvrirPlusDeFiltres,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String libelle;
  final bool actif;
  final IconData? icone;
  final VoidCallback onTap;

  const _Chip({required this.libelle, required this.actif, this.icone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: actif ? AppColors.vertOlive : AppColors.blanc,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: actif ? AppColors.vertOlive : AppColors.grisLigne),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[
              Icon(icone, size: 14, color: actif ? AppColors.blanc : AppColors.grisMoyen),
              const SizedBox(width: 4),
            ],
            Text(
              libelle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: actif ? AppColors.blanc : AppColors.grisFonce,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
