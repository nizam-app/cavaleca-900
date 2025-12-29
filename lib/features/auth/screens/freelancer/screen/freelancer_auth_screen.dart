import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/features/auth/logic/auth_login_flow.dart';
import 'package:workpleis/features/auth/logic/registration_logic.dart';
import 'package:workpleis/features/auth/model/auth_login_model.dart';
import 'package:workpleis/features/nav_bar/screen/freelancer_bottom_nav_bar.dart';
import 'package:workpleis/features/shared/background_location_service.dart';

const Color kPrimaryRed = Color(0xFFC20001);
const Color kPrimaryRedDark = Color(0xFF9A0001);

class FreelancerUserData {
  final String name;
  final String phone;

  const FreelancerUserData({required this.name, required this.phone});
}

typedef FreelancerAuthComplete = void Function(FreelancerUserData user);

enum AuthMode { welcome, login, signup, signupOtp, setPassword }

class FreelancerAuthScreen extends ConsumerStatefulWidget {
  const FreelancerAuthScreen({
    super.key,
    required this.onAuthComplete,
    required this.onBack,
  });

  static const String routeName = '/freelancerAuthScreen';

  /// login / signup sesh hole call hobe
  final FreelancerAuthComplete onAuthComplete;

  /// footer er Back (welcome mode e -> role selection e)
  final VoidCallback onBack;

  @override
  ConsumerState<FreelancerAuthScreen> createState() =>
      _FreelancerAuthScreenState();
}

