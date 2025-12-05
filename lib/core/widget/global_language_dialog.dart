// core/widget/global_language_dialog.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key, required this.currentCode});

  final String currentCode; // en, fr

  @override
  Widget build(BuildContext context) {
    /// Tumi jodi sudhu en + fr use koro:
    final languages = [
      ('en', 'English', 'English'),
      ('fr', 'French', 'Français'),
      // jodi pore Arabic add koro, tokhon niche line ta uncomment korbe:
      // ('ar', 'Arabic', 'العربية'),
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        // JSON key: language.select_title
        'language.select_title'.tr(), // e.g. "Select Language"
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            // JSON key: language.select_subtitle
            'language.select_subtitle'.tr(),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          for (final item in languages) ...[
            _LanguageTile(
              code: item.$1,
              nativeName: item.$3,
              name: item.$2,
              isSelected: currentCode == item.$1,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.code,
    required this.nativeName,
    required this.name,
    required this.isSelected,
  });

  final String code;
  final String nativeName;
  final String name;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      // dialog theke language code pop korbo
      onTap: () => Navigator.of(context).pop(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC20001)
                : const Color(0xFFE5E7EB),
            width: 2,
          ),
          color: isSelected ? const Color(0xFFFFE5E5) : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFFC20001), size: 20),
          ],
        ),
      ),
    );
  }
}
