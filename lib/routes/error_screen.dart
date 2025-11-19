// widgets/custom_go_error_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomGoErrorPage extends StatelessWidget {
  const CustomGoErrorPage({
    super.key,
    required this.location,
    this.error,
    this.onRetry,
    this.onReport,
  });

  final String location;
  final Object? error;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    // Use ScreenUtil if you already initialize it in your app
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final parsed = _parseError(error, location);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 560.w),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: _ErrorCard(
                  title: parsed.title,
                  subtitle: parsed.subtitle,
                  details: parsed.details,
                  onRetry: onRetry,
                  onReport: onReport,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ParsedError _parseError(Object? err, String loc) {
    final message = err?.toString() ?? '';
    // Simple heuristics to show nicer titles
    if (message.contains('not found') ||
        message.contains('No routes for') ||
        message.contains('Exception: 404')) {
      return _ParsedError(
        title: 'Page not found',
        subtitle: 'We couldn’t find “$loc”. It may have moved or never existed.',
        details: message.isEmpty ? 'Unknown 404' : message,
      );
    }
    if (message.contains('permission') || message.contains('denied')) {
      return _ParsedError(
        title: 'Permission required',
        subtitle: 'You don’t have access to this page.',
        details: message,
      );
    }
    return _ParsedError(
      title: 'Something went wrong',
      subtitle: 'An unexpected error occurred while opening “$loc”.',
      details: message.isEmpty ? 'No details available.' : message,
    );
  }
}

class _ErrorCard extends StatefulWidget {
  const _ErrorCard({
    required this.title,
    required this.subtitle,
    required this.details,
    this.onRetry,
    this.onReport,
  });

  final String title;
  final String subtitle;
  final String details;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;

  @override
  State<_ErrorCard> createState() => _ErrorCardState();
}

class _ErrorCardState extends State<_ErrorCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon header
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.28),
                    blurRadius: 20.r,
                    spreadRadius: 2.r,
                  ),
                ],
              ),
              child: const Icon(Icons.error_outline, color: Colors.white, size: 34),
            ),
            SizedBox(height: 16.h),

            Text(widget.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),

            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            SizedBox(height: 16.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onReport,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: const Text('Report'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: const Text('Go Home'),
                  ),
                ),
              ],
            ),

            // Expandable technical details
            SizedBox(height: 8.h),
            InkWell(
              onTap: () => setState(() => _showDetails = !_showDetails),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _showDetails ? 'Hide details' : 'Show details',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    Icon(
                      _showDetails ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: Colors.grey[600],
                    )
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              crossFadeState: _showDetails
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 220),
              firstChild: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    widget.details,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParsedError {
  final String title;
  final String subtitle;
  final String details;
  const _ParsedError({
    required this.title,
    required this.subtitle,
    required this.details,
  });
}
