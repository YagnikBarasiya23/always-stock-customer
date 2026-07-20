import 'package:always_stock/core/utils/api_response_handler.dart';
import 'package:always_stock/features/cart/data/models/cart_model.dart';
import 'package:always_stock/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:always_stock/features/inventory/data/models/inventory_transaction_model.dart';
import 'package:always_stock/features/products/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductModel', () {
    test('fromJson -> toJson round trip is stable', () {
      final json = {
        '_id': 'p1',
        'businessId': 'b1',
        'name': 'Rice 5kg',
        'sku': 'SKU-01',
        'barcode': null,
        'categoryId': 'c1',
        'unit': 'bag',
        'costPrice': 320,
        'sellingPrice': '450.5',
        'imageUrl': null,
        'currentStock': 12,
        'lowStockThreshold': 5,
        'tags': ['grain', 'staple', 42],
        'isActive': true,
        'createdAt': '2026-07-01T10:00:00.000Z',
        'updatedAt': '2026-07-15T10:00:00.000Z',
      };

      final product = ProductModel.fromJson(json);
      expect(product.costPrice, 320.0);
      expect(product.sellingPrice, 450.5);
      expect(product.tags, ['grain', 'staple']);
      expect(product.isLowStock, false);

      final reparsed = ProductModel.fromJson(product.toJson());
      expect(reparsed.toJson(), product.toJson());
    });
  });

  group('DashboardSummaryModel', () {
    test('parses nested today and populated recentTransactions', () {
      final json = {
        'totalProducts': 8,
        'totalStock': 140.5,
        'lowStock': 2,
        'outOfStock': 1,
        'inventoryValue': 20500,
        'today': {'transactionCount': 3, 'netQuantity': -4},
        'recentTransactions': [
          {
            '_id': 't1',
            'businessId': 'b1',
            'productId': {'_id': 'p1', 'name': 'Rice 5kg'},
            'type': 'remove',
            'quantity': 2,
            'previousStock': 14,
            'newStock': 12,
            'performedBy': 'u1',
            'createdAt': '2026-07-18T08:00:00.000Z',
          },
        ],
      };

      final summary = DashboardSummaryModel.fromJson(json);
      expect(summary.today.transactionCount, 3);
      expect(summary.recentTransactions, hasLength(1));
      expect(summary.recentTransactions.first.productId, 'p1');
      expect(summary.recentTransactions.first.type, TransactionType.remove);
    });
  });

  group('TransactionType', () {
    test('unknown fallback for unrecognized values', () {
      expect(TransactionType.fromValue('bogus'), TransactionType.unknown);
      expect(TransactionType.fromValue(null), TransactionType.unknown);
      expect(TransactionType.fromValue('adjust'), TransactionType.adjust);
    });
  });

  group('CartModel', () {
    test('parses nested items and round trips', () {
      final json = {
        '_id': 'cart1',
        'items': [
          {
            '_id': 'ci1',
            'productId': 'p1',
            'name': 'Milk 1L',
            'quantity': 2,
            'sellingPrice': 60,
            'lineTotal': 120,
          },
        ],
        'itemCount': 2,
        'subtotal': 120,
        'grandTotal': 120,
      };

      final cart = CartModel.fromJson(json);
      expect(cart.items, hasLength(1));
      expect(cart.items.first.lineTotal, 120.0);
      expect(cart.isEmpty, false);

      final reparsed = CartModel.fromJson(cart.toJson());
      expect(reparsed.toJson(), cart.toJson());
    });
  });

  group('Pagination', () {
    test('derives totalPages and hasNextPage from backend meta', () {
      final pagination = Pagination.fromJson({'page': 1, 'limit': 20, 'total': 45});
      expect(pagination.totalPages, 3);
      expect(pagination.hasNextPage, true);
      expect(pagination.hasPrevPage, false);

      final lastPage = Pagination.fromJson({'page': 3, 'limit': 20, 'total': 45});
      expect(lastPage.hasNextPage, false);
      expect(lastPage.hasPrevPage, true);
    });
  });
}
