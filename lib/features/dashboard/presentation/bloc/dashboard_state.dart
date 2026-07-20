part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.emitState = DashboardEmitState.initial,
    this.summary,
    this.errorMessage,
  });

  final DashboardEmitState emitState;
  final DashboardSummaryModel? summary;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardEmitState? emitState,
    DashboardSummaryModel? summary,
    String? errorMessage,
    bool nullError = false,
  }) => DashboardState(
    emitState: emitState ?? this.emitState,
    summary: summary ?? this.summary,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  DashboardState asLoading() => copyWith(emitState: DashboardEmitState.loading, nullError: true);
  DashboardState asError(String? errorMessage) =>
      copyWith(emitState: DashboardEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, summary, errorMessage];
}

enum DashboardEmitState { initial, loading, success, error }
