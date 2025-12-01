import 'package:flutter/material.dart';
import 'package:workpleis/features/auth/widgets/Customer_portal_top_section.dart';

const Color kPrimaryRed = Color(0xFFD4161F);

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});
  static final String routeName = '/set-password';

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Logo card (same as OTP screen) ---
              RoleSelectionCard(),

              const SizedBox(height: 24),

              // --- Set password card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Set Password',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Step 3 of 3: Create a secure password',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Password',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // password field
                    SizedBox(
                      height: 52,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: 'Create a password (min. 6 char)',
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() => _obscure = !_obscure);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
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

                    const SizedBox(height: 6),
                    Text(
                      'Password must be at least 6 characters long',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: create account action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- Bottom Back button (same style as previous) ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
