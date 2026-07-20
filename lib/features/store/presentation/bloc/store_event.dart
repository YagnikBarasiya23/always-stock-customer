part of 'store_bloc.dart';

sealed class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

class StoreServiceabilityRequested extends StoreEvent {
  const StoreServiceabilityRequested({this.pincode, this.latitude, this.longitude});

  final String? pincode;
  final double? latitude;
  final double? longitude;

  @override
  List<Object?> get props => [pincode, latitude, longitude];
}
