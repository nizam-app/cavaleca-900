import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/auth/logic/auth_login_flow.dart';
import 'package:workpleis/features/auth/model/auth_login_model.dart';

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
          final user = res.user;

          widget.onAuthComplete(
            FreelancerUserData(name: user.name, phone: user.phone),
          );
        }
      },
      loading: () {},
      error: (err, _) {
        _showSnack(err.toString(), error: true);
      },
    );
  }

  void _handleSignupSubmit() {
    FocusScope.of(context).unfocus();

    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _showSnack('Please fill all fields', error: true);
      return;
    }

    setState(() {
      _mode = AuthMode.signupOtp;
    });
    _showSnack('OTP sent to your phone');
  }

  void _handleSignupOtpVerify() {
    FocusScope.of(context).unfocus();

    if (_otpController.text.length != 6) {
      _showSnack('Please enter a valid 6-digit OTP', error: true);
      return;
    }

    _showSnack('Phone number verified!');
    setState(() {
      _mode = AuthMode.setPassword;
    });
  }

  void _handleSetPassword() {
    FocusScope.of(context).unfocus();

    if (_passwordController.text.length < 6) {
      _showSnack('Password must be at least 6 characters', error: true);
      return;
    }

    _showSnack('Account created successfully!');
    widget.onAuthComplete(
      FreelancerUserData(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      ),
    );
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
                        isWelcome ? 'Back to Role Selection' : 'Back',
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
        const Text(
          'Welcome Freelancer!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Start earning on your schedule',
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
            child: const Text(
              'Login to Your Account',
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
            child: const Text(
              'Create New Account',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Join our network of skilled technicians and earn commission on every job.',
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
          const Text(
            'Welcome Back',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Login to your account',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),

          const Text(
            'Phone Number (User ID)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              hintText: 'Enter your phone number',
              icon: Icons.phone,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Password',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: _inputDecoration(
              hintText: 'Enter your password',
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
                  : const Text(
                      'Login',
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
              const Text(
                "Don't have an account? ",
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _resetForm();
                    _mode = AuthMode.signup;
                  });
                },
                child: const Text(
                  'Sign up',
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
          const Text(
            'Join as Freelancer',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Step 1 of 3: Enter your details',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),

          const Text(
            'Full Name',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: _inputDecoration(
              hintText: 'Enter your full name',
              icon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Phone Number',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              hintText: 'Enter your phone number',
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
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _resetForm();
                    _mode = AuthMode.login;
                  });
                },
                child: const Text(
                  'Login',
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
        const Text(
          'Verify Phone',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Step 2 of 3: Enter the 6-digit code sent to\n${_phoneController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),

        const Text(
          'OTP Code',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _otpController,
          maxLength: 6,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(
            hintText: '000000',
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
            child: const Text(
              'Resend OTP',
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
            child: const Text(
              'Verify & Continue',
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
        const Text(
          'Set Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Step 3 of 3: Create a secure password',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),

        const Text(
          'Password',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: _inputDecoration(
            hintText: 'Create a password (min. 6 characters)',
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
        const Text(
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
            child: const Text(
              'Create Account',
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
          const Text(
            'Freelancer Portal',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
