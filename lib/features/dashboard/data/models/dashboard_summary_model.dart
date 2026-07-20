import '../../../../core/utils/app_utils.dart';
import '../../../inventory/data/models/inventory_transaction_model.dart';

class TodayStatsModel {
  final int transactionCount;
  final double netQuantity;

  const TodayStatsModel({this.transactionCount = 0, this.netQuantity = 0});

  factory TodayStatsModel.fromJson(Map<String, dynamic> json) {
    return TodayStatsModel(
      transactionCount: AppUtils.parseInt(json['transactionCount']) ?? 0,
      netQuantity: AppUtils.parseDouble(json['netQuantity']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionCount': transactionCount,
      'netQuantity': netQuantity,
    };
  }
}

/// Response of `/dashboard/summary`.
class DashboardSummaryModel {
  final int totalProducts;
  final double totalStock;
  final int lowStock;
  final int outOfStock;
  final double inventoryValue;
  final TodayStatsModel today;
  final List<InventoryTransactionModel> recentTransactions;

  const DashboardSummaryModel({
    this.totalProducts = 0,
    this.totalStock = 0,
    this.lowStock = 0,
    this.outOfStock = 0,
    this.inventoryValue = 0,
    this.today = const TodayStatsModel(),
    this.recentTransactions = const [],
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalProducts: AppUtils.parseInt(json['totalProducts']) ?? 0,
      totalStock: AppUtils.parseDouble(json['totalStock']) ?? 0,
      lowStock: AppUtils.parseInt(json['lowStock']) ?? 0,
      outOfStock: AppUtils.parseInt(json['outOfStock']) ?? 0,
      inventoryValue: AppUtils.parseDouble(json['inventoryValue']) ?? 0,
      today: json['today'] is Map<String, dynamic>
          ? TodayStatsModel.fromJson(json['today'] as Map<String, dynamic>)
          : const TodayStatsModel(),
      recentTransactions: AppUtils.parseObjectList(json['recentTransactions'], InventoryTransactionModel.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'totalStock': totalStock,
      'lowStock': lowStock,
      'outOfStock': outOfStock,
      'inventoryValue': inventoryValue,
      'today': today.toJson(),
      'recentTransactions': recentTransactions.map((e) => e.toJson()).toList(),
    };
  }
}
