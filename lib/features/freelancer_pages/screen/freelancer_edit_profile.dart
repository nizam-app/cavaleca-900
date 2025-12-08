
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

const Color kPrimaryYellow = Color(0xFFFFB111);
const Color kPrimaryYellowDark = Color(0xFFE69F0F);
const Color kPrimaryRed = Color(0xFFC20001);
const Color kPrimaryRedDark = Color(0xFF9A0001);

class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final String? placeName;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.placeName,
  });
}

class FreelancerProfileData {
  String name;
  String phone;
  String email;
  String address;
  String? placeName;
  bool isAvailable;
  String bio;
  List<String> skills;
  String bankName;
  String accountNumber;
  LocationData? location;

  FreelancerProfileData({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.placeName,
    this.isAvailable = true,
    this.bio = '',
    this.skills = const [],
    this.bankName = '',
    this.accountNumber = '',
    this.location,
  });
}

class FreelancerEditProfile extends ConsumerStatefulWidget {
  const FreelancerEditProfile({super.key});

  static const String routeName = '/freelancer-edit-profile';

  @override
  ConsumerState<FreelancerEditProfile> createState() =>
      _FreelancerEditProfileState();
}

class _FreelancerEditProfileState extends ConsumerState<FreelancerEditProfile> {
  late FreelancerProfileData formData;
  LocationData? locationData;
  bool showMapPicker = false;
  bool isSaving = false;

  // avatar path local (shows selected image)
  String? _avatarImagePath;
  final ImagePicker _picker = ImagePicker();

  // controllers (avoid creating them inside build)
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;
  late final TextEditingController _bankController;
  late final TextEditingController _accountController;

