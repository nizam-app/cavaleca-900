import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:workpleis/features/customer/screen/service/model/create_sr_model.dart';

const Color kPrimaryRed = Color(0xFFC20001);
const Color kPrimaryRedDark = Color(0xFF9A0001);

Future<void> showBookCatagoryDialog(
  BuildContext context, {
  required List<FsmCategory> categories,
  required void Function(FsmCategory category) onCategorySelected,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (ctx) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        backgroundColor: Colors.transparent,
        child: BookServiceDialog(
          categories: categories,
          onCategorySelected: onCategorySelected,
        ),
      );
    },
  );
}

class BookServiceDialog extends StatelessWidget {
  const BookServiceDialog({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  final List<FsmCategory> categories;
  final void Function(FsmCategory category) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 520.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- Header (title + close) ----
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 12.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'book_a_service'.tr(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'select_service_in_steps'.tr(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      size: 22.r,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1.h, color: const Color(0xFFF3F4F6)),
            SizedBox(height: 8.h),

            // ---- Services list ----
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  children: [
                    for (final cat in categories)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _ServiceCard(
                          title: cat.name,
                          description: cat.description ?? '',
                          icon: Icons
                              .handyman_outlined, // চাইলে dynamic করতে পারো
                          onTap: () {
                            Navigator.of(context).pop();
                            onCategorySelected(cat);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const _ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<_ServiceItem> _serviceList = [
  _ServiceItem(
    id: 'general',
    title: 'General Maintenance',
    description: 'Regular maintenance and repairs',
    icon: Icons.handyman_outlined,
  ),
  _ServiceItem(
    id: 'hvac',
    title: 'HVAC Services',
    description: 'Heating, cooling, and ventilation',
    icon: Icons.ac_unit_outlined,
  ),
  _ServiceItem(
    id: 'cleaning',
    title: 'Cleaning Services',
    description: 'Professional cleaning services',
    icon: Icons.cleaning_services_outlined,
  ),
  _ServiceItem(
    id: 'electrical',
    title: 'Electrical Services',
    description: 'Electrical repairs and installations',
    icon: Icons.bolt_outlined,
  ),
  _ServiceItem(
    id: 'plumbing',
    title: 'Plumbing Services',
    description: 'Plumbing repairs and maintenance',
    icon: Icons.plumbing_outlined,
  ),
];

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // left red icon box
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: kPrimaryRed,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26.r),
                ),
                SizedBox(width: 14.w),
                // title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18.r,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
