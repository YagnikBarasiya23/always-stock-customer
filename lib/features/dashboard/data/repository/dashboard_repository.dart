import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../models/dashboard_summary_model.dart';

abstract class DashboardRepository {
  /// POST /dashboard/summary → summary object. Cached for offline use.
  static Future<DashboardSummaryModel> summary() async {
    final result = await ApiServices.post(
      UrlConstants.dashboardSummary,
      data: {},
      cacheKey: 'dashboard_summary',
    );
    return DashboardSummaryModel.fromJson(AppUtils.parseMap(result.data));
  }
}
