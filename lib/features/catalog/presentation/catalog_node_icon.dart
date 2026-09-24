import 'package:flutter/material.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

/// `CatalogNode.icon` is a raw emoji glyph seeded straight into Supabase
/// (see `supabase/catalog_seed*.sql`), which is why topic tiles used to
/// render actual emoji next to Material icons everywhere else in the app.
/// This maps the glyphs we know about to an icon from the same visual
/// language; anything unrecognized (including a missing icon) falls back to
/// the node's own subject icon instead of showing a raw emoji.
IconData catalogNodeIcon(String? rawIcon, Subject subject) {
  final icon = rawIcon == null ? null : _iconByGlyph[rawIcon];
  if (icon != null) return icon;
  if (rawIcon != null && _isFlagEmoji(rawIcon)) return Icons.flag_outlined;
  return subject.icon;
}

bool _isFlagEmoji(String value) {
  if (value.isEmpty) return false;
  final first = value.runes.first;
  return first >= 0x1F1E6 && first <= 0x1F1FF;
}

const _iconByGlyph = <String, IconData>{
  // Places / geography
  '🌎': Icons.public_outlined,
  '🌍': Icons.public_outlined,
  '🌏': Icons.public_outlined,
  '🌐': Icons.public_outlined,
  '🗺️': Icons.map_outlined,
  '🗺': Icons.map_outlined,
  '🏙️': Icons.location_city_outlined,
  '🏙': Icons.location_city_outlined,
  '🏝️': Icons.beach_access_outlined,
  '🏝': Icons.beach_access_outlined,
  // Natural features
  '💧': Icons.water_drop_outlined,
  '⛰️': Icons.terrain_outlined,
  '⛰': Icons.terrain_outlined,
  '🌳': Icons.park_outlined,
  '🌱': Icons.eco_outlined,
  '🌦️': Icons.wb_cloudy_outlined,
  '🌦': Icons.wb_cloudy_outlined,
  '🐾': Icons.pets_outlined,
  // Industry / economy
  '🏭': Icons.factory_outlined,
  '💰': Icons.payments_outlined,
  '📈': Icons.trending_up_outlined,
  '📉': Icons.trending_down_outlined,
  // History / civics
  '🏛️': Icons.account_balance_outlined,
  '🏛': Icons.account_balance_outlined,
  '⚔️': Icons.shield_outlined,
  '⚔': Icons.shield_outlined,
  '🗳️': Icons.how_to_vote_outlined,
  '🗳': Icons.how_to_vote_outlined,
  // Language / literature
  '📖': Icons.menu_book_outlined,
  '📚': Icons.menu_book_outlined,
  '✍️': Icons.edit_outlined,
  '✍': Icons.edit_outlined,
  // Science
  '🧬': Icons.biotech_outlined,
  '🔬': Icons.science_outlined,
  '⚛️': Icons.science_outlined,
  '⚛': Icons.science_outlined,
  '🧪': Icons.science_outlined,
  '🩺': Icons.health_and_safety_outlined,
  '⚡': Icons.bolt_outlined,
  // Math
  '🔢': Icons.calculate_outlined,
  '➗': Icons.calculate_outlined,
  '📐': Icons.architecture_outlined,
  '📏': Icons.straighten_outlined,
  '🎲': Icons.casino_outlined,
};
