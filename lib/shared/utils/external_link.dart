import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/shared/l10n/shared_strings.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';

/// Opens [url] in the browser (outside the app, so the page keeps its own
/// address bar and the person can see where they are). If nothing can open
/// it, says so instead of failing silently.
Future<void> openExternalLink(BuildContext context, String url) async {
  var opened = false;
  try {
    opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    opened = false;
  }
  if (opened || !context.mounted) return;
  final strings = SharedStrings(context.read<LocaleCubit>().state);
  await AppInfoBottomSheet.showError(
    context,
    description: strings.linkOpenFailed,
  );
}
