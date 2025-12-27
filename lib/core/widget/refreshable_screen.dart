import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that automatically refreshes its child when it becomes visible.
/// Useful for IndexedStack-based navigation where screens stay in memory.
class RefreshableScreen extends ConsumerStatefulWidget {
  const RefreshableScreen({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshOnVisible = true,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final bool refreshOnVisible;

  @override
  ConsumerState<RefreshableScreen> createState() => _RefreshableScreenState();
}

class _RefreshableScreenState extends ConsumerState<RefreshableScreen>
    with WidgetsBindingObserver {
  bool _wasVisible = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh when first mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.refreshOnVisible) {
        _refreshIfVisible();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshIfVisible();
    }
  }

  void _refreshIfVisible() {
    if (!mounted || _isRefreshing) return;

    // Check if widget is visible by checking if it's in the render tree
    final renderObject = context.findRenderObject();
    if (renderObject == null) return;

    final isVisible = renderObject.attached && 
                      renderObject is RenderBox && 
                      renderObject.hasSize;

    if (isVisible && (!_wasVisible || widget.refreshOnVisible)) {
      _wasVisible = true;
      _performRefresh();
    } else if (!isVisible) {
      _wasVisible = false;
    }
  }

  Future<void> _performRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh();
    } catch (e) {
      debugPrint('Error refreshing screen: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use VisibilityDetector-like approach with LayoutBuilder
    return LayoutBuilder(
      builder: (context, constraints) {
        // Trigger refresh when constraints change (screen becomes visible)
        if (constraints.maxWidth > 0 && constraints.maxHeight > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && widget.refreshOnVisible) {
              _refreshIfVisible();
            }
          });
        }
        return widget.child;
      },
    );
  }
}

/// Mixin for screens that need to refresh when they become visible
mixin RefreshableScreenMixin<T extends StatefulWidget> on State<T> {
  bool _hasRefreshed = false;
  bool _isRefreshing = false;

  /// Override this method to implement refresh logic
  Future<void> refreshData();

  /// Call this method when the screen becomes visible
  void onScreenVisible() {
    if (!_hasRefreshed || _isRefreshing) {
      _hasRefreshed = true;
      _performRefresh();
    }
  }

  Future<void> _performRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      await refreshData();
    } catch (e) {
      debugPrint('Error refreshing screen: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }
}

/// Provider to track current visible screen index for bottom nav
final currentVisibleScreenProvider = StateProvider<int?>((ref) => null);

