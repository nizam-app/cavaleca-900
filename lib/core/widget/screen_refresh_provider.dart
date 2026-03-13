import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track when a screen should refresh
/// Used to trigger refresh when navigating to screens in IndexedStack
final screenRefreshTriggerProvider = StateProvider<int>((ref) => 0);

/// Trigger for jobs list refresh (realtime: technician:jobs_updated).
/// InternalJobs and InternalDashboardV2Screen listen and refetch jobs.
final jobsRefreshTriggerProvider = StateProvider<int>((ref) => 0);

/// Provider to track current visible screen index
final currentVisibleScreenIndexProvider = StateProvider<int?>((ref) => null);

/// Helper function to trigger refresh for a specific screen index
void triggerScreenRefresh(WidgetRef ref, int screenIndex) {
  ref.read(screenRefreshTriggerProvider.notifier).state = 
      ref.read(screenRefreshTriggerProvider) + 1;
  ref.read(currentVisibleScreenIndexProvider.notifier).state = screenIndex;
}

