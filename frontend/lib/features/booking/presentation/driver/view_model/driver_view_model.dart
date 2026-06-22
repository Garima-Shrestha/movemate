import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/usecase/get_driver_stats_usecase.dart';
import '../state/driver_state.dart';

final driverViewModelProvider =
NotifierProvider<
    DriverViewModel,
    DriverState>(
      () => DriverViewModel(),
);

class DriverViewModel
    extends Notifier<DriverState> {

  late final GetDriverStatsUsecase
  _getDriverStatsUsecase;

  @override
  DriverState build() {

    _getDriverStatsUsecase =
        ref.read(
          getDriverStatsUsecaseProvider,
        );

    Future.microtask(
          () => getDriverStats(),
    );

    return const DriverState();
  }

  Future<void> getDriverStats() async {

    state = state.copyWith(
      status: DriverStatus.loading,
    );

    final result =
    await _getDriverStatsUsecase.call();

    result.fold(
          (failure) {
        state = state.copyWith(
          status: DriverStatus.error,
          errorMessage:
          failure.message,
        );
      },
          (stats) {
        state = state.copyWith(
          status: DriverStatus.loaded,

          todayEarning: stats['todayEarning'] ?? 0,
          totalEarning: stats['totalEarning'] ?? 0,
          todayDelivery: stats['todayDelivery'] ?? 0,
          totalDelivery: stats['totalDelivery'] ?? 0,

          errorMessage: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(
      errorMessage: null,
    );
  }
}