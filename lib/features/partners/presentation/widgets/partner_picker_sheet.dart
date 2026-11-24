import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/features/auth/l10n/email_verification_strings.dart';
import 'package:aura/features/partners/domain/entities/partner.dart';
import 'package:aura/features/partners/presentation/cubit/partner_picker_cubit.dart';

/// Bottom sheet with search + list of active teachers. Returns the chosen
/// [PartnerSummary]; [allowNone] adds the "no referral" option (sign-up),
/// which pops with [PartnerPickerResult.none].
class PartnerPickerResult {
  const PartnerPickerResult(this.partner);
  final PartnerSummary? partner;
  static const none = PartnerPickerResult(null);
}

Future<PartnerPickerResult?> showPartnerPickerSheet(
  BuildContext context, {
  required PartnerPickerCubit cubit,
  required EmailVerificationStrings strings,
  required bool allowNone,
}) {
  return showModalBottomSheet<PartnerPickerResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _PickerBody(strings: strings, allowNone: allowNone),
    ),
  );
}

class _PickerBody extends StatefulWidget {
  const _PickerBody({required this.strings, required this.allowNone});

  final EmailVerificationStrings strings;
  final bool allowNone;

  @override
  State<_PickerBody> createState() => _PickerBodyState();
}

class _PickerBodyState extends State<_PickerBody> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.strings;
    final cubit = context.read<PartnerPickerCubit>();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _controller,
                onChanged: cubit.search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: t.referralSearchHint,
                ),
              ),
            ),
            if (widget.allowNone)
              ListTile(
                leading: const Icon(Icons.person_off_outlined),
                title: Text(t.referralNone),
                onTap: () => Navigator.of(context).pop(PartnerPickerResult.none),
              ),
            Expanded(
              child: BlocBuilder<PartnerPickerCubit, PartnerPickerState>(
                builder: (context, s) {
                  if (s.failed && s.items.isEmpty) {
                    return Center(
                      child: TextButton(
                        onPressed: () => cubit.search(_controller.text),
                        child: Text('${t.referralError} ${t.retry}'),
                      ),
                    );
                  }
                  if (s.loading && s.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (s.items.isEmpty) {
                    return Center(child: Text(t.referralEmpty));
                  }
                  return ListView.builder(
                    itemCount: s.items.length + (s.hasMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == s.items.length) {
                        return TextButton(
                          onPressed: cubit.more,
                          child: Text(t.referralLoadMore),
                        );
                      }
                      final p = s.items[i];
                      return ListTile(
                        title: Text(p.displayName),
                        trailing: s.selected?.id == p.id
                            ? const Icon(Icons.check_rounded)
                            : null,
                        onTap: () => Navigator.of(
                          context,
                        ).pop(PartnerPickerResult(p)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
