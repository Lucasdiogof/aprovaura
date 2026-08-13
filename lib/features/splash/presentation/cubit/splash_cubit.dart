import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/features/splash/presentation/cubit/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashInProgress()) {
    _start();
  }

  Future<void> _start() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (isClosed) return;
    emit(const SplashCompleted());
  }
}
