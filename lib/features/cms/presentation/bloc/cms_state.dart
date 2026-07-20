part of 'cms_bloc.dart';

class CmsState extends Equatable {
  const CmsState({
    this.emitState = CmsEmitState.initial,
    this.page,
    this.errorMessage,
  });

  final CmsEmitState emitState;
  final CmsPageModel? page;
  final String? errorMessage;

  CmsState copyWith({
    CmsEmitState? emitState,
    CmsPageModel? page,
    String? errorMessage,
    bool nullError = false,
  }) => CmsState(
    emitState: emitState ?? this.emitState,
    page: page ?? this.page,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  CmsState asLoading() => copyWith(emitState: CmsEmitState.loading, nullError: true);
  CmsState asError(String? errorMessage) => copyWith(emitState: CmsEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, page, errorMessage];
}

enum CmsEmitState { initial, loading, success, error }
