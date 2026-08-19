import 'package:equatable/equatable.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';

sealed class XpState extends Equatable {
  const XpState();

  @override
  List<Object?> get props => [];
}

class XpLoading extends XpState {
  const XpLoading();
}

class XpError extends XpState {
  const XpError();
}

class XpLoaded extends XpState {
  const XpLoaded(this.xp);

  final UserXp xp;

  @override
  List<Object?> get props => [xp];
}
