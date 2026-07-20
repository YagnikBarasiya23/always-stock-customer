import '../../../../core/utils/app_utils.dart';
import 'notification_preferences_model.dart';

enum UserRole {
  owner('owner'),
  staff('staff'),
  viewer('viewer'),
  unknown('unknown');

  const UserRole(this.value);

  final String value;

  static UserRole fromValue(String? value) =>
      values.firstWhere((e) => e.value == value, orElse: () => unknown);
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? businessId;
  final String preferredLanguage;
  final NotificationPreferencesModel notificationPreferences;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = UserRole.owner,
    this.businessId,
    this.preferredLanguage = 'en',
    this.notificationPreferences = const NotificationPreferencesModel(),
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      name: AppUtils.parseString(json['name']) ?? '',
      email: AppUtils.parseString(json['email']) ?? '',
      phone: AppUtils.parseString(json['phone']),
      role: UserRole.fromValue(AppUtils.parseString(json['role'])),
      businessId: AppUtils.parseString(json['businessId']),
      preferredLanguage: AppUtils.parseString(json['preferredLanguage']) ?? 'en',
      notificationPreferences: json['notificationPreferences'] is Map<String, dynamic>
          ? NotificationPreferencesModel.fromJson(json['notificationPreferences'] as Map<String, dynamic>)
          : const NotificationPreferencesModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.value,
      'businessId': businessId,
      'preferredLanguage': preferredLanguage,
      'notificationPreferences': notificationPreferences.toJson(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? businessId,
    String? preferredLanguage,
    NotificationPreferencesModel? notificationPreferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      businessId: businessId ?? this.businessId,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
    );
  }
}
