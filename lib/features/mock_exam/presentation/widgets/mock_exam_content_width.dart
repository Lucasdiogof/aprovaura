import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:aura/core/theme/app_spacing.dart';

/// Widest the mock exam content gets. On tablets and wide web windows a
/// 1024px-wide option card or progress bar reads badly, so the side
/// padding grows instead; on phones it's the usual page padding.
const mockExamMaxContentWidth = 640.0;

/// Horizontal padding for mock exam screens: [AppSpacing.pageHorizontal]
/// on phones, and whatever centers the content at
/// [mockExamMaxContentWidth] on wider screens. Backgrounds, borders and the
/// sticky bars still span the full width -- only the content is centered.
double mockExamHorizontalPadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return max(AppSpacing.pageHorizontal, (width - mockExamMaxContentWidth) / 2);
}