  List<String> availableSkills = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Skilled & Experienced', // example special label
  ];

  @override
  void initState() {
    super.initState();
    formData = FreelancerProfileData(
      name: '',
      phone: '',
      email: '',
      address: '',
      skills: [],
    );

    _nameController = TextEditingController(text: formData.name);
    _phoneController = TextEditingController(text: formData.phone);
    _emailController = TextEditingController(text: formData.email);
    _bioController = TextEditingController(text: formData.bio);
    _bankController = TextEditingController(text: formData.bankName);
    _accountController = TextEditingController(text: formData.accountNumber);

    // keep controllers synced to model
    _nameController.addListener(() => formData.name = _nameController.text);
    _phoneController.addListener(() => formData.phone = _phoneController.text);
    _emailController.addListener(() => formData.email = _emailController.text);
    _bioController.addListener(() => formData.bio = _bioController.text);
    _bankController.addListener(() => formData.bankName = _bankController.text);
    _accountController.addListener(() => formData.accountNumber = _accountController.text);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _bankController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return name.substring(0, name.length.clamp(1, 2)).toUpperCase();
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (formData.skills.contains(skill)) {
        formData.skills.remove(skill);
      } else {
        formData.skills.add(skill);
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (formData.name.isEmpty ||
        formData.phone.isEmpty ||
        formData.email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    setState(() => isSaving = true);
    // TODO: call API to save profile + upload avatar if needed
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isSaving = false);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
    context.pop(formData);
  }

  Future<void> _openMapPicker() async {
    // TODO: Implement map picker route; using push and expecting LocationData return
    final result = await context.push<LocationData>('/map-address-picker');
    if (result != null) {
      setState(() {
        locationData = result;
        formData.address = result.address;
        formData.placeName = result.placeName;
      });
    }
  }

  // -------------- Image picker helpers --------------
  Future<void> _showImageSourceActionSheet() async {
    final choice = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.of(ctx).pop('camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(ctx).pop('gallery'),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );

    if (choice == null) return;
    if (choice == 'camera') {
      await _pickImage(ImageSource.camera);
    } else {
      await _pickImage(ImageSource.gallery);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked == null) return;
      setState(() => _avatarImagePath = picked.path);
      // TODO: upload to server here if needed and replace _avatarImagePath with uploaded URL
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image pick failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimaryYellow, kPrimaryYellowDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
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
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r)),
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: _showImageSourceActionSheet,
                                    child: CircleAvatar(
                                      radius: 48.r,
                                      backgroundColor: Colors.transparent,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [kPrimaryYellow, kPrimaryYellowDark],
                                          ),
                                        ),
                                        child: Center(
                                          child: _avatarImagePath == null
                                              ? Text(
                                            _getInitials(formData.name),
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 24.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                              : ClipOval(
                                            child: Image.file(
                                              File(_avatarImagePath!),
                                              width: 96.r,
                                              height: 96.r,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _showImageSourceActionSheet,
                                      child: Container(
                                        width: 32.w,
                                        height: 32.w,
                                        decoration: BoxDecoration(
                                          color: kPrimaryRed,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.15),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Tap to change photo',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12.sp,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Availability Toggle
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r)),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: const Icon(
                                    Icons.work_outline,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Availability Status',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      'Accept new job requests',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Switch(
                              value: formData.isAvailable,
                              onChanged: (val) {
                                setState(() {
                                  formData.isAvailable = val;
                                });
                              },
                              activeColor: kPrimaryYellow,
                            )
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Personal Info Fields
                    _buildTextField(
                      label: 'Full Name *',
                      controller: _nameController,
                      onChanged: (val) => formData.name = val,
                      icon: Icons.person_outline,
                    ),
                    _buildTextField(
                      label: 'Phone Number *',
                      controller: _phoneController,
                      onChanged: (val) => formData.phone = val,
                      icon: Icons.phone_outlined,
                    ),
                    _buildTextField(
                      label: 'Email Address *',
                      controller: _emailController,
                      onChanged: (val) => formData.email = val,
                      icon: Icons.mail_outline,
                    ),

                    SizedBox(height: 16.h),

                    // Address
                    Text('Address'),
                    SizedBox(height: 4.h),
                    InkWell(
                      onTap: _openMapPicker,
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.grey),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(formData.address.isEmpty ? 'Tap to select location' : formData.address),
                            ),
                            Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: kPrimaryYellow,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: const Icon(Icons.location_on, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Bio
                    _buildTextField(
                      label: 'Bio / Description',
                      controller: _bioController,
                      onChanged: (val) => formData.bio = val,
                      icon: Icons.edit,
                      maxLines: 4,
                    ),

                    SizedBox(height: 16.h),

                    // Skills Section
                    Text('Skills & Expertise *'),
                    SizedBox(height: 8.h),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: availableSkills.map((skill) {
                            final selected = formData.skills.contains(skill);

                            // if selected -> special yellow gradient style
                            if (selected) {
                              return GestureDetector(
                                onTap: () => _toggleSkill(skill),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24.r),
                                    gradient: const LinearGradient(
                                      colors: [kPrimaryYellow, kPrimaryYellowDark],
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        skill,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 6.w),
                                        child: const Icon(Icons.close, size: 12, color: Colors.black87),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }

                            // not selected -> neutral grey pill
                            return GestureDetector(
                              onTap: () => _toggleSkill(skill),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.r),
                                  color: Colors.grey[200],
                                ),
                                child: Text(
                                  skill,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Payment Info
                    Text('Payment Information'),
                    _buildTextField(
                      label: 'Bank Name',
                      controller: _bankController,
                      onChanged: (val) => formData.bankName = val,
                      icon: Icons.credit_card,
                    ),
                    _buildTextField(
                      label: 'Account Number',
                      controller: _accountController,
                      onChanged: (val) => formData.accountNumber = val,
                      icon: Icons.credit_card,
                    ),

                    SizedBox(height: 16.h),

                    // Commission Card
                    Card(
                      elevation: 2,
                      color: Colors.blue[50],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '💡 Commission Rate: 15% of job payment',
                              style: TextStyle(color: Colors.blue),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your earnings will be deposited to this account after job completion',
                              style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.fromHeight(48.h),
                              side: const BorderSide(color: Colors.grey),
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
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size.fromHeight(48.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              backgroundColor: kPrimaryYellow,
                              foregroundColor: Colors.black87,
                            ),
                            child: Text(isSaving ? 'Saving...' : 'Save Changes'),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
