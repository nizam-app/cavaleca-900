import 'package:flutter/material.dart';

const _kDialogShadow = BoxShadow(
  color: Color(0x22000000),
  blurRadius: 18,
  offset: Offset(0, 6),
);

class SpecificServiceOption {
  final String title;
  final String priceRange; // e.g. "Est. \$50–80"

  SpecificServiceOption({required this.title, required this.priceRange});
}

/// Step-3 dialog: "Repairs & Fixes"
///
/// Example call:
/// await showSpecificServiceDialog(
///   context,
///   title: 'Repairs & Fixes',
///   stepText: 'Step 3 of 3 – Select specific service',
///   options: [
///     SpecificServiceOption(title: 'Door Repair',   priceRange: 'Est. \$50–80'),
///     SpecificServiceOption(title: 'Window Repair',priceRange: 'Est. \$40–70'),
///     SpecificServiceOption(title: 'Wall Patching',priceRange: 'Est. \$60–100'),
///     SpecificServiceOption(title: 'Floor Repair', priceRange: 'Est. \$80–150'),
///   ],
///   onSelect: (opt) {
///     // TODO: handle selection, go_router / API etc.
///   },
/// );
Future<void> showSpecificServiceDialog(
  BuildContext context, {
  required String title,
  required String stepText,
  required List<SpecificServiceOption> options,
  ValueChanged<SpecificServiceOption>? onSelect,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Select specific service',
    barrierColor: Colors.black.withOpacity(0.5),
    pageBuilder: (_, __, ___) {
      return _SpecificServiceDialog(
        title: title,
        stepText: stepText,
        options: options,
        onSelect: onSelect,
      );
    },
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _SpecificServiceDialog extends StatelessWidget {
  const _SpecificServiceDialog({
    required this.title,
    required this.stepText,
    required this.options,
    this.onSelect,
  });

  final String title;
  final String stepText;
  final List<SpecificServiceOption> options;
  final ValueChanged<SpecificServiceOption>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: 420,
              constraints: const BoxConstraints(maxHeight: 480),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [_kDialogShadow],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: options.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final opt = options[index];
                          return _SpecificServiceTile(
                            title: opt.title,
                            priceRange: opt.priceRange,
                            onTap: () {
                              Navigator.of(context).pop();
                              onSelect?.call(opt);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 14, bottom: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Color(0xFF4B5563),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stepText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _SpecificServiceTile extends StatelessWidget {
  const _SpecificServiceTile({
    required this.title,
    required this.priceRange,
    this.onTap,
  });

  final String title;
  final String priceRange;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceRange,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFF97316), // orange
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
