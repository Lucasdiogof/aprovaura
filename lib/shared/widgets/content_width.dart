import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:aura/core/theme/app_spacing.dart';

/// Widest a column of text or cards gets. On tablets and wide web windows
/// a full-bleed line of prose is miserable to read and to write in, so the
/// side padding grows instead; on phones it's the usual page padding.
const appMaxContentWidth = 640.0;

/// Horizontal padding for a reading/writing screen:
/// [AppSpacing.pageHorizontal] on phones, and whatever centers the content
/// at [appMaxContentWidth] on wider screens. Backgrounds, borders and
/// sticky bars still span the full width -- only the content is centered.
double appHorizontalPadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return max(AppSpacing.pageHorizontal, (width - appMaxContentWidth) / 2);
}
