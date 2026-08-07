import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/build_context_l10n_extension.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/carte_stylisee.dart';
import '../../domain/entities/session_entity.dart';
import '../providers/sessions_provider.dart';

/// Sous-écran "Sessions actives" — liste les OutstandingToken valides de
/// l'utilisateur (GET /api/auth/sessions/) et permet de révoquer une
/// session ou toutes sauf la courante (DELETE /api/auth/sessions/<id>/).
class SessionsActivesScreen extends ConsumerWidget {
  const SessionsActivesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(sessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: AppColors.fond,
        elevation: 0,
        title: Text(l10n.sessionsActivesTitre, style: AppTextStyles.bienvenue.copyWith(fontSize: 18)),
      ),
      body: _corps(context, ref, state),
    );
  }

  Widget _corps(BuildContext context, WidgetRef ref, SessionsState state) {
    final l10n = context.l10n;

    if (state.sessions == null && state.enChargement) {
      return const Center(child: CircularProgressIndicator(color: AppColors.vertOlive));
    }

    if (state.sessions == null && state.echec != null) {
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
                onPressed: () => ref.read(sessionsProvider.notifier).charger(),
                child: Text(l10n.reessayer, style: AppTextStyles.boutonPrincipal),
              ),
            ],
          ),
        ),
      );
    }

    final sessions = state.sessions ?? const [];
    final aDesAutres = sessions.any((session) => !session.estCourante);

    return RefreshIndicator(
      color: AppColors.vertOlive,
      onRefresh: () => ref.read(sessionsProvider.notifier).charger(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text(l10n.aucuneSessionMessage, style: AppTextStyles.sousTexteBienvenue)),
            )
          else ...[
            for (final session in sessions) ...[
              _CarteSession(
                session: session,
                enCoursDeRevocation: state.enCoursDeRevocation.contains(session.id),
                onRevoquer: () => ref.read(sessionsProvider.notifier).revoquer(session.id),
              ),
              const SizedBox(height: 12),
            ],
            if (aDesAutres) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.erreur),
                    foregroundColor: AppColors.erreur,
                  ),
                  onPressed: () => ref.read(sessionsProvider.notifier).revoquerToutesSaufCourante(),
                  child: Text(l10n.revoquerToutesSaufCouranteBouton),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _CarteSession extends StatelessWidget {
  final SessionEntity session;
  final bool enCoursDeRevocation;
  final VoidCallback onRevoquer;

  const _CarteSession({
    required this.session,
    required this.enCoursDeRevocation,
    required this.onRevoquer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatDate = DateFormat.yMd(l10n.localeName).add_Hm();

    return CarteStylisee(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: session.estCourante ? AppColors.evooFond : AppColors.fond,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smartphone,
              color: session.estCourante ? AppColors.vertOliveFonce : AppColors.grisMoyen,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (session.estCourante) ...[
                      Text(
                        l10n.sessionCouranteLabel,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.vertOliveFonce),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        l10n.sessionCreeeLabel(formatDate.format(session.dateCreation)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grisFonce),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.sessionExpireLabel(formatDate.format(session.dateExpiration)),
                  style: AppTextStyles.sousTexteBienvenue.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          if (!session.estCourante)
            enCoursDeRevocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.erreur),
                  )
                : TextButton(
                    onPressed: onRevoquer,
                    child: Text(l10n.revoquerSessionBouton, style: const TextStyle(color: AppColors.erreur)),
                  ),
        ],
      ),
    );
  }
}