class _FreelancerAuthScreenState extends ConsumerState<FreelancerAuthScreen> {
  AuthMode _mode = AuthMode.welcome;
  bool _showPassword = false;
  bool _isSendingSignupOtp = false;
  bool _isVerifyingSignupOtp = false;
  bool _isCompletingSignup = false;
  String? _signupTempToken;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  void _showToast(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success
            ? const Color(0xFF16A34A)
            : const Color(0xFFDC2626),
      ),
    );
  }

  // ------------------- Login / Signup Flow -------------------

  void _handleLoginSubmit() async {
    FocusScope.of(context).unfocus();

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty) {
      _showSnack('Please enter phone', error: true);
      return;
    }
    if (password.isEmpty) {
      _showSnack('Please enter password', error: true);
      return;
    }

    // 🔴 ekhane SAME provider use – internalAuthProvider
    final auth = ref.read(internalAuthProvider.notifier);

    await auth.login(phone, password);

    final result = ref.read(internalAuthProvider);

    result.when(
      data: (InternalLoginResponse? res) {
        if (res != null) {
          // backend theke asha user object use korbo
          if (res.user.role == 'TECH_FREELANCER') {
          _showToast('Login successful!');
            // Request location permission and update location silently in background
            BackgroundLocationService.requestAndUpdateLocationInBackground();
            // Navigate to home
            if (context.mounted) {
              context.push(FreelancerBottomNavBar.routeName);
            }
          } else {
            _showToast('You are not authorized');
            // context.push(FreelancerBottomNavBar.routeName);
          }
          final user = res.user;

          widget.onAuthComplete(
            FreelancerUserData(
              name: user.name.isNotEmpty ? user.name : 'Unknown',
              phone: user.phone.isNotEmpty ? user.phone : '',
            ),
          );
        }
      },
      loading: () {},
      error: (err, _) {
        _showSnack(err.toString(), error: true);
      },
    );
  }

  Future<void> _handleSignupSubmit() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showSnack('Please fill all fields', error: true);
      return;
    }
    if (_isSendingSignupOtp) return;

    try {
      setState(() => _isSendingSignupOtp = true);

      final res = await RegistrationApi.sendRegistrationOtp(
        phone: phone,
        name: name,
        role: 'TECH_FREELANCER',
      );

      debugPrint('REG OTP (freelancer) => ${res.code}');
      _signupTempToken = res.tempToken;

      setState(() => _mode = AuthMode.signupOtp);
      _showSnack(res.message);
    } catch (e) {
      _showSnack(e.toString(), error: true);
    } finally {
      if (mounted) {
        setState(() => _isSendingSignupOtp = false);
      }
    }
  }

  Future<void> _handleSignupOtpVerify() async {
    FocusScope.of(context).unfocus();

    final code = _otpController.text.trim();
    final phone = _phoneController.text.trim();

    if (code.length != 6) {
      _showSnack('Please enter a valid 6-digit OTP', error: true);
      return;
    }
    if (_signupTempToken == null) {
      _showSnack('Missing temp token, please resend OTP', error: true);
      return;
    }
    if (_isVerifyingSignupOtp) return;

    try {
      setState(() => _isVerifyingSignupOtp = true);

      final res = await RegistrationApi.verifyRegistrationOtp(
        phone: phone,
        code: code,
        tempToken: _signupTempToken!,
      );

      if (!res.verified) {
        _showSnack('OTP verification failed', error: true);
        return;
      }

      _signupTempToken = res.tempToken;
      _showSnack(res.message);
      setState(() => _mode = AuthMode.setPassword);
    } catch (e) {
      _showSnack(e.toString(), error: true);
    } finally {
      if (mounted) {
        setState(() => _isVerifyingSignupOtp = false);
      }
    }
  }

  Future<void> _handleSetPassword() async {
    FocusScope.of(context).unfocus();

    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters', error: true);
      return;
    }
    if (_signupTempToken == null) {
      _showSnack('Missing temp token, please restart signup', error: true);
      return;
    }
    if (_isCompletingSignup) return;

    try {
      setState(() => _isCompletingSignup = true);

      final res = await RegistrationApi.setPassword(
        phone: phone,
        password: password,
        tempToken: _signupTempToken!,
        role: 'TECH_FREELANCER',
      );

      _showSnack(res.message);
      // token save হয়েছে, এখন nav + callback
      // Request location permission and update location silently in background
      BackgroundLocationService.requestAndUpdateLocationInBackground();
      // Navigate to home
      if (context.mounted) {
        context.push(FreelancerBottomNavBar.routeName);
      }

      widget.onAuthComplete(FreelancerUserData(name: name, phone: phone));
    } catch (e) {
      _showSnack(e.toString(), error: true);
    } finally {
      if (mounted) {
        setState(() => _isCompletingSignup = false);
      }
    }
  }

  void _resetForm() {
    _nameController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _otpController.clear();
  }

  /// Footer back button er behaviour (TSX er getBackAction er moto)
  VoidCallback _getBackAction() {
    switch (_mode) {
      case AuthMode.signupOtp:
        return () {
          setState(() {
            _otpController.clear();
            _mode = AuthMode.signup;
          });
        };
      case AuthMode.setPassword:
        return () {
          setState(() {
            _passwordController.clear();
            _mode = AuthMode.signupOtp;
          });
        };
      case AuthMode.login:
      case AuthMode.signup:
        return () {
          setState(() {
            _resetForm();
            _mode = AuthMode.welcome;
          });
        };
      case AuthMode.welcome:
      default:
        return widget.onBack;
    }
  }

  // ------------------- Build -------------------

  @override
  Widget build(BuildContext context) {
    final bool isWelcome = _mode == AuthMode.welcome;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _FreelancerHeader(),

                // Content: equivalent to flex-1 p-6 + Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      elevation: 6,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _buildBodyForMode(),
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer button: "Back to Role Selection"
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _getBackAction(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF111827),
                      ),
                      label: Text(
                        isWelcome ? 'back_to_role_selection'.tr() : 'back'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------- Different modes (TSX er renderX) -------------------

  Widget _buildBodyForMode() {
    switch (_mode) {
      case AuthMode.welcome:
        return _buildWelcome();
      case AuthMode.login:
        return _buildLogin();
      case AuthMode.signup:
        return _buildSignup();
      case AuthMode.signupOtp:
        return _buildSignupOtp();
      case AuthMode.setPassword:
        return _buildSetPassword();
    }
  }

  // min-h-screen er moddher welcome state
  Widget _buildWelcome() {
    return Column(
      key: const ValueKey('welcome'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
         Text(
          'welcome_freelancer'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
         Text(
          'start_earning_on_your_schedule'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),

        // Login outline button
        SizedBox(
          width: double.infinity,
          height: 56, // h-14
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _mode = AuthMode.login;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimaryRed,
              backgroundColor: Colors.white,
              side: const BorderSide(
                color: kPrimaryRed,
                width: 2, // border-2
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // rounded-2xl
              ),
            ),
            child: Text(
              'login_to_your_account'.tr(),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Create account solid button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _mode = AuthMode.signup;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryRed,
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child:Text(
              'create_new_account'.tr(),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),
         Text(
          'join_our_network_skilled_technicians'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), height: 1.4),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), // rounded-xl
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kPrimaryRed),
      ),
    );
  }

  Widget _buildLogin() {
    final loginState = ref.watch(internalAuthProvider);
    return SingleChildScrollView(
      child: Column(
        key: const ValueKey('login'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
           Text(
            'welcome_back'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
           Text(
            'login_to_your_account'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),

           Text(
            'phone_number_user_id'.tr(),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              hintText: 'enter_your_phone_number'.tr(),
              icon: Icons.phone,
            ),
          ),
          const SizedBox(height: 16),

           Text(
            'password'.tr(),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: _inputDecoration(
              hintText: 'enter_password'.tr(),
              icon: Icons.lock_outline,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: loginState.isLoading ? null : _handleLoginSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: loginState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  :  Text(
                      'log_in'.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(
                "dont_have_account".tr(),
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _resetForm();
                    _mode = AuthMode.signup;
                  });
                },
                child:  Text(
                  'sign_up'.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    color: kPrimaryRed,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Widget _buildSignup() {
    return SingleChildScrollView(
      child: Column(
        key: const ValueKey('signup'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
           Text(
            'join_as_freelancer'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
           Text(
            's_tep_1_of_3'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),

           Text(
            'full_name'.tr(),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: _inputDecoration(
              hintText: 'enter_your_full_name'.tr(),
              icon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 16),

           Text(
            'phone_number'.tr(),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              hintText: 'enter_your_phone_number'.tr(),
              icon: Icons.phone,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _handleSignupSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child:  Text(
                'continue'.tr(),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(
                'already_have_an_account'.tr(),
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _resetForm();
                    _mode = AuthMode.login;
                  });
                },
                child:  Text(
                  'log_in'.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    color: kPrimaryRed,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignupOtp() {
    return Column(
      key: const ValueKey('signupOtp'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
         Text(
          'verify_phone'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
         SizedBox(height: 4),
        Text(
          '${'step_2_of_3'.tr()}\n${_phoneController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),

         Text(
          'otp_code'.tr(),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _otpController,
          maxLength: 6,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(
            hintText: 'otp_placeholder'.tr(),
            icon: Icons.confirmation_number_outlined,
          ).copyWith(counterText: ''),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () {
              _showSnack('OTP resent!');
            },
            child:  Text(
              'resend_otp'.tr(),
              style: TextStyle(fontSize: 13, color: kPrimaryRed),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _handleSignupOtpVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'verify_continue'.tr(),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetPassword() {
    return Column(
      key: const ValueKey('setPassword'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
         Text(
          'set_password'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
         Text(
          'step_3_of_3'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),

         Text(
          'password'.tr(),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: _inputDecoration(
            hintText: 'create_password_hint'.tr(),
            icon: Icons.lock_outline,
            suffix: IconButton(
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
         Text(
          'Password must be at least 6 characters long',
          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _handleSetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child:  Text(
              'create_account'.tr(),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------- Header (logo + “Freelancer Portal”) -------------------

class _FreelancerHeader extends StatelessWidget {
  const _FreelancerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // TODO: nijer logo path boshao (TSX er logoVertical)
          Image.asset(
            'assets/images/Logo.png',
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
           Text(
            'freelancer_portal'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
