// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:workpleis/features/customer/logic/custom_logic.dart';
//
// /// ------------------------------------------------------
// ///  Models / Enums
// /// ------------------------------------------------------
// enum AuthMode { welcome, login, loginOtp, signup, signupOtp, setPassword }
//
// class CustomerAuthScreen extends ConsumerStatefulWidget {
//   const CustomerAuthScreen({super.key, this.onBack});
//
//   static final String routeName = '/customer_auth';
//
//   final VoidCallback? onBack;
//   @override
//   ConsumerState<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
// }
//
// class _CustomerAuthScreenState extends ConsumerState<CustomerAuthScreen> {
//   AuthMode _mode = AuthMode.welcome;
//   bool _showPassword = false;
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }
//
//   void _showToast(String message, {bool success = true}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: success
//             ? const Color(0xFF16A34A)
//             : const Color(0xFFDC2626),
//       ),
//     );
//   }
//
//   // ----------------- FLOW HANDLERS -----------------
//
//   void _handleGuestAccess() {
//     _showToast('Welcome! Booking as guest');
//
//     ref
//         .read(customerAppControllerProvider.notifier)
//         .authComplete(isGuest: true, name: 'Guest User', phone: null);
//   }
//
//   void _handleLoginSubmit() {
//     if (_phoneController.text.trim().isEmpty) {
//       _showToast('Please enter your phone number', success: false);
//       return;
//     }
//     setState(() => _mode = AuthMode.loginOtp);
//     _showToast('OTP sent to your phone');
//   }
//
//   void _handleLoginOtpVerify() {
//     if (_otpController.text.trim().length != 6) {
//       _showToast('Please enter a valid 6-digit OTP', success: false);
//       return;
//     }
//     _showToast('Login successful!');
//
//     ref
//         .read(customerAppControllerProvider.notifier)
//         .authComplete(
//           isGuest: false,
//           name: 'cavaleca', // TODO: backend theke real name
//           phone: _phoneController.text.trim(),
//         );
//   }
//
//   void _handleSignupSubmit() {
//     if (_nameController.text.trim().isEmpty ||
//         _phoneController.text.trim().isEmpty) {
//       _showToast('Please fill all fields', success: false);
//       return;
//     }
//     setState(() => _mode = AuthMode.signupOtp);
//     _showToast('OTP sent to your phone');
//   }
//
//   void _handleSignupOtpVerify() {
//     if (_otpController.text.trim().length != 6) {
//       _showToast('Please enter a valid 6-digit OTP', success: false);
//       return;
//     }
//     _showToast('Phone number verified!');
//     setState(() => _mode = AuthMode.setPassword);
//   }
//
//   void _handleSetPassword() {
//     if (_passwordController.text.trim().length < 6) {
//       _showToast('Password must be at least 6 characters', success: false);
//       return;
//     }
//     _showToast('Account created successfully!');
//
//     ref
//         .read(customerAppControllerProvider.notifier)
//         .authComplete(
//           isGuest: false,
//           name: _nameController.text.trim(),
//           phone: _phoneController.text.trim(),
//         );
//   }
//
//   // ----------------- BACK ACTION -----------------
//
//   void _handleBack() {
//     switch (_mode) {
//       case AuthMode.loginOtp:
//         setState(() {
//           _otpController.clear();
//           _mode = AuthMode.login;
//         });
//         break;
//       case AuthMode.signupOtp:
//         setState(() {
//           _otpController.clear();
//           _mode = AuthMode.signup;
//         });
//         break;
//       case AuthMode.setPassword:
//         setState(() {
//           _passwordController.clear();
//           _mode = AuthMode.signupOtp;
//         });
//         break;
//       case AuthMode.login:
//       case AuthMode.signup:
//         setState(() {
//           _nameController.clear();
//           _phoneController.clear();
//           _passwordController.clear();
//           _otpController.clear();
//           _mode = AuthMode.welcome;
//         });
//         break;
//       case AuthMode.welcome:
//         if (widget.onBack != null) {
//           widget.onBack!();
//         } else {
//           Navigator.of(context).maybePop();
//         }
//         break;
//     }
//   }
//
//   // ----------------- UI BUILDERS -----------------
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F8F8),
//       body: Column(
//         children: [
//           _buildHeader(),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               child: Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 420),
//                   child: _buildCard(),
//                 ),
//               ),
//             ),
//           ),
//           _buildFooter(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0x22000000),
//             blurRadius: 12.r,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           Image.asset(
//             'assets/images/Logo.png',
//             width: 130.w,
//             fit: BoxFit.contain,
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Customer Portal',
//             style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCard() {
//     return Card(
//       elevation: 8.r,
//       margin: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: _buildModeContent(),
//       ),
//     );
//   }
//
//   Widget _buildModeContent() {
//     switch (_mode) {
//       case AuthMode.welcome:
//         return _buildWelcome();
//       case AuthMode.login:
//         return _buildLogin();
//       case AuthMode.loginOtp:
//         return _buildLoginOtp();
//       case AuthMode.signup:
//         return _buildSignup();
//       case AuthMode.signupOtp:
//         return _buildSignupOtp();
//       case AuthMode.setPassword:
//         return _buildSetPassword(); // 👈 screenshot-er screen
//     }
//   }
//
//   Widget _buildFooter() {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.w),
//       child: SizedBox(
//         width: double.infinity,
//         height: 48.h,
//         child: OutlinedButton(
//           onPressed: _handleBack,
//           style: OutlinedButton.styleFrom(
//             backgroundColor: Colors.white,
//             side: const BorderSide(color: Color(0xFFE5E7EB)),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(24.r),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.arrow_back, size: 18.sp, color: Color(0xFF374151)),
//               SizedBox(width: 8.w),
//               Text(
//                 _mode == AuthMode.welcome ? 'Back to Role Selection' : 'Back',
//                 style: TextStyle(fontSize: 14.sp, color: Color(0xFF374151)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ----------------- INDIVIDUAL SCREENS -----------------
//
//   Widget _buildWelcome() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SizedBox(height: 8.h),
//         Text(
//           'Welcome!',
//           style: TextStyle(
//             fontSize: 20.sp,
//             color: Color(0xFF111827),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         SizedBox(height: 6.h),
//         Text(
//           'Book services quickly and easily',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 14.sp, color: Color(0xFF4B5563)),
//         ),
//         const SizedBox(height: 24),
//
//         // Continue as Guest
//         SizedBox(
//           width: double.infinity,
//           height: 56.h,
//           child: ElevatedButton(
//             onPressed: _handleGuestAccess,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFFB111),
//               elevation: 6.r,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//             ),
//             child: Text(
//               'Continue as Guest',
//               style: TextStyle(
//                 fontSize: 15.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF111827),
//               ),
//             ),
//           ),
//         ),
//
//         SizedBox(height: 20.h),
//
//         // Divider with "or"
//         Row(
//           children: const [
//             Expanded(child: Divider(color: Color(0xFFE5E7EB))),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8.0),
//               child: Text(
//                 'or',
//                 style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
//               ),
//             ),
//             Expanded(child: Divider(color: Color(0xFFE5E7EB))),
//           ],
//         ),
//
//         const SizedBox(height: 16),
//
//         // Login button
//         SizedBox(
//           width: double.infinity,
//           height: 56.h,
//           child: OutlinedButton(
//             onPressed: () => setState(() => _mode = AuthMode.login),
//             style: OutlinedButton.styleFrom(
//               side: const BorderSide(color: Color(0xFFC20001), width: 2),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//               backgroundColor: Colors.white,
//             ),
//             child: Text(
//               'Login to Your Account',
//               style: TextStyle(
//                 fontSize: 15.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFFC20001),
//               ),
//             ),
//           ),
//         ),
//
//         SizedBox(height: 12.h),
//
//         // Create new account
//         SizedBox(
//           width: double.infinity,
//           height: 56.h,
//           child: ElevatedButton(
//             onPressed: () => setState(() => _mode = AuthMode.signup),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFC20001),
//               elevation: 6.r,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//             ),
//             child: Text(
//               'Create New Account',
//               style: TextStyle(
//                 fontSize: 15.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//
//         SizedBox(height: 16.h),
//         Text(
//           'Guest bookings are limited. Create an account to track your service history.',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 11.sp, color: Color(0xFF9CA3AF)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLogin() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Center(
//           child: Text(
//             'Welcome Back',
//             style: TextStyle(
//               fontSize: 20.sp,
//               color: Color(0xFF111827),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         SizedBox(height: 6.h),
//         Center(
//           child: Text(
//             'Enter your phone number to login',
//             style: TextStyle(fontSize: 14.sp, color: Color(0xFF4B5563)),
//           ),
//         ),
//         SizedBox(height: 24.h),
//
//         Text(
//           'Phone Number',
//           style: TextStyle(
//             fontSize: 13.sp,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF374151),
//           ),
//         ),
//         SizedBox(height: 6.h),
//         TextField(
//           controller: _phoneController,
//           keyboardType: TextInputType.phone,
//           decoration: InputDecoration(
//             hintText: 'Enter your phone number',
//             prefixIcon: const Icon(
//               Icons.phone_outlined,
//               color: Color(0xFF9CA3AF),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 12.w,
//               vertical: 12.h,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16.r),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16.r),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//           ),
//         ),
//         SizedBox(height: 24.h),
//
//         SizedBox(
//           width: double.infinity,
//           height: 48.h,
//           child: ElevatedButton(
//             onPressed: _handleLoginSubmit,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFC20001),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//             ),
//             child: Text(
//               'Send OTP',
//               style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ),
//
//         SizedBox(height: 16.h),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               "Don't have an account? ",
//               style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
//             ),
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _nameController.clear();
//                   _phoneController.clear();
//                   _passwordController.clear();
//                   _otpController.clear();
//                   _mode = AuthMode.signup;
//                 });
//               },
//               child: Text(
//                 'Sign up',
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   color: Color(0xFFC20001),
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLoginOtp() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         Text(
//           'Verify OTP',
//           style: TextStyle(
//             fontSize: 20.sp,
//             color: Color(0xFF111827),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         SizedBox(height: 6.h),
//         Text(
//           'Enter the 6-digit code sent to\n${_phoneController.text}',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 14.sp, color: Color(0xFF4B5563)),
//         ),
//         SizedBox(height: 24.h),
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Text(
//             'OTP Code',
//             style: TextStyle(
//               fontSize: 13.sp,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey.shade800,
//             ),
//           ),
//         ),
//         SizedBox(height: 6.h),
//         TextField(
//           controller: _otpController,
//           maxLength: 6,
//           keyboardType: TextInputType.number,
//           textAlign: TextAlign.center,
//           decoration: InputDecoration(
//             counterText: '',
//             hintText: '000000',
//             contentPadding: EdgeInsets.symmetric(vertical: 14.h),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//           ),
//           onChanged: (value) {
//             if (value.length > 6) {
//               _otpController.text = value.substring(0, 6);
//             }
//           },
//         ),
//         SizedBox(height: 12.h),
//         TextButton(
//           onPressed: () {
//             _showToast('OTP resent!');
//           },
//           child: Text(
//             'Resend OTP',
//             style: TextStyle(fontSize: 13.sp, color: Color(0xFFC20001)),
//           ),
//         ),
//         SizedBox(height: 8.h),
//         SizedBox(
//           width: double.infinity,
//           height: 48.h,
//           child: ElevatedButton(
//             onPressed: _handleLoginOtpVerify,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFC20001),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//             ),
//             child: Text(
//               'Verify & Login',
//               style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSignup() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Center(
//           child: Text(
//             'Create Account',
//             style: TextStyle(
//               fontSize: 20.sp,
//               color: Color(0xFF111827),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         SizedBox(height: 6.h),
//         Center(
//           child: Text(
//             'Step 1 of 3: Enter your details',
//             style: TextStyle(fontSize: 14.sp, color: Color(0xFF4B5563)),
//           ),
//         ),
//         SizedBox(height: 24.h),
//
//         Text(
//           'Full Name',
//           style: TextStyle(
//             fontSize: 13.sp,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF374151),
//           ),
//         ),
//         SizedBox(height: 6.h),
//         TextField(
//           controller: _nameController,
//           decoration: InputDecoration(
//             hintText: 'Enter your full name',
//             prefixIcon: const Icon(
//               Icons.person_outline,
//               color: Color(0xFF9CA3AF),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 12.w,
//               vertical: 12.h,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//           ),
//         ),
//
//         SizedBox(height: 16.h),
//         Text(
//           'Phone Number',
//           style: TextStyle(
//             fontSize: 13.sp,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF374151),
//           ),
//         ),
//         SizedBox(height: 6.h),
//         TextField(
//           controller: _phoneController,
//           keyboardType: TextInputType.phone,
//           decoration: InputDecoration(
//             hintText: 'Enter your phone number',
//             prefixIcon: const Icon(
//               Icons.phone_outlined,
//               color: Color(0xFF9CA3AF),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 12.w,
//               vertical: 12.h,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16.r),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16.r),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//           ),
//         ),
//
//         SizedBox(height: 24.h),
//         SizedBox(
//           width: double.infinity,
//           height: 48.h,
//           child: ElevatedButton(
//             onPressed: _handleSignupSubmit,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFC20001),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//             ),
//             child: Text(
//               'Continue',
//               style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ),
//
//         SizedBox(height: 16.h),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Already have an account? ',
//               style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
//             ),
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _nameController.clear();
//                   _phoneController.clear();
//                   _passwordController.clear();
//                   _otpController.clear();
//                   _mode = AuthMode.login;
//                 });
//               },
//               child: Text(
//                 'Login',
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   color: Color(0xFFC20001),
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSignupOtp() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         Text(
//           'Verify Phone',
//           style: TextStyle(
//             fontSize: 20.sp,
//             color: Color(0xFF111827),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         SizedBox(height: 6.h),
//         Text(
//           'Step 2 of 3: Enter the 6-digit code sent to\n${_phoneController.text}',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 14.sp, color: Color(0xFF4B5563)),
//         ),
//         SizedBox(height: 24.h),
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Text(
//             'OTP Code',
//             style: TextStyle(
//               fontSize: 13.sp,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey.shade800,
//             ),
//           ),
//         ),
//         SizedBox(height: 6.h),
//         TextField(
//           controller: _otpController,
//           maxLength: 6,
//           keyboardType: TextInputType.number,
//           textAlign: TextAlign.center,
//           decoration: InputDecoration(
//             counterText: '',
//             hintText: '000000',
//             contentPadding: EdgeInsets.symmetric(vertical: 14.h),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//           ),
//           onChanged: (value) {
//             if (value.length > 6) {
//               _otpController.text = value.substring(0, 6);
//             }
//           },
//         ),
//         SizedBox(height: 12.h),
//         TextButton(
//           onPressed: () => _showToast('OTP resent!'),
//           child: Text(
//             'Resend OTP',
//             style: TextStyle(fontSize: 13.sp, color: Color(0xFFC20001)),
//           ),
//         ),
//         SizedBox(height: 8.h),
//         SizedBox(
//           width: double.infinity,
//           height: 48.h,
//           child: ElevatedButton(
//             onPressed: _handleSignupOtpVerify,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFC20001),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//             ),
//             child: Text(
//               'Verify & Continue',
//               style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// ----------------- SET PASSWORD (SCREENSHOT) -----------------
//   Widget _buildSetPassword() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Center(
//           child: Text(
//             'Set Password',
//             style: TextStyle(
//               fontSize: 20.sp,
//               color: Color(0xFF111827),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         SizedBox(height: 6.h),
//         Center(
//           child: Text(
//             'Step 3 of 3: Create a secure password',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14.sp, color: Color(0xFF4B5563)),
//           ),
//         ),
//         SizedBox(height: 24.h),
//
//         Text(
//           'Password',
//           style: TextStyle(
//             fontSize: 13.sp,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF374151),
//           ),
//         ),
//         SizedBox(height: 6.h),
//
//         TextField(
//           controller: _passwordController,
//           obscureText: !_showPassword,
//           decoration: InputDecoration(
//             hintText: 'Create a password (min. 6 characters)',
//             prefixIcon: const Icon(
//               Icons.lock_outline,
//               color: Color(0xFF9CA3AF),
//             ),
//             suffixIcon: IconButton(
//               onPressed: () {
//                 setState(() => _showPassword = !_showPassword);
//               },
//               icon: Icon(
//                 _showPassword
//                     ? Icons.visibility_off_outlined
//                     : Icons.visibility_outlined,
//                 color: Color(0xFF9CA3AF),
//               ),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 12.w,
//               vertical: 12.h,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16.r),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16.r),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//           ),
//         ),
//
//         SizedBox(height: 6.h),
//         Text(
//           'Password must be at least 6 characters long',
//           style: TextStyle(fontSize: 11.sp, color: Color(0xFF9CA3AF)),
//         ),
//
//         SizedBox(height: 24.h),
//         SizedBox(
//           width: double.infinity,
//           height: 48.h,
//           child: ElevatedButton(
//             onPressed: _handleSetPassword,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFC20001),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//             ),
//             child: Text(
//               'Create Account',
//               style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/auth/logic/registration_logic.dart';
import 'package:workpleis/features/auth/screens/customer/logic/customer_login_logic.dart';
import 'package:workpleis/features/customer/logic/custom_logic.dart';

/// ------------------------------------------------------
///  Models / Enums
/// ------------------------------------------------------
enum AuthMode { welcome, login, loginOtp, signup, signupOtp, setPassword }

class CustomerAuthScreen extends ConsumerStatefulWidget {
  const CustomerAuthScreen({super.key, this.onBack});

  static const String routeName = '/customer_auth';
  final VoidCallback? onBack;

  @override
  ConsumerState<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends ConsumerState<CustomerAuthScreen> {
  AuthMode _mode = AuthMode.welcome;
  bool _showPassword = false;

  /// loading flags (আগে ছিল, এখন কাজ করবে)
  bool _isSendingLoginOtp = false;
  bool _isVerifyingLoginOtp = false;

  // 🔵 নতুন registration flags
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

  void _showToast(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success
            ? const Color(0xFF16A34A)
            : const Color(0xFFDC2626),
      ),
    );
  }

  // ----------------- FLOW HANDLERS -----------------

  void _handleGuestAccess() {
    // "Welcome! Booking as guest"
    _showToast('${'welcome'.tr()} ${'booking_as_guest'.tr()}');

    /// Guest → শুধু state আপডেট, token লাগবে না
    ref
        .read(customerAppControllerProvider.notifier)
        .authComplete(isGuest: true, name: 'guest_user'.tr(), phone: null);
  }

  //   void _handleLoginSubmit() {
  //     if (_phoneController.text.trim().isEmpty) {
  //       // ei jaygay hint er text use korlam
  //       _showToast('enter_your_phone_number'.tr(), success: false);
  //       return;
  //     }
  //     setState(() => _mode = AuthMode.loginOtp);
  //     _showToast('otp_sent_to_your_phone'.tr());

  Future<void> _handleLoginSubmit() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showToast('Please enter your phone number', success: false);
      return;
    }

    if (_isSendingLoginOtp) return;

    try {
      setState(() => _isSendingLoginOtp = true);

      final res = await CustomerAuthApi.sendLoginOtp(phone);

      // optional: debug dekhte chaile
      debugPrint('OTP code (test only): ${res.code}');

      setState(() {
        _mode = AuthMode.loginOtp;
      });
      _showToast(res.message);
    } catch (e) {
      _showToast(e.toString(), success: false);
    } finally {
      if (mounted) {
        setState(() => _isSendingLoginOtp = false);
      }
    }
  }

  Future<void> _handleLoginOtpVerify() async {
    final code = _otpController.text.trim();
    final phone = _phoneController.text.trim();

    if (code.length != 6) {
      _showToast('Please enter a valid 6-digit OTP', success: false);
      return;
    }

    //     ref.read(customerAppControllerProvider.notifier).authComplete(
    //       isGuest: false,
    //       name: 'cavaleca', // TODO: backend theke real name
    //       phone: _phoneController.text.trim(),
    //     );

    if (_isVerifyingLoginOtp) return;

    try {
      setState(() => _isVerifyingLoginOtp = true);

      /// এখানে ধরছি verifyLoginOtp ভিতরে token + user save করছে
      await CustomerAuthApi.verifyLoginOtp(phone: phone, code: code);

      _showToast('Login successful!');

      /// এখন শুধু UI state আপডেট করছি
      ref
          .read(customerAppControllerProvider.notifier)
          .authComplete(isGuest: false, name: phone, phone: phone);
    } catch (e) {
      _showToast(e.toString(), success: false);
    } finally {
      if (mounted) {
        setState(() => _isVerifyingLoginOtp = false);
      }
    }
  }

  Future<void> _handleSignupSubmit() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showToast('Please fill all fields', success: false);
      return;
    }
    if (_isSendingSignupOtp) return;

    try {
      setState(() => _isSendingSignupOtp = true);

      final res = await RegistrationApi.sendRegistrationOtp(
        phone: phone,
        name: name,
        role: 'CUSTOMER',
      );

      debugPrint('REG OTP (customer) => ${res.code}');

      _signupTempToken = res.tempToken;

      setState(() => _mode = AuthMode.signupOtp);
      _showToast(res.message);
    } catch (e) {
      _showToast(e.toString(), success: false);
    } finally {
      if (mounted) {
        setState(() => _isSendingSignupOtp = false);
      }
    }
  }

  Future<void> _handleSignupOtpVerify() async {
    final code = _otpController.text.trim();
    final phone = _phoneController.text.trim();

    if (code.length != 6) {
      _showToast('Please enter a valid 6-digit OTP', success: false);
      return;
    }
    if (_signupTempToken == null) {
      _showToast('Missing temp token, please resend OTP', success: false);
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
        _showToast('OTP verification failed', success: false);
        return;
      }

      // backend theke new tempToken pele update করে নিলাম
      _signupTempToken = res.tempToken;

      _showToast(res.message);
      setState(() => _mode = AuthMode.setPassword);
    } catch (e) {
      _showToast(e.toString(), success: false);
    } finally {
      if (mounted) {
        setState(() => _isVerifyingSignupOtp = false);
      }
    }
  }

  Future<void> _handleSetPassword() async {
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();

    if (password.length < 6) {
      _showToast('Password must be at least 6 characters', success: false);
      return;
    }
    if (_signupTempToken == null) {
      _showToast('Missing temp token, please restart signup', success: false);
      return;
    }
    if (_isCompletingSignup) return;

    try {
      setState(() => _isCompletingSignup = true);

      final res = await RegistrationApi.setPassword(
        phone: phone,
        password: password,
        tempToken: _signupTempToken!,
        role: 'CUSTOMER',
        // extra data লাগলে এখানে পাঠাও
      );

      _showToast(res.message);

      // AuthLocalStorage already set হয়েছে RegistrationApi ভেতরে
      ref
          .read(customerAppControllerProvider.notifier)
          .authComplete(isGuest: false, name: name, phone: phone);
    } catch (e) {
      _showToast(e.toString(), success: false);
    } finally {
      if (mounted) {
        setState(() => _isCompletingSignup = false);
      }
    }
  }

  // ----------------- BACK ACTION -----------------

  void _handleBack() {
    switch (_mode) {
      case AuthMode.loginOtp:
        setState(() {
          _otpController.clear();
          _mode = AuthMode.login;
        });
        break;
      case AuthMode.signupOtp:
        setState(() {
          _otpController.clear();
          _mode = AuthMode.signup;
        });
        break;
      case AuthMode.setPassword:
        setState(() {
          _passwordController.clear();
          _mode = AuthMode.signupOtp;
        });
        break;
      case AuthMode.login:
      case AuthMode.signup:
        setState(() {
          _nameController.clear();
          _phoneController.clear();
          _passwordController.clear();
          _otpController.clear();
          _mode = AuthMode.welcome;
        });
        break;
      case AuthMode.welcome:
        if (widget.onBack != null) {
          widget.onBack!();
        } else {
          Navigator.of(context).maybePop();
        }
        break;
    }
  }

  // ----------------- UI BUILDERS -----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x22000000),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            'assets/images/Logo.png',
            width: 130.w,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            'customer_portal'.tr(),
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Card(
      elevation: 8.r,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildModeContent(),
      ),
    );
  }

  Widget _buildModeContent() {
    switch (_mode) {
      case AuthMode.welcome:
        return _buildWelcome();
      case AuthMode.login:
        return _buildLogin();
      case AuthMode.loginOtp:
        return _buildLoginOtp();
      case AuthMode.signup:
        return _buildSignup();
      case AuthMode.signupOtp:
        return _buildSignupOtp();
      case AuthMode.setPassword:
        return _buildSetPassword();
    }
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.w),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: OutlinedButton(
          onPressed: _handleBack,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Color(0xFFE5E7EB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back,
                size: 18.sp,
                color: const Color(0xFF374151),
              ),
              SizedBox(width: 8.w),
              Text(
                _mode == AuthMode.welcome
                    ? 'back_to_role_selection'.tr().substring(0, 8)
                    : 'back'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF374151),
                ),
              ),

              Icon(
                Icons.arrow_back,
                size: 18.sp,
                color: const Color(0xFF374151),
              ),
              SizedBox(width: 8.w),
              Text(
                _mode == AuthMode.welcome ? 'Back to Role Selection' : 'Back',
                style: TextStyle(fontSize: 14.sp, color: Color(0xFF374151)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- INDIVIDUAL SCREENS -----------------

  Widget _buildWelcome() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        Text(
          'welcome'.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'book_services_quickly_and_easily'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4B5563)),
        ),
        const SizedBox(height: 24),

        // Continue as Guest
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: _handleGuestAccess,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB111),
              elevation: 6.r,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              'continue_as_guest'.tr(),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // Divider with "or"
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'or'.tr(),
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
          ],
        ),

        const SizedBox(height: 16),

        // Login button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: OutlinedButton(
            onPressed: () => setState(() => _mode = AuthMode.login),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFC20001), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              backgroundColor: Colors.white,
            ),
            child: Text(
              'login_to_your_account'.tr(),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFC20001),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Create new account
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () => setState(() => _mode = AuthMode.signup),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC20001),
              elevation: 6.r,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              'create_new_account'.tr(),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        SizedBox(height: 16.h),
        Text(
          'guest_bookings_limited'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  Widget _buildLogin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Text(
            'welcome_back'.tr(),
            style: TextStyle(
              fontSize: 20.sp,
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Center(
          child: Text(
            'enter_phone_to_login'.tr(),

            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4B5563)),
          ),
        ),
        SizedBox(height: 24.h),

        Text(
          'phone_number'.tr(),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'enter_your_phone_number'.tr(),
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: Color(0xFF9CA3AF),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
        SizedBox(height: 24.h),

        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _isSendingLoginOtp ? null : _handleLoginSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC20001),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),

            child: _isSendingLoginOtp
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'send_otp'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'dont_have_account'.tr(),
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _nameController.clear();
                  _phoneController.clear();
                  _passwordController.clear();
                  _otpController.clear();
                  _mode = AuthMode.signup;
                });
              },
              child: Text(
                'sign_up'.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFFC20001),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginOtp() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'verify_otp'.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          '${'enter_6_digit_code_sent_to'.tr()}\n${_phoneController.text}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4B5563)),
        ),
        SizedBox(height: 24.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'otp_code'.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: _otpController,
          maxLength: 6,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            counterText: '',
            hintText: 'otp_placeholder'.tr(),
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
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
        SizedBox(height: 12.h),
        TextButton(
          onPressed: () {
            _handleLoginSubmit();
            _showToast('OTP resent!');
          },
          child: Text(
            'resend_otp'.tr(),

            style: TextStyle(fontSize: 13.sp, color: const Color(0xFFC20001)),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _isVerifyingLoginOtp ? null : _handleLoginOtpVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC20001),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),

            child: _isVerifyingLoginOtp
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'verify_and_login'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Text(
            'create_account'.tr(),
            style: TextStyle(
              fontSize: 20.sp,
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        // eta jonno kono key nai, tai English-i rakhlam
        Center(
          child: Text(
            'Step 1 of 3: Enter your details',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4B5563)),
          ),
        ),
        SizedBox(height: 24.h),

        Text(
          'full_name'.tr(),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'enter_name'.tr(),
            prefixIcon: const Icon(
              Icons.person_outline,
              color: Color(0xFF9CA3AF),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),

        SizedBox(height: 16.h),
        Text(
          'phone_number'.tr(),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'enter_your_phone_number'.tr(),
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: Color(0xFF9CA3AF),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),

        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _handleSignupSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC20001),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              'Continue',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        SizedBox(height: 16.h),
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
                  _phoneController.clear();
                  _passwordController.clear();
                  _otpController.clear();
                  _mode = AuthMode.login;
                });
              },
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFFC20001),

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
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Verify Phone',
          style: TextStyle(
            fontSize: 20.sp,
            color: const Color(0xFF111827),

            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Step 2 of 3: Enter the 6-digit code sent to\n${_phoneController.text}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4B5563)),
        ),
        SizedBox(height: 24.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'otp_code'.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: _otpController,
          maxLength: 6,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            counterText: '',
            hintText: 'otp_placeholder'.tr(),
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
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
        SizedBox(height: 12.h),
        TextButton(
          onPressed: () => _showToast('otp_sent_to_your_phone'.tr()),
          child: Text(
            'resend_otp'.tr(),

            style: TextStyle(fontSize: 13.sp, color: const Color(0xFFC20001)),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _handleSignupOtpVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC20001),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
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

  /// ----------------- SET PASSWORD -----------------
  Widget _buildSetPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Text(
            'Set Password',
            style: TextStyle(
              fontSize: 20.sp,
              color: const Color(0xFF111827),

              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Center(
          child: Text(
            'Step 3 of 3: Create a secure password',
            textAlign: TextAlign.center,

            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4B5563)),
          ),
        ),
        SizedBox(height: 24.h),

        Text(
          'password'.tr(),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 6.h),

        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            hintText: 'enter_password'.tr(),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFF9CA3AF),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _showPassword = !_showPassword);
              },
              icon: Icon(
                _showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),

        SizedBox(height: 6.h),
        Text(
          'Password must be at least 6 characters long',

          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
        ),

        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _handleSetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC20001),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              'create_account'.tr(),
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
