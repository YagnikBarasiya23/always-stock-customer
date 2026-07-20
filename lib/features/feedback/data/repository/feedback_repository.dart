import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../models/feedback_model.dart';

abstract class FeedbackRepository {
  /// POST /feedback/submit → { feedback }. [rating] must be 1–5.
  static Future<FeedbackModel> submit({
    required int rating,
    required String message,
    String? appVersion,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.feedbackSubmit,
      data: {
        'rating': rating,
        'message': message,
        'appVersion': ?appVersion,
      },
    );
    return FeedbackModel.fromJson(AppUtils.parseMap(AppUtils.parseMap(result.data)['feedback']));
  }
}
