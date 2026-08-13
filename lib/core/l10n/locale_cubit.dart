import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/app_language.dart';

class LocaleCubit extends Cubit<AppLanguage> {
  LocaleCubit() : super(AppLanguage.fromDeviceLocale());

  void setLanguage(AppLanguage language) => emit(language);
}
