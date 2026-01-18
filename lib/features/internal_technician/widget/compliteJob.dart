import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:workpleis/features/internal_technician/screen/job/logic/internal_job_logic.dart';
import 'package:workpleis/features/internal_technician/screen/job/model/internal_job_model.dart';

/// ------------------------------------------------------
///  Colors (same style as Job Details popup)
/// ------------------------------------------------------
const Color kDialogBg = Color(0xFFF4F4F4);
const Color kCardBg = Colors.white;
const Color kTextMain = Color(0xFF222222);
const Color kTextMuted = Color(0xFF9E9E9E);
const Color kTextSubtle = Color(0xFFB0B0B0);
const Color kPrimaryGreen = Color(0xFF00B357);
const Color kBorderLight = Color(0xFFE5E5E5);

class Complitejob extends StatefulWidget {
  final int woId;
  final InternalJob job;
  final Function(InternalJob)? onJobCompleted;

  const Complitejob({
    super.key,
    required this.woId,
    required this.job,
    this.onJobCompleted,
  });

  @override
  State<Complitejob> createState() => _ComplitejobState();
}

class _ComplitejobState extends State<Complitejob> {
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double _calculateBonus(String payment) {
    // Use bonusRate from API if available, otherwise default to 5%
    final bonusRate = widget.job.bonusRate ?? 5.0;
    final sanitized = payment.replaceAll('\$', '').replaceAll(',', '');
    final amount = double.tryParse(sanitized) ?? 0;
    return (amount * bonusRate) / 100;
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
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
                leading: Icon(Icons.photo_library, color: kPrimaryGreen),
                title: Text('gallery'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImagesFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: kPrimaryGreen),
                title: Text('camera'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), use READ_MEDIA_IMAGES
      if (await Permission.photos.isGranted) {
        return true;
      }
      final status = await Permission.photos.request();
      if (status.isGranted) {
        return true;
      }
      // Fallback to storage permission for older Android versions
      if (await Permission.storage.isGranted) {
        return true;
      }
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
    return true; // iOS handles permissions automatically
  }

  Future<bool> _requestCameraPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (await Permission.camera.isGranted) {
        return true;
      }
      final status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('camera_permission_required'.tr()),
            ),
          );
        }
        return false;
      }
      return status.isGranted;
    }
    return true;
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('storage_permission_required'.tr()),
            ),
          );
        }
        return;
      }

      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'failed_to_pick_images'.tr()}: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'failed_to_take_photo'.tr()}: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitCompletion() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_upload_at_least_one_photo'.tr())),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updated = await TechnicianJobsApi.completeWorkOrder(
        woId: widget.woId,
        completionNotes: _notesController.text.trim(),
        materialsUsedJson: '[]',
        photos: _selectedImages,
      );

      if (mounted) {
        Navigator.of(context).pop(); // close Complete dialog
        Navigator.of(context).pop(); // close Jobdetails dialog

        if (widget.onJobCompleted != null) {
          widget.onJobCompleted!(updated);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('job_completed_successfully'.tr()),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'failed_to_complete_job'.tr()}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentAmount = double.tryParse(widget.job.payment.replaceAll('\$', '').replaceAll(',', '')) ?? 0;
    // Use yourBonus from API if available, otherwise calculate
    final bonusAmount = widget.job.yourBonus ?? _calculateBonus(widget.job.payment);
    // Use bonusRate from API if available, otherwise default to 5%
    final bonusRate = (widget.job.bonusRate ?? 5.0) / 100; // Convert percentage to decimal

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      child: Container(
        width: 320.w,
        decoration: BoxDecoration(
          color: kDialogBg,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 18.h),
                  _buildWorkPhotosCard(),
                  SizedBox(height: 14.h),
                  _buildNotesField(),
                  SizedBox(height: 14.h),
                  _buildBonusCard(paymentAmount, bonusRate, bonusAmount),
                  SizedBox(height: 20.h),
                  _buildBottomButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// -------------------  HEADER  -----------------------
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 24.w),
            Expanded(
              child: Text(
                'complete_job'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: kTextMain,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.close,
                size: 20.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'upload_photos_and_add_notes'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: kTextMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// -------------------  WORK PHOTOS  ------------------
  Widget _buildWorkPhotosCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'work_photos'.tr(),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: kTextMain,
          ),
        ),
        SizedBox(height: 8.h),
        // Selected images grid
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100.w,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: kBorderLight),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          width: 100.w,
                          height: 100.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
        ],
        // Upload button
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: kBorderLight, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 40.w,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 22.sp,
                    color: kTextMuted,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  _selectedImages.isEmpty ? 'tap_to_upload_photos'.tr() : 'add_more_photos'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: kTextMain,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'one_photo_required'.tr(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: kTextSubtle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// -------------------  NOTES FIELD  ------------------
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'work_notes'.tr(),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: kTextMain,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 12.sp,
            ),
            decoration: InputDecoration(
              hintText: 'add_notes'.tr(),
              hintStyle: TextStyle(fontSize: 12.sp, color: kTextMuted),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  /// -------------------  COMMISSION CARD  -------------------
  Widget _buildBonusCard(
    double jobPayment,
    double bonusRate,
    double bonusValue,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFE7FAF0), Color(0xFFF4FFF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                size: 20.sp,
                color: kPrimaryGreen,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  'bonus_calculation'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'job_payment'.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: kPrimaryGreen,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '\$${jobPayment.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'bonus_rate'.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: kPrimaryGreen,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '${(bonusRate * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(color: const Color(0xFFD6F2E2), height: 1.h, thickness: 1),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'your_bonus'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryGreen,
                  ),
                ),
              ),
              Text(
                '\$${bonusValue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'paid_every_monday'.tr(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: kPrimaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  /// -------------------  BOTTOM BUTTONS  ---------------
  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Container(
              height: 46.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Center(
                child: Text(
                  'cancel'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: GestureDetector(
            onTap: _isSubmitting ? null : _submitCompletion,
            child: Container(
              height: 46.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _isSubmitting ? Colors.grey : kPrimaryGreen,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSubmitting)
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                  SizedBox(width: 8.w),
                  Text(
                    _isSubmitting ? 'completing'.tr() : 'complete_job'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
