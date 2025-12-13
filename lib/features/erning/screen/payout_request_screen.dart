import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/features/erning/logic/payout_request_payload.dart';

/// ------------------------------------------------------
///  Colors (আপনার স্ক্রিনের সাথে match রাখলাম)
/// ------------------------------------------------------
const Color kBg = Color(0xFFF4F4F4);
const Color kCard = Colors.white;
const Color kTextMain = Color(0xFF364153);
const Color kTextMuted = Color(0xFF9CA3AF);
const Color kPrimaryYellow = Color(0xFFE69F0F);
const Color kPrimaryYellowDark = Color(0xFFE69F0F);
const Color kPrimaryBlue = Color(0xFF2563EB);

/// ------------------------------------------------------
///  Screen (UI)
/// ------------------------------------------------------
class PayoutRequestScreen extends ConsumerStatefulWidget {
  const PayoutRequestScreen({super.key});

  static const routeName = '/payout-request';

  @override
  ConsumerState<PayoutRequestScreen> createState() =>
      _PayoutRequestScreenState();
}

class _PayoutRequestScreenState extends ConsumerState<PayoutRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  String _method = 'BANK_ACCOUNT'; // default

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final amount = num.tryParse(_amountCtrl.text.trim()) ?? 0;
    final reason = _reasonCtrl.text.trim();

    try {
      final res = await ref
          .read(payoutRequestControllerProvider.notifier)
          .submit(amount: amount, reason: reason, paymentMethod: _method);

      if (!mounted) return;

      final msg = (res['message'] ?? 'payout_request_sent'.tr()).toString();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      context.pop(); // চাইলে remove করতে পারেন
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${'failed'.tr()}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(payoutRequestControllerProvider);
    final isLoading = submitState.isLoading;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'payout_request'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: kTextMain,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimaryYellow, kPrimaryYellowDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40.w,
                      width: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: const Icon(Icons.payments, color: Colors.white),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'request_payout_subtitle'
                            .tr(), // "Send payout request to admin"
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // Form Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('amount'.tr()),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _decoration(
                          hint: 'e.g. 100',
                          icon: Icons.attach_money,
                        ),
                        validator: (v) {
                          final n = num.tryParse((v ?? '').trim());
                          if (n == null || n <= 0) {
                            return 'please_enter_valid_amount'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),

                      _Label('payment_method'.tr()),
                      SizedBox(height: 6.h),
                      DropdownButtonFormField<String>(
                        value: _method,
                        decoration: _decoration(
                          hint: '',
                          icon: Icons.account_balance,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'BANK_ACCOUNT',
                            child: Text('BANK_ACCOUNT'),
                          ),
                          // চাইলে পরে add করবেন:
                          // DropdownMenuItem(value: 'PAYPAL', child: Text('PAYPAL')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _method = v);
                        },
                      ),
                      SizedBox(height: 12.h),

                      _Label('reason'.tr()),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _reasonCtrl,
                        maxLines: 4,
                        decoration: _decoration(
                          hint: 'Need funds for expenses',
                          icon: Icons.description_outlined,
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return 'please_enter_reason'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      SizedBox(
                        width: double.infinity,
                        height: 46.h,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 18.w,
                                  width: 18.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'submit_request'.tr(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: kTextMuted),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: kPrimaryBlue, width: 1.2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: kTextMain,
      ),
    );
  }
}

/// ------------------------------------------------------
///  TODO: আপনার প্রজেক্টের config/token এখানে connect করবেন
/// ------------------------------------------------------
class _AppConfig {
  static String baseUrl = "https://YOUR_BASE_URL_HERE"; // ✅ change
  static String? token = ""; // ✅ change (from storage/provider)
}

final payoutRequestControllerProvider =
    AutoDisposeAsyncNotifierProvider<PayoutRequestController, void>(
      PayoutRequestController.new,
    );

class PayoutRequestController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Map<String, dynamic>> submit({
    required num amount,
    required String reason,
    required String paymentMethod,
  }) async {
    state = const AsyncLoading();

    try {
      // ✅ TODO: আপনার প্রজেক্টের baseUrl/token সোর্স এখানে বসান
      final baseUrl = _AppConfig.baseUrl; // <-- change if needed
      final token = _AppConfig.token; // <-- change if needed

      final payload = PayoutRequestPayload(
        amount: amount,
        reason: reason,
        paymentMethod: paymentMethod,
      );

      final res = await CommissionApi.requestPayout(
        baseUrl: baseUrl,
        token: token,
        payload: payload,
      );

      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
