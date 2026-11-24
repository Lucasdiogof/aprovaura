import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/auth/l10n/email_verification_strings.dart';
import 'package:aura/features/partners/domain/entities/partner.dart';
import 'package:aura/features/partners/domain/repositories/partners_repository.dart';
import 'package:aura/features/partners/l10n/partner_strings.dart';
import 'package:aura/features/partners/presentation/cubit/partner_link_cubit.dart';
import 'package:aura/features/partners/presentation/cubit/partner_picker_cubit.dart';
import 'package:aura/features/partners/presentation/widgets/partner_picker_sheet.dart';
import 'package:aura/features/profile/presentation/widgets/settings_tile.dart';

/// Profile row for the referring teacher: first self-link if never linked,
/// then the linked teacher, with a one-at-a-time change request.
class PartnerLinkTile extends StatefulWidget {
  const PartnerLinkTile({super.key});

  @override
  State<PartnerLinkTile> createState() => _PartnerLinkTileState();
}

class _PartnerLinkTileState extends State<PartnerLinkTile> {
  late final _link = PartnerLinkCubit(sl<PartnersRepository>())..load();
  late final _picker = PartnerPickerCubit(sl<PartnersRepository>())..load();

  @override
  void dispose() {
    _link.close();
    _picker.close();
    super.dispose();
  }

  Future<void> _onTap(PartnerLink link, PartnerStrings p) async {
    final language = context.read<LocaleCubit>().state;
    if (link.hasPendingChange) {
      await _info(p.pendingDescription, p);
      return;
    }
    final picked = await showPartnerPickerSheet(
      context,
      cubit: _picker,
      strings: EmailVerificationStrings(language),
      allowNone: false,
    );
    final partner = picked?.partner;
    if (partner == null || !mounted) return;
    if (link.canSelfLink) {
      final ok = await _confirm(p, p.chooseDescription, p.confirmLink, null);
      if (ok == null || !mounted) return;
      _toast(await _link.linkTo(partner.id) ? p.linkedOk : p.failed);
    } else {
      final reason = TextEditingController();
      final ok = await _confirm(p, p.changeNote, p.sendRequest, reason);
      final text = reason.text.trim();
      reason.dispose();
      if (ok == null || !mounted) return;
      _toast(
        await _link.requestChange(partner.id, text.isEmpty ? null : text)
            ? p.requestedOk
            : p.failed,
      );
    }
  }

  Future<bool?> _confirm(
    PartnerStrings p,
    String text,
    String action,
    TextEditingController? reason,
  ) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(p.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          if (reason != null) ...[
            const SizedBox(height: 12),
            TextField(
              controller: reason,
              maxLength: 300,
              decoration: InputDecoration(labelText: p.reasonLabel),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );

  Future<void> _info(String text, PartnerStrings p) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(p.title),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
        ),
      ],
    ),
  );

  void _toast(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final p = PartnerStrings(context.watch<LocaleCubit>().state);
    return BlocBuilder<PartnerLinkCubit, PartnerLinkState>(
      bloc: _link,
      builder: (context, ls) {
        return BlocBuilder<PartnerPickerCubit, PartnerPickerState>(
          bloc: _picker,
          builder: (context, ps) {
            final link = ls.link;
            // Nothing to show: no link yet and no active teacher to pick.
            if (link == null || (!link.isLinked && ps.anyPartner != true)) {
              return const SizedBox.shrink();
            }
            // Already chose once and nobody else is available: still shows
            // the linked teacher, just without the pending/change prompt.
            final subtitle = link.hasPendingChange
                ? p.pendingChange
                : (link.displayName ?? p.notLinked);
            return SettingsTile(
              icon: Icons.school_outlined,
              title: p.tileTitle,
              subtitle: subtitle,
              trailing: ls.busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: ls.busy ? null : () => _onTap(link, p),
            );
          },
        );
      },
    );
  }
}
