import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/journal_audit_entity.dart';
import '../providers/journal_audit_provider.dart';

/// Historique des actions sensibles (voir administration.models.JournalAudit
/// côté backend) — connexions, changements de rôle, activation/désactivation
/// de comptes, modifications de configuration, purges...
class JournalAuditScreen extends ConsumerStatefulWidget {
  const JournalAuditScreen({super.key});

  @override
  ConsumerState<JournalAuditScreen> createState() => _JournalAuditScreenState();
}

class _JournalAuditScreenState extends ConsumerState<JournalAuditScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(journalAuditProvider.notifier).chargerPageSuivante();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(journalAuditProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.journalAuditTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
      ),
      body: _corps(context, state),
    );
  }

  Widget _corps(BuildContext context, JournalAuditState state) {
    final l10n = context.l10n;

    if (state.entrees == null && state.enChargement) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.entrees == null && state.echec != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.grisMoyen),
              const SizedBox(height: 16),
              Text(
                state.echec!.messageLocalise(context),
                textAlign: TextAlign.center,
                style: AppTextStyles.sousTexteBienvenue,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.vertOlive),
                onPressed: () => ref.read(journalAuditProvider.notifier).charger(),
                child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
              ),
            ],
          ),
        ),
      );
    }

    final entrees = state.entrees ?? const [];
    if (entrees.isEmpty) {
      return Center(child: Text(l10n.aucuneEntreeJournalTexte, style: AppTextStyles.sousTexteBienvenue));
    }

    return RefreshIndicator(
      color: AppColors.vertOlive,
      onRefresh: () => ref.read(journalAuditProvider.notifier).charger(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: entrees.length + (state.chargementPageSuivante ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= entrees.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(color: AppColors.vertOlive)),
            );
          }
          return _LigneEntree(entree: entrees[index]);
        },
      ),
    );
  }
}

class _LigneEntree extends StatelessWidget {
  final JournalAuditEntity entree;

  const _LigneEntree({required this.entree});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatDate = DateFormat.yMd(l10n.localeName).add_Hms();

    return CarteStylisee(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.history, size: 18, color: AppColors.grisMoyen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entree.actionLibelle,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                ),
                if (entree.acteurNom != null)
                  Text(
                    entree.acteurNom!,
                    style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                  ),
                const SizedBox(height: 2),
                Text(
                  formatDate.format(entree.dateCreation),
                  style: const TextStyle(fontSize: 11, color: AppColors.grisMoyen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
