part of 'device_bloc.dart';

sealed class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class DeviceRegisterRequested extends DeviceEvent {
  const DeviceRegisterRequested({
    required this.deviceId,
    required this.platform,
    this.fcmToken,
    this.appVersion,
  });

  final String deviceId;
  final DevicePlatform platform;
  final String? fcmToken;
  final String? appVersion;

  @override
  List<Object?> get props => [deviceId, platform, fcmToken, appVersion];
}
