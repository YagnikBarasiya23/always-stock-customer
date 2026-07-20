/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.me / UrlConstants.updateProfile.
library;

import '../../../../core/utils/app_utils.dart';

class CustomerModel {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String? avatarUrl;
  final String? defaultAddressId;
  final DateTime? createdAt;

  const CustomerModel({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.avatarUrl,
    this.defaultAddressId,
    this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      name: AppUtils.parseString(json['name']) ?? '',
      email: AppUtils.parseString(json['email']),
      phone: AppUtils.parseString(json['phone']) ?? '',
      avatarUrl: AppUtils.parseString(json['avatarUrl']),
      defaultAddressId: AppUtils.parseString(json['defaultAddressId']),
      createdAt: AppUtils.parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'defaultAddressId': defaultAddressId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? defaultAddressId,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      defaultAddressId: defaultAddressId ?? this.defaultAddressId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
