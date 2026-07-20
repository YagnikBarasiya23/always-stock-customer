part of 'banner_bloc.dart';

class BannerState extends Equatable {
  const BannerState({
    this.emitState = BannerEmitState.initial,
    this.banners = const [],
    this.errorMessage,
  });

  final BannerEmitState emitState;
  final List<BannerModel> banners;
  final String? errorMessage;

  BannerState copyWith({
    BannerEmitState? emitState,
    List<BannerModel>? banners,
    String? errorMessage,
    bool nullError = false,
  }) => BannerState(
    emitState: emitState ?? this.emitState,
    banners: banners ?? this.banners,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  BannerState asLoading() => copyWith(emitState: BannerEmitState.loading, nullError: true);
  BannerState asError(String? errorMessage) => copyWith(emitState: BannerEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, banners, errorMessage];
}

enum BannerEmitState { initial, loading, success, error }
