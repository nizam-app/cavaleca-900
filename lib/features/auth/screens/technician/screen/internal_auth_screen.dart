import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/features/auth/logic/auth_login_flow.dart';
import 'package:workpleis/features/nav_bar/screen/internal_bottom_nav_bar.dart';

/// -----------------------------
///  Auth Mode Enum
/// -----------------------------
enum InternalAuthMode { welcome, login, signup, signupOtp, setPassword }

class InternalAuthScreen extends ConsumerStatefulWidget {
  const InternalAuthScreen({super.key});
  static final String routeName = '/internal_auth';

  @override
  ConsumerState<InternalAuthScreen> createState() => _InternalAuthScreenState();
}

class _InternalAuthScreenState extends ConsumerState<InternalAuthScreen> {
  InternalAuthMode _mode = InternalAuthMode.welcome;
  bool _showPassword = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
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

  // -----------------------------
  //  FLOW HANDLERS
  // -----------------------------

  void _handleLoginSubmit() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty) {
      _showToast('Please enter phone', success: false);
      return;
    }
    if (password.isEmpty) {
      _showToast('Please enter password', success: false);
      return;
    }

    final auth = ref.read(internalAuthProvider.notifier);

    await auth.login(phone, password);

    final result = ref.read(internalAuthProvider);

    result.when(
      data: (data) {
        if (data != null) {
          _showToast('Login successful!');
          context.push(InternalBottomNavBar.routeName);
        }
      },
      loading: () {},
      error: (err, _) {
        _showToast(err.toString(), success: false);
      },
    );
  }

  // Signup: name + employee ID + phone -> OTP
  void _handleSignupSubmit() {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _employeeIdController.text.trim().isEmpty) {
      _showToast('Please fill all fields', success: false);
      return;
    }
    setState(() => _mode = InternalAuthMode.signupOtp);
    _showToast('OTP sent to your phone');
  }

  void _handleSignupOtpVerify() {
    if (_otpController.text.trim().length != 6) {
      _showToast('Please enter a valid 6-digit OTP', success: false);
      return;
    }
    _showToast('Phone number verified!');
    setState(() => _mode = InternalAuthMode.setPassword);
  }

  void _handleSetPassword() {
    if (_passwordController.text.trim().length < 6) {
      _showToast('Password must be at least 6 characters', success: false);
      return;
    }
    _showToast('Account created successfully!');
    // onAuthComplete({ name: _nameController.text, phone: _phoneController.text });
  }

  // -----------------------------
  //  BACK ACTION
  // -----------------------------
  void _handleBack() {
    switch (_mode) {
      case InternalAuthMode.signupOtp:
        setState(() {
          _otpController.clear();
          _mode = InternalAuthMode.signup;
        });
        break;
      case InternalAuthMode.setPassword:
        setState(() {
          _passwordController.clear();
          _mode = InternalAuthMode.signupOtp;
        });
        break;
      case InternalAuthMode.login:
      case InternalAuthMode.signup:
        setState(() {
          _nameController.clear();
          _employeeIdController.clear();
          _phoneController.clear();
          _passwordController.clear();
          _otpController.clear();
          _mode = InternalAuthMode.welcome;
        });
        break;
      case InternalAuthMode.welcome:
        Navigator.of(context).maybePop();
        break;
    }
  }

  // -----------------------------
  //  BUILD
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _buildCard(),
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 32, bottom: 24, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔴 ei path ta nijer asset path diye change korba
          Image.asset(
            'assets/images/Logo.png',
            width: 130,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          const Text(
            'Internal Team Portal',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildModeContent(),
      ),
    );
  }

  Widget _buildModeContent() {
    switch (_mode) {
      case InternalAuthMode.welcome:
        return _buildWelcome();
      case InternalAuthMode.login:
        return _buildLogin();
      case InternalAuthMode.signup:
        return _buildSignup();
      case InternalAuthMode.signupOtp:
        return _buildSignupOtp();
      case InternalAuthMode.setPassword:
        return _buildSetPassword();
    }
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: _handleBack,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, size: 18, color: Color(0xFF374151)),
              SizedBox(width: 8),
              Text(
                'Back to Role Selection',
                style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------
  //  INDIVIDUAL SCREENS
  // -----------------------------

  /// Welcome screen
  Widget _buildWelcome() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Internal Team Portal',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Manage your assignments & performance',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
        ),
        const SizedBox(height: 24),

        // Login button (outline red)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => setState(() => _mode = InternalAuthMode.login),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFC20001), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'Login to Your Account',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFC20001),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Register button (solid red)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => setState(() => _mode = InternalAuthMode.signup),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC20001),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Register as Employee',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        const Text(
          'For IBACOS internal technicians with employee ID only.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  Widget _buildLogin() {
    final loginState = ref.watch(internalAuthProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'Login to your account',
            style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Phone Number (User ID)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration(
            hintText: 'Enter your phone number',
            prefixIcon: Icons.phone_outlined,
          ),
        ),

        const SizedBox(height: 16),
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration:
              _inputDecoration(
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline,
              ).copyWith(
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: loginState.isLoading ? null : _handleLoginSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC20001),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: loginState.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Login',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
          ),
        ),

        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _nameController.clear();
                  _employeeIdController.clear();
                  _phoneController.clear();
                  _passwordController.clear();
                  _otpController.clear();
                  _mode = InternalAuthMode.signup;
                });
              },
              child: const Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFC20001),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Employee Registration',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'Step 1 of 3: Enter your details',
            style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Full Name',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          decoration: _inputDecoration(
            hintText: 'Enter your full name',
            prefixIcon: Icons.person_outline,
          ),
        ),

        const SizedBox(height: 16),
        const Text(
          'Employee ID',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _employeeIdController,
          decoration: _inputDecoration(
            hintText: 'Enter your employee ID',
            prefixIcon: Icons.badge_outlined,
          ),
        ),

        const SizedBox(height: 16),
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration(
            hintText: 'Enter your phone number',
            prefixIcon: Icons.phone_outlined,
          ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handleSignupSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC20001),
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
              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _nameController.clear();
                  _employeeIdController.clear();
                  _phoneController.clear();
                  _passwordController.clear();
                  _otpController.clear();
                  _mode = InternalAuthMode.login;
                });
              },
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFC20001),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignupOtp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Verify Phone',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Step 2 of 3: Enter the 6-digit code sent to\n',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                ),
                TextSpan(
                  text: _phoneController.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFC20001),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'OTP Code',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _otpController,
          maxLength: 6,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            counterText: '',
            hintText: '000000',
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          onChanged: (value) {
            if (value.length > 6) {
              _otpController.text = value.substring(0, 6);
            }
          },
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => _showToast('OTP resent!'),
            child: const Text(
              'Resend OTP',
              style: TextStyle(fontSize: 13, color: Color(0xFFC20001)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handleSignupOtpVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC20001),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Set Password',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'Step 3 of 3: Create a secure password',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Password',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration:
              _inputDecoration(
                hintText: 'Create a password (min. 6 characters)',
                prefixIcon: Icons.lock_outline,
              ).copyWith(
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Password must be at least 6 characters long',
          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handleSetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC20001),
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

  // -----------------------------
  //  COMMON DECORATION
  // -----------------------------
  InputDecoration _inputDecoration({
    required String hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, color: const Color(0xFF9CA3AF)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    );
  }
}
