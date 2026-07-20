part of 'feedback_bloc.dart';

class FeedbackState extends Equatable {
  const FeedbackState({
    this.emitState = FeedbackEmitState.initial,
    this.feedback,
    this.errorMessage,
  });

  final FeedbackEmitState emitState;
  final FeedbackModel? feedback;
  final String? errorMessage;

  FeedbackState copyWith({
    FeedbackEmitState? emitState,
    FeedbackModel? feedback,
    String? errorMessage,
    bool nullError = false,
  }) => FeedbackState(
    emitState: emitState ?? this.emitState,
    feedback: feedback ?? this.feedback,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  FeedbackState asLoading() => copyWith(emitState: FeedbackEmitState.loading, nullError: true);
  FeedbackState asError(String? errorMessage) =>
      copyWith(emitState: FeedbackEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, feedback, errorMessage];
}

enum FeedbackEmitState { initial, loading, success, error }
