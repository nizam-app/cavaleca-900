import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/shared/profile_update_service.dart';
import 'package:workpleis/features/internal_technician/screen/profile/data/internal_profile_data.dart';
import 'package:workpleis/features/freelancer_pages/screen/profile/screen/freelancer_profile_screen.dart';

const Color kPrimaryRed = Color(0xFFC20001);
const Color kPrimaryRedDark = Color(0xFF9A0001);
const Color kAccentYellow = Color(0xFFFFB111);

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  static const String routeName = '/edit-profile';

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Controllers
  late final TextEditingController _nameController;

  // Skills management
  final List<String> _skills = [];
  final TextEditingController _skillInputController = TextEditingController();

  // Certifications management
  final List<Map<String, String>> _certifications = [];
  final TextEditingController _certNameController = TextEditingController();
  final TextEditingController _certUrlController = TextEditingController();

  // Dropdowns
  String? _selectedStatus;

  // User role
  String? _userRole; // CUSTOMER, TECH_INTERNAL, TECH_FREELANCER

  bool _isLoading = false;
  bool _isInitializing = true;

  // Status options
  final List<String> _statusOptions = ['ACTIVE', 'INACTIVE', 'PENDING'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isInitializing = true);

    try {
      // Fetch profile from API
      final token = await AuthLocalStorage.getToken();
      if (token == null) {
        throw Exception('No auth token found');
      }

      final response = await http.get(
        Uri.parse(AuthAPIController.profile),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load profile (${response.statusCode})');
      }

      final Map<String, dynamic> userJson = jsonDecode(response.body);

      // Get user role
      _userRole = userJson['role']?.toString().toUpperCase();

      // Load name
      if (userJson['name'] != null) {
        _nameController.text = userJson['name'].toString();
      }

      // Load technician profile data if available (for freelancer/internal)
      final techProfile = userJson['technicianProfile'] as Map<String, dynamic>?;
      if (techProfile != null) {
        // Status
        if (techProfile['status'] != null) {
          _selectedStatus = techProfile['status'].toString();
        }

        // Skills
        if (techProfile['skills'] != null) {
          final skillsList = techProfile['skills'] as List<dynamic>?;
          if (skillsList != null) {
            _skills.clear();
            _skills.addAll(skillsList.map((e) => e.toString()));
          }
        }

        // Certifications
        if (techProfile['certifications'] != null) {
          final certsList = techProfile['certifications'] as List<dynamic>?;
          if (certsList != null) {
            _certifications.clear();
            for (var cert in certsList) {
              if (cert is Map<String, dynamic>) {
                _certifications.add({
                  'name': cert['name']?.toString() ?? '',
                  'url': cert['url']?.toString() ?? '',
                });
              }
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skillInputController.dispose();
    _certNameController.dispose();
    _certUrlController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.grey[800],
        ),
      );
  }

  void _addSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillInputController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _addCertification() {
    final name = _certNameController.text.trim();
    final url = _certUrlController.text.trim();

    if (name.isEmpty || url.isEmpty) {
      _showToast('Please enter both name and URL');
      return;
    }

    setState(() {
      _certifications.add({'name': name, 'url': url});
      _certNameController.clear();
      _certUrlController.clear();
    });
  }

  void _removeCertification(int index) {
    setState(() {
      _certifications.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.trim().isEmpty) {
      _showToast('Please enter your name');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // For CUSTOMER: only send name
      if (_userRole == 'CUSTOMER') {
        await ProfileUpdateService.updateProfile(
          name: _nameController.text.trim(),
        );
      } else {
        // For TECH_INTERNAL and TECH_FREELANCER: send name, status, skills, certifications
        final List<Map<String, String>> certs = _certifications
            .map((c) => {'name': c['name']!, 'url': c['url']!})
            .toList();

        await ProfileUpdateService.updateProfile(
          name: _nameController.text.trim(),
          status: _selectedStatus,
          skills: _skills.isNotEmpty ? _skills : null,
          certifications: certs.isNotEmpty ? certs : null,
        );
      }

      if (!mounted) return;

      // Update local storage with new name for customer
      if (_userRole == 'CUSTOMER') {
        final userJson = await AuthLocalStorage.getUserJson();
        if (userJson != null) {
          userJson['name'] = _nameController.text.trim();
          final token = await AuthLocalStorage.getToken();
          if (token != null) {
            await AuthLocalStorage.saveLoginData(
              token: token,
              userJson: userJson,
            );
          }
        }
      }

      // Invalidate profile providers to refresh profile screens
      if (_userRole == 'TECH_INTERNAL') {
        ref.invalidate(internalProfileProvider);
      } else if (_userRole == 'TECH_FREELANCER') {
        ref.invalidate(freelancerProfileProvider);
      }

      _showToast('Profile updated successfully!');
      
      // Wait a bit for the toast to show, then pop
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      context.pop(true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;
      _showToast('Failed to update profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildLabeledField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              icon,
              size: 20.sp,
              color: Colors.grey[400],
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(
                color: kPrimaryRed,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            hint: Text(
              'Select $label',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimaryRed, kPrimaryRedDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 24.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[900],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    _buildLabeledField(
                      label: 'Name',
                      icon: Icons.person_outline_rounded,
                      controller: _nameController,
                      hintText: 'Enter your name',
                      isRequired: true,
                    ),
                    SizedBox(height: 16.h),

                    // Only show status, skills, certifications for Internal/Freelancer
                    if (_userRole == 'TECH_INTERNAL' ||
                        _userRole == 'TECH_FREELANCER') ...[
                      _buildDropdownField(
                        label: 'Status',
                        value: _selectedStatus,
                        items: _statusOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                      SizedBox(height: 24.h),

                      // Skills Section
                      Text(
                        'Skills',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: 12.h),

                    // Add skill input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _skillInputController,
                            decoration: InputDecoration(
                              hintText: 'Add a skill (e.g., HVAC)',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                            onSubmitted: (_) => _addSkill(),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          onPressed: _addSkill,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Skills chips
                    if (_skills.isNotEmpty)
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _skills.map((skill) {
                          return Chip(
                            label: Text(skill),
                            onDeleted: () => _removeSkill(skill),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.h),

                      // Certifications Section
                      Text(
                        'Certifications',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: 12.h),

                    // Add certification inputs
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _certNameController,
                            decoration: InputDecoration(
                              hintText: 'Certification Name',
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: _certUrlController,
                            decoration: InputDecoration(
                              hintText: 'Certificate URL/File',
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _addCertification,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kAccentYellow,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: const Text('Add Certification'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Certifications list
                    if (_certifications.isNotEmpty)
                      ..._certifications.asMap().entries.map((entry) {
                        final index = entry.key;
                        final cert = entry.value;
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cert['name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      cert['url'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () => _removeCertification(index),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 24.h),
                    ],
                    SizedBox(height: 32.h),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.fromHeight(50.h),
                              side: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size.fromHeight(50.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              backgroundColor: kPrimaryRed,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              _isLoading ? 'Saving...' : 'Save Changes',
                            ),
                          ),
                        ),
                      ],
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

