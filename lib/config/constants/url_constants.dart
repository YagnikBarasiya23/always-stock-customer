import 'package:flutter/foundation.dart';

abstract class UrlConstants {
  
  
  
  
  
  
  static String get baseUrl => _override.isEmpty ? _prodUrl : _override;

  static const String _override = String.fromEnvironment('BASE_URL');

  /// Default backend: deployed Vercel production API.
  static const String _prodUrl = 'https://always-stock-backend.vercel.app/api';

  
  
  
  
  
  
  
  
  
  
  /// Local dev fallback. Not used by default — pass one of these via
  // ignore: unintended_html_in_doc_comment
  /// --dart-define=BASE_URL=<url> to target a local backend.
  // ignore: unused_element
  static String get _devFallback => defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:4000/api'
      : 'http://localhost:4000/api';

  
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String login = '/auth/login';

  
  
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';

  
  static const String me = '/user/me';
  static const String updateProfile = '/users/update-profile';
  static const String deleteAccount = '/users/delete-account';


  static const String cmsPageDetailBySlug = '/cms-pages/detail-by-slug';

  
  static const String categoryTree = '/catalog/category-tree';
  static const String catalogHome = '/catalog/home';
  static const String byCategory = '/catalog/by-category';
  static const String productDetail = '/catalog/product-detail';

  
  
  
  static const String orderItems = '/order-items/list';

  
  
  static const String cartDetail = '/cart/detail';
  static const String cartAddItem = '/cart/add-item';
  static const String cartUpdateItemQuantity = '/cart/update-item-quantity';
  static const String cartRemoveItem = '/cart/remove-item';

  
  static const String addressList = '/addresses/list';

  
  static const String activeBanners = '/banners/active-list';

  
  
  
  static const String serviceability = '/stores/serviceability';

  
  
  
  
  
  
  
  static const String globalSearch = '/search/global-search';


  static const String searchSuggestions = '/search/suggestions';

  // ---- Inventory backend (backend/src) ----
  static const String register = '/auth/register';

  static const String productUpsert = '/products/upsert';
  static const String productList = '/products/list';
  static const String productDelete = '/products/delete';
  static const String productSearch = '/products/search';

  static const String categoryUpsert = '/categories/upsert';
  static const String categoryList = '/categories/list';

  static const String inventoryAddStock = '/inventory/add-stock';
  static const String inventoryRemoveStock = '/inventory/remove-stock';
  static const String inventoryAdjustStock = '/inventory/adjust-stock';
  static const String inventoryHistory = '/inventory/history';

  static const String dashboardSummary = '/dashboard/summary';

  static const String notificationList = '/notifications/list';
  static const String notificationMarkRead = '/notifications/mark-read';
  static const String notificationPreferencesUpsert = '/notifications/preferences/upsert';

  static const String deviceRegister = '/devices/register';

  static const String feedbackSubmit = '/feedback/submit';

  static const String userLanguageUpsert = '/user/language/upsert';
}
