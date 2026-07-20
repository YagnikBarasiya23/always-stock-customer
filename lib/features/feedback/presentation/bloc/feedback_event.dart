part of 'feedback_bloc.dart';

sealed class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

class FeedbackSubmitRequested extends FeedbackEvent {
  const FeedbackSubmitRequested({
    required this.rating,
    required this.message,
    this.appVersion,
  });

  final int rating;
  final String message;
  final String? appVersion;

  @override
  List<Object?> get props => [rating, message, appVersion];
}
