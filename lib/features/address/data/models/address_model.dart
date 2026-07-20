/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.addressList.
library;

import '../../../../core/utils/app_utils.dart';

enum AddressType {
  home('home'),
  work('work'),
  other('other'),
  unknown('unknown');

  const AddressType(this.value);

  final String value;

  static AddressType fromValue(String? value) =>
      values.firstWhere((e) => e.value == value, orElse: () => unknown);
}

class AddressModel {
  final String id;
  final AddressType type;
  final String line1;
  final String? line2;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final String? contactName;
  final String? contactPhone;

  const AddressModel({
    required this.id,
    this.type = AddressType.home,
    required this.line1,
    this.line2,
    this.landmark,
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.contactName,
    this.contactPhone,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      type: json['type'] == null ? AddressType.home : AddressType.fromValue(AppUtils.parseString(json['type'])),
      line1: AppUtils.parseString(json['line1']) ?? '',
      line2: AppUtils.parseString(json['line2']),
      landmark: AppUtils.parseString(json['landmark']),
      city: AppUtils.parseString(json['city']) ?? '',
      state: AppUtils.parseString(json['state']) ?? '',
      pincode: AppUtils.parseString(json['pincode']) ?? '',
      latitude: AppUtils.parseDouble(json['latitude']),
      longitude: AppUtils.parseDouble(json['longitude']),
      isDefault: AppUtils.parseBool(json['isDefault']) ?? false,
      contactName: AppUtils.parseString(json['contactName']),
      contactPhone: AppUtils.parseString(json['contactPhone']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type.value,
      'line1': line1,
      'line2': line2,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'contactName': contactName,
      'contactPhone': contactPhone,
    };
  }

  AddressModel copyWith({
    String? id,
    AddressType? type,
    String? line1,
    String? line2,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
    bool? isDefault,
    String? contactName,
    String? contactPhone,
  }) {
    return AddressModel(
      id: id ?? this.id,
      type: type ?? this.type,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }
}
