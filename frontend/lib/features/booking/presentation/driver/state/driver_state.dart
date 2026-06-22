import 'package:equatable/equatable.dart';

enum DriverStatus {
  initial,
  loading,
  loaded,
  error,
}

class DriverState extends Equatable {
  final DriverStatus status;

  final int todayEarning;
  final int totalEarning;

  final int todayDelivery;
  final int totalDelivery;

  final String? errorMessage;

  const DriverState({
    this.status = DriverStatus.initial,
    this.todayEarning = 0,
    this.totalEarning = 0,
    this.todayDelivery = 0,
    this.totalDelivery = 0,
    this.errorMessage,
  });

  DriverState copyWith({
    DriverStatus? status,
    int? todayEarning,
    int? totalEarning,
    int? todayDelivery,
    int? totalDelivery,
    String? errorMessage,
  }) {
    return DriverState(
      status: status ?? this.status,
      todayEarning: todayEarning ?? this.todayEarning,
      totalEarning: totalEarning ?? this.totalEarning,
      todayDelivery: todayDelivery ?? this.todayDelivery,
      totalDelivery: totalDelivery ?? this.totalDelivery,
      errorMessage:
      errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    todayEarning,
    totalEarning,
    todayDelivery,
    totalDelivery,
    errorMessage,
  ];
}