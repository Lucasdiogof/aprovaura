import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aura/features/auth/domain/entities/legal_document.dart';
import 'package:aura/features/auth/l10n/email_verification_strings.dart';
import 'package:aura/features/auth/presentation/widgets/auth_palette.dart';
import 'package:aura/features/partners/presentation/cubit/partner_picker_cubit.dart';
import 'package:aura/features/partners/presentation/widgets/partner_picker_sheet.dart';

/// Sign-up extras under the password fields: the "which teacher referred you"
/// picker (hidden while no teacher is active) and the legal acceptance line
/// (hidden while no legal document is published).
class RegisterExtras extends StatelessWidget {
  const RegisterExtras({
    required this.strings,
    required this.picker,
    required this.legalDocs,
    required this.legalAccepted,
    required this.onLegalChanged,
    required this.showLegalError,
    super.key,
  });

  final EmailVerificationStrings strings;
  final PartnerPickerCubit picker;
  final List<LegalDocument> legalDocs;
  final bool legalAccepted;
  final ValueChanged<bool> onLegalChanged;
  final bool showLegalError;

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final palette = AuthPalette.of(context);
    return BlocBuilder<PartnerPickerCubit, PartnerPickerState>(
      bloc: picker,
      builder: (context, s) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (s.anyPartner == true) ...[
              Text(
                strings.referralLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.label,
                ),
              ),
              const SizedBox(height: 6),
              Semantics(
                button: true,
                label: strings.referralLabel,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final result = await showPartnerPickerSheet(
                      context,
                      cubit: picker,
                      strings: strings,
                      allowNone: true,
                    );
                    if (result != null) picker.select(result.partner);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: palette.cardBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.selected?.displayName ?? strings.referralNone,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: palette.label),
                          ),
                        ),
                        Icon(
                          Icons.unfold_more_rounded,
                          color: palette.subtitle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (legalDocs.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: legalAccepted,
                    onChanged: (v) => onLegalChanged(v ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            legalDocs.length > 1
                                ? strings.legalPrefixPlural
                                : strings.legalPrefix,
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.subtitle,
                            ),
                          ),
                          for (var i = 0; i < legalDocs.length; i++) ...[
                            if (i > 0)
                              Text(
                                strings.legalAnd,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: palette.subtitle,
                                ),
                              ),
                            InkWell(
                              onTap: () => _open(legalDocs[i].url),
                              child: Text(
                                strings.legalName(legalDocs[i].kind),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  color: palette.label,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (showLegalError && !legalAccepted)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 2),
                  child: Text(
                    strings.legalRequired,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 6),
            ],
          ],
        );
      },
    );
  }
}
