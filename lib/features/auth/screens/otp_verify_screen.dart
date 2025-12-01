import 'package:flutter/material.dart';
import 'package:workpleis/features/auth/widgets/Customer_portal_top_section.dart';

const Color kPrimaryRed = Color(0xFFD4161F); // main red color

class OtpVerifyScreen extends StatelessWidget {
  const OtpVerifyScreen({
    super.key,
    this.sentTo = 'fdsfa', // এখানে তুমি real phone/email পাঠাবে
  });

  final String sentTo;
  static const String routeName = '/otp-verify';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: Column(
        children: [
          // ---------- TOP LOGO CARD ----------
          RoleSelectionCard(),

          const SizedBox(height: 24),

          // ---------- OTP CARD ----------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Center(
                          child: Text(
                            'Verify Phone',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Step text + sentTo in red
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Step 2 of 3: Enter the 6-digit code',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF757575),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'sent to',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF757575),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sentTo,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryRed,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Label
                        Text(
                          'OTP Code',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF555555),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // OTP input
                        SizedBox(
                          height: 48,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '000000',
                              hintStyle: const TextStyle(
                                fontSize: 16,
                                letterSpacing: 4,
                                color: Color(0xFFB0B0B0),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F7F7),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: kPrimaryRed,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Resend OTP
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: resend OTP
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: kPrimaryRed,
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Verify button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: verify & continue
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryRed,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Verify & Continue',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- BOTTOM BACK BUTTON ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  foregroundColor: const Color(0xFF333333),
                ),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text(
                  'Back',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
