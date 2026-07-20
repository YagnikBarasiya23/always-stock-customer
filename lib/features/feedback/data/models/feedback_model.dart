import '../../../../core/utils/app_utils.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final int rating;
  final String message;
  final String? appVersion;
  final DateTime? createdAt;

  const FeedbackModel({
    required this.id,
    required this.userId,
    required this.rating,
    this.message = '',
    this.appVersion,
    this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      userId: AppUtils.parseString(json['userId']) ?? '',
      rating: AppUtils.parseInt(json['rating']) ?? 0,
      message: AppUtils.parseString(json['message']) ?? '',
      appVersion: AppUtils.parseString(json['appVersion']),
      createdAt: AppUtils.parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'rating': rating,
      'message': message,
      'appVersion': appVersion,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
