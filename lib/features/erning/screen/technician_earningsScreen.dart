import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workpleis/features/erning/data/erning_data.dart';
import 'package:workpleis/features/erning/model/erninig_model.dart';
import 'package:workpleis/core/widget/screen_refresh_provider.dart';
import 'package:workpleis/features/nav_bar/logic/botton_nav_index_logic.dart';

class Earningsscreen extends ConsumerStatefulWidget {
  const Earningsscreen({super.key});

  static const String routeName = '/internalEarningsScreen';

  @override
  ConsumerState<Earningsscreen> createState() => _EarningsscreenState();
}

class _EarningsscreenState extends ConsumerState<Earningsscreen> {
  @override
  Widget build(BuildContext context) {
    final asyncSummary = ref.watch(internalEarningsProvider);
    
    // Listen for refresh triggers when this screen becomes visible
    ref.listen<int>(screenRefreshTriggerProvider, (previous, next) {
      final currentIndex = ref.read(bottomNavIndexProvider);
      final visibleIndex = ref.read(currentVisibleScreenIndexProvider);
      // Refresh if this is the earnings screen (index 3) and it's currently visible
      if (currentIndex == 3 && visibleIndex == 3) {
        ref.invalidate(internalEarningsProvider);
      }
    });

    return asyncSummary.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Failed to load earnings:\n$err',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (summary) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(internalEarningsProvider);
              await ref.read(internalEarningsProvider.future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: 30.h),
              child: Column(
                children: [
                  _header(summary),
                  SizedBox(height: 16.h),
                  _statsRow(summary),
                  SizedBox(height: 16.h),
                  _availableBonusCard(context, summary),
                  SizedBox(height: 16.h),
                  _bonusRateCard(summary),
                  SizedBox(height: 16.h),
                  monthlySalaryCard(summary),
                  SizedBox(height: 22.h),
                  _recentBonusesHeader(),
                  SizedBox(height: 8.h),
                  if (summary.recentBonuses.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No recent bonuses yet',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        children: summary.recentBonuses
                            .map((bonus) => _bonusCard(bonus))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // HEADER  – use totalBonuses
  // ------------------------------------------------------------------
  Widget _header(TechnicianEarningsSummary summary) {
    final total = summary.totalBonuses;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 26.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1625),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26.r),
          bottomRight: Radius.circular(26.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "earnings_menu".tr(),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(12.r),
              //     color: Colors.white.withOpacity(0.15),
              //   ),
              //   child: Row(
              //     children: [
              //       Icon(
              //         Icons.file_download_outlined,
              //         color: Colors.white70,
              //         size: 16.sp,
              //       ),
              //       SizedBox(width: 6.w),
              //       // Text(
              //       //   "export".tr(),
              //       //   style: TextStyle(
              //       //     color: Colors.white70,
              //       //     fontSize: 13.sp,
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            "track_bonus".tr(),
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 18.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2432),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Total Bonuses (All Time)",
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  "\$${total.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  total.increaseText.isNotEmpty
                      ? total.increaseText
                      : "${total.increaseRate.toStringAsFixed(1)}% from last month",
                  style: TextStyle(
                    color: const Color(0xFF05DF72),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // TODAY / WEEK / MONTH  – use breakdown
  // ------------------------------------------------------------------
  Widget _statsRow(TechnicianEarningsSummary summary) {
    final br = summary.breakdown;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statBox(
          title: "today".tr(),
          value: "\$${br.today.toStringAsFixed(2)}",
          icon: Icons.attach_money,
          bgColor: const Color(0xFFE8FEEA),
          iconColor: const Color(0xFF4CAF50),
        ),
        _statBox(
          title: "this_week".tr(),
          value: "\$${br.thisWeek.toStringAsFixed(2)}",
          icon: Icons.trending_up,
          bgColor: const Color(0xFFEAF3FF),
          iconColor: const Color(0xFF2979FF),
        ),
        _statBox(
          title: "this_month".tr(),
          value: "\$${br.thisMonth.toStringAsFixed(2)}",
          icon: Icons.calendar_month,
          bgColor: const Color(0xFFF5E8FF),
          iconColor: const Color(0xFF9C27B0),
        ),
      ],
    );
  }

  Widget _statBox({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      width: 110.w,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // AVAILABLE BONUS card – use availableBonus
  // ------------------------------------------------------------------
  Widget _availableBonusCard(
    BuildContext context,
    TechnicianEarningsSummary summary,
  ) {
    final ab = summary.availableBonus;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0A77FF),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "available_bonus".tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "this_week_earnings".tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            "\$${ab.amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "${ab.jobsText} × ${ab.bonusText}",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.85),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            softWrap: true,
          ),
          SizedBox(height: 20.h),
          _earlyPayoutButton(context, summary),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              ab.payoutInfo,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _earlyPayoutButton(
    BuildContext context,
    TechnicianEarningsSummary summary,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(30.r),
      onTap: () => _showEarlyPayoutBottomSheet(context, summary),
      child: Container(
        height: 42.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_money,
              color: const Color(0xFF0A77FF),
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              "request_payout".tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A77FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEarlyPayoutBottomSheet(
    BuildContext context,
    TechnicianEarningsSummary summary,
  ) {
    final available = summary.availableBonus.amount;
    final amountController = TextEditingController(
      text: available.toStringAsFixed(2),
    );
    final reasonController = TextEditingController(
      text: 'Need funds for expenses',
    );
    final imagePicker = ImagePicker();
    String paymentMethod = 'CASH';
    XFile? proofImage;
    bool isSubmitting = false;
    String? imageError;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 16.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: StatefulBuilder(
            builder: (sheetContext, setState) {
              // Check if payment method requires image
              bool requiresImage = paymentMethod != 'CASH';
              
              Future<void> pickProofImage() async {
                try {
                  final source = await showModalBottomSheet<ImageSource>(
                    context: sheetContext,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Gallery'),
                              onTap: () => Navigator.pop(context, ImageSource.gallery),
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Camera'),
                              onTap: () => Navigator.pop(context, ImageSource.camera),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                    ),
                  );

                  if (source == null) return;

                  final image = await imagePicker.pickImage(source: source);
                  if (image != null) {
                    setState(() {
                      proofImage = image;
                    });
                  }
                } catch (e) {
                  if (sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      SnackBar(content: Text('Failed to pick image: $e')),
                    );
                  }
                }
              }

              Future<void> submit() async {
                if (isSubmitting) return;
                if (!formKey.currentState!.validate()) return;

                // Validate image for mobile payment methods
                if (requiresImage && proofImage == null) {
                  setState(() {
                    imageError = 'Please upload payment proof image';
                  });
                  return;
                }
                
                // Clear error if image is present
                setState(() {
                  imageError = null;
                });

                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                    const SnackBar(content: Text('Enter a valid amount')),
                  );
                  return;
                }

                setState(() => isSubmitting = true);
                try {
                  // Note: API may need to be updated to support image upload
                  // For now, we'll call the existing API
                  await TechnicianEarningsApi.requestEarlyPayout(
                    amount: amount,
                    reason: reasonController.text.trim(),
                    paymentMethod: paymentMethod,
                  );
                  if (Navigator.of(sheetContext).canPop()) {
                    Navigator.of(sheetContext).pop();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payout request submitted successfully'),
                    ),
                  );
                } catch (e) {
                  setState(() => isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to submit request: $e'),
                    ),
                  );
                }
              }

              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 48.w,
                        height: 4.h,
                        margin: EdgeInsets.only(bottom: 20.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    // Title with icon
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A77FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: const Color(0xFF0A77FF),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request Early Payout',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Available: \$${available.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    // Amount field (read-only)
                    TextFormField(
                      controller: amountController,
                      readOnly: true,
                      enabled: false,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Amount (Auto-filled)',
                        labelStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
                        ),
                        prefixIcon: Container(
                          margin: EdgeInsets.all(12.r),
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A77FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.attach_money,
                            color: const Color(0xFF0A77FF),
                            size: 20.sp,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Payment Method dropdown
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        labelStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
                        ),
                        prefixIcon: Container(
                          margin: EdgeInsets.all(12.r),
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A77FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.payment,
                            color: const Color(0xFF0A77FF),
                            size: 20.sp,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF0A77FF),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'CASH',
                          child: Text('Cash'),
                        ),
                        DropdownMenuItem(
                          value: 'MOBILE_MONEY',
                          child: Text('Mobile money'),
                        ),
                        DropdownMenuItem(
                          value: 'BANK_TRANSFER',
                          child: Text('Bank transfer'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            paymentMethod = value;
                            // Clear image and error when switching to CASH
                            if (value == 'CASH') {
                              proofImage = null;
                              imageError = null;
                            }
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16.h),
                    // Reason field
                    TextFormField(
                      controller: reasonController,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 15.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Reason',
                        labelStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
                        ),
                        alignLabelWithHint: true,
                        prefixIcon: Container(
                          margin: EdgeInsets.all(12.r),
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A77FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            color: const Color(0xFF0A77FF),
                            size: 20.sp,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF0A77FF),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a reason';
                        }
                        return null;
                      },
                    ),
                    // Conditional image upload for mobile payment methods
                    if (requiresImage) ...[
                      SizedBox(height: 16.h),
                      Text(
                        'Payment Proof Image',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: pickProofImage,
                        child: Container(
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: proofImage == null
                                  ? Colors.grey.shade300
                                  : const Color(0xFF0A77FF),
                              width: proofImage == null ? 1 : 2,
                            ),
                          ),
                          child: proofImage != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14.r),
                                      child: Image.file(
                                        File(proofImage!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(Icons.image, size: 48),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 4.h,
                                      right: 4.w,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            proofImage = null;
                                            imageError = null;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4.w),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 40.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Tap to upload payment proof',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      // Show error message if validation fails
                      if (imageError != null) ...[
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  imageError!,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                    SizedBox(height: 24.h),
                    // Submit button
                    Container(
                      width: double.infinity,
                      height: 52.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0A77FF).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A77FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Submit request',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // BONUS RATE card – use bonusRate
  // ------------------------------------------------------------------
  Widget _bonusRateCard(TechnicianEarningsSummary summary) {
    final br = summary.bonusRate;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF131A26),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium_outlined,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "current_bonus_rate".tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "for_internal_employees".tr(),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                br.ratePercentage.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 48.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                " %",
                style: TextStyle(
                  fontSize: 30.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                "five_percent_rate".tr(),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: Colors.white70, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    br.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // MONTHLY SALARY card – use monthlySalary
  // ------------------------------------------------------------------
  Widget monthlySalaryCard(TechnicianEarningsSummary summary) {
    final ms = summary.monthlySalary;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0CCE6B), Color(0xFF00B95A)],
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "monthly_salary".tr(),
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "\$${ms.total.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 32.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 26.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "base_salary".tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "\$${ms.baseSalary.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 13.sp, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Text(
                      "this_month_bonus".tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "+\$${ms.thisMonthBonus.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 13.sp, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // RECENT BONUSES HEADER (same)
  // ------------------------------------------------------------------
  Widget _recentBonusesHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        children: [
          Text(
            "recent_bonuses".tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            "view_all".tr(),
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF364153),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // BONUS CARD
  // ------------------------------------------------------------------
  Widget _bonusCard(Map<String, dynamic> bonus) {
    final jobName = (bonus['jobName'] ?? '') as String;
    final customerName = (bonus['customerName'] ?? '') as String;
    final dateStr = (bonus['date'] ?? '') as String;
    final bonusAmount = ((bonus['bonus'] ?? 0) as num).toDouble();
    final status = (bonus['status'] ?? '') as String;

    DateTime? date;
    if (dateStr.isNotEmpty) {
      try {
        date = DateTime.parse(dateStr);
      } catch (e) {
        date = DateTime.now();
      }
    } else {
      date = DateTime.now();
    }

    String formattedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bonusDate = DateTime(date.year, date.month, date.day);

    if (bonusDate == today) {
      formattedDate = 'Today, ${_formatTime(date)}';
    } else if (bonusDate == today.subtract(const Duration(days: 1))) {
      formattedDate = 'Yesterday, ${_formatTime(date)}';
    } else {
      formattedDate = _formatDate(date);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      customerName,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${bonusAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0CCE6B),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.black54,
                ),
              ),
              if (status.isNotEmpty) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'PAID'
                        ? const Color(0xFF0CCE6B).withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: status == 'PAID'
                          ? const Color(0xFF0CCE6B)
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
