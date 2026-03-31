import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:workpleis/features/internal_technician/screen/job/logic/internal_job_logic.dart';
import 'package:workpleis/features/internal_technician/screen/job/model/internal_job_model.dart';
import 'package:workpleis/features/internal_technician/widget/newJobAssigned.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';

/// Global service to show incoming job notifications with mandatory dialog
/// Works across all screens using Overlay
class JobNotificationService {
  static final _log = Logger();
  static final JobNotificationService _instance = JobNotificationService._internal();
  factory JobNotificationService() => _instance;
  JobNotificationService._internal();

  OverlayEntry? _currentOverlay;
  BuildContext? _context;
  bool _isShowingDialog = false;
  Timer? _pollingTimer;
  Set<int> _knownJobIds = {}; // Track jobs we've already shown
  Map<int, DateTime> _closedJobs = {}; // Track when jobs were closed (for 30 min reminder)
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  /// Initialize the service with app context
  Future<void> initialize(BuildContext context) async {
    _context = context;
    _log.i('JobNotificationService initialized');
    
    // Initialize notification channel for alarm sound (Android)
    await _initializeNotificationChannel();
  }

  /// Initialize notification channel for alarm sound
  Future<void> _initializeNotificationChannel() async {
    try {
      const androidChannel = AndroidNotificationChannel(
        'job_alarm_channel',
        'Job Alarm Notifications',
        description: 'Alarm sound for incoming job notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
      
      _log.i('Job alarm notification channel initialized');
    } catch (e) {
      _log.w('Error initializing notification channel: $e');
    }
  }

  /// Start polling for new incoming jobs
  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    _stopPolling();
    _log.i('Starting job polling with interval: ${interval.inSeconds}s');
    
    _pollingTimer = Timer.periodic(interval, (_) async {
      await _checkForNewJobs();
    });
    
    // Check immediately
    _checkForNewJobs();
  }

  /// Stop polling
  void stopPolling() {
    _stopPolling();
  }

  /// Trigger an immediate check for new incoming jobs (e.g. from realtime socket).
  Future<void> triggerCheckForNewJobs() async {
    await _checkForNewJobs();
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Check for new incoming jobs
  Future<void> _checkForNewJobs() async {
    if (_context == null || _isShowingDialog) return;

    try {
      final token = await AuthLocalStorage.getToken();
      if (token == null) return;

      final incomingJobs = await TechnicianJobsApi.fetchJobs('incoming');
      
      if (incomingJobs.isEmpty) return;
      
      // Get the most recent job (first one in the list, assuming API returns newest first)
      final mostRecentJob = incomingJobs.first;
      
      // Check if this is a new job we haven't shown yet
      if (!_knownJobIds.contains(mostRecentJob.id)) {
        _knownJobIds.add(mostRecentJob.id);
        // Remove from closed jobs if it was there
        _closedJobs.remove(mostRecentJob.id);
        // Show notification for new job
        await showJobNotification(mostRecentJob);
        return;
      }
      
      // Check if this job was closed and 30 minutes have passed
      if (_closedJobs.containsKey(mostRecentJob.id)) {
        final closedTime = _closedJobs[mostRecentJob.id]!;
        final now = DateTime.now();
        final difference = now.difference(closedTime);
        
        if (difference.inMinutes >= 30) {
          // 30 minutes passed, show reminder
          _log.i('Showing reminder for job ${mostRecentJob.id} after 30 minutes');
          _closedJobs.remove(mostRecentJob.id);
          await showJobNotification(mostRecentJob);
        }
      }

      // Clean up old job IDs (keep only current incoming jobs)
      final currentIds = incomingJobs.map((j) => j.id).toSet();
      _knownJobIds.removeWhere((id) => !currentIds.contains(id));
      _closedJobs.removeWhere((id, _) => !currentIds.contains(id));
    } catch (e) {
      _log.e('Error checking for new jobs: $e');
    }
  }

  /// Show job notification dialog (mandatory, non-dismissible)
  Future<void> showJobNotification(InternalJob job) async {
    _log.i('🎯 Attempting to show job notification for job ${job.id}');
    
    if (_context == null) {
      _log.w('⚠️ Cannot show job notification: context is null. Job will be shown via polling.');
      // Mark job as known so polling will pick it up
      _knownJobIds.add(job.id);
      return;
    }

    if (_isShowingDialog) {
      _log.w('⚠️ Cannot show job notification: dialog already showing. Job ${job.id} will be shown via polling.');
      // Mark job as known so polling will pick it up when current dialog closes
      _knownJobIds.add(job.id);
      return;
    }

    _isShowingDialog = true;
    _log.i('✅ Showing job notification dialog for job ${job.id}');

    try {
      // Play alarm sound immediately
      _log.i('🔊 Starting alarm sound...');
      await _playAlarmSound();

      // Get the root navigator context and overlay
      final overlay = Overlay.of(_context!, rootOverlay: true);
      _log.i('✅ Overlay obtained successfully');

      // Remove any existing overlay
      _hideCurrentDialog();

      // Create overlay entry
      _currentOverlay = OverlayEntry(
        builder: (context) => _JobNotificationOverlay(
          job: job,
          onAccept: () async {
            await _handleAccept(job);
            _hideCurrentDialog();
          },
          onReject: () async {
            await _handleReject(job);
            _hideCurrentDialog();
          },
          onClose: () {
            // User closed the dialog - stop sound and schedule reminder after 30 minutes
            _stopAlarmSound();
            _scheduleReminder(job);
            _hideCurrentDialog();
          },
          onTimeout: () {
            // Auto-close after 20 seconds - stop sound and schedule reminder after 30 minutes
            _stopAlarmSound();
            _scheduleReminder(job);
            _hideCurrentDialog();
          },
        ),
      );

      overlay.insert(_currentOverlay!);
      _log.i('✅ Job notification overlay inserted successfully');
    } catch (e, stackTrace) {
      _log.e('❌ Error showing job notification: $e', error: e, stackTrace: stackTrace);
      _isShowingDialog = false;
      // Mark job as known so polling can catch it
      _knownJobIds.add(job.id);
    }
  }

  /// Handle job notification from FCM
  Future<void> handleFCMJobNotification(Map<String, dynamic> data) async {
    try {
      _log.i('🔔 FCM Job Notification received: $data');
      
      // Extract job ID from notification data
      final jobId = data['jobId'] ?? data['woId'] ?? data['workOrderId'];
      if (jobId == null) {
        _log.w('❌ No job ID in FCM notification data: $data');
        return;
      }

      _log.i('📋 Looking for job ID: $jobId');

      // Retry logic: Sometimes API needs a moment to update after job assignment
      InternalJob? job;
      int retryCount = 0;
      const maxRetries = 5;
      const retryDelay = Duration(seconds: 2);

      while (retryCount < maxRetries && job == null) {
        try {
          _log.i('🔄 Fetching incoming jobs (attempt ${retryCount + 1}/$maxRetries)...');
          final incomingJobs = await TechnicianJobsApi.fetchJobs('incoming');
          
          _log.i('📦 Found ${incomingJobs.length} incoming jobs');
          
          try {
            job = incomingJobs.firstWhere(
              (j) => j.id.toString() == jobId.toString(),
            );
            _log.i('✅ Job found: ${job.id}');
            break;
          } catch (e) {
            _log.w('⚠️ Job $jobId not found in incoming list yet (attempt ${retryCount + 1})');
            if (retryCount < maxRetries - 1) {
              await Future.delayed(retryDelay);
            }
          }
        } catch (e) {
          _log.e('❌ Error fetching jobs: $e');
          if (retryCount < maxRetries - 1) {
            await Future.delayed(retryDelay);
          }
        }
        retryCount++;
      }

      if (job == null) {
        _log.e('❌ Job $jobId not found after $maxRetries attempts. FCM data: $data');
        // Still try to show notification by triggering polling check
        _log.i('🔄 Triggering immediate polling check as fallback...');
        await _checkForNewJobs();
        return;
      }

      // Mark as known to prevent duplicate from polling
      _knownJobIds.add(job.id);
      _closedJobs.remove(job.id);

      // Show notification immediately
      _log.i('🚀 Showing job notification for job ${job.id}');
      await showJobNotification(job);
    } catch (e, stackTrace) {
      _log.e('❌ Error handling FCM job notification: $e', error: e, stackTrace: stackTrace);
      // Fallback: trigger polling to catch the job
      _log.i('🔄 Triggering polling check as fallback after error...');
      await _checkForNewJobs();
    }
  }

  /// Play alarm sound when dialog appears (using external sound file, plays for 20 seconds)
  Future<void> _playAlarmSound() async {
    try {
      _log.i('Playing alarm sound for new job notification (20 seconds)');
      
      // Try to play custom sound file from assets
      // Place your sound file at: assets/sounds/alarm.mp3
      try {
        // Set release mode to loop for 20 seconds
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
        _log.i('Custom alarm sound playing (will loop for 20 seconds)');
        
        // Stop sound after 20 seconds
        Future.delayed(const Duration(seconds: 20), () async {
          await _audioPlayer.stop();
          await _audioPlayer.setReleaseMode(ReleaseMode.release);
          _log.i('Alarm sound stopped after 20 seconds');
        });
      } catch (e) {
        // If custom sound not found, use system notification sound
        _log.w('Custom sound not found, using system notification sound: $e');
        
        final androidDetails = AndroidNotificationDetails(
          'job_alarm_channel',
          'Job Alarm Notifications',
          channelDescription: 'Alarm sound for incoming job notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        );

        final iosDetails = DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: true,
          sound: 'default',
          interruptionLevel: InterruptionLevel.timeSensitive,
        );

        final details = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        await _localNotifications.show(
          999999,
          'New Job Available!',
          'You have a new incoming job',
          details,
        );
        
        // Cancel notification after 20 seconds
        Future.delayed(const Duration(seconds: 20), () {
          _localNotifications.cancel(999999);
        });
      }
    } catch (e, stackTrace) {
      _log.e('Error playing alarm sound: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// Schedule reminder for closed job (30 minutes later)
  void _scheduleReminder(InternalJob job) {
    _closedJobs[job.id] = DateTime.now();
    _log.i('Scheduled reminder for job ${job.id} after 30 minutes');
  }

  /// Stop alarm sound
  Future<void> _stopAlarmSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      _log.i('Alarm sound stopped');
    } catch (e) {
      _log.w('Error stopping alarm sound: $e');
    }
  }

  /// Called after accept/reject so UI can refresh jobs list (e.g. set from nav bar with ref).
  static void Function()? onJobsListChanged;

  /// Handle accept action
  Future<void> _handleAccept(InternalJob job) async {
    try {
      // Stop alarm sound immediately
      await _stopAlarmSound();

      await TechnicianJobsApi.respondToWorkOrder(
        woId: job.id,
        action: 'ACCEPT',
      );
      _log.i('Job ${job.id} accepted');

      // Remove from known jobs and closed jobs
      _knownJobIds.remove(job.id);
      _closedJobs.remove(job.id);

      onJobsListChanged?.call();
    } catch (e) {
      _log.e('Error accepting job: $e');
      rethrow;
    }
  }

  /// Handle reject action
  Future<void> _handleReject(InternalJob job) async {
    try {
      // Stop alarm sound immediately
      await _stopAlarmSound();

      await TechnicianJobsApi.respondToWorkOrder(
        woId: job.id,
        action: 'DECLINE',
      );
      _log.i('Job ${job.id} rejected');

      // Remove from known jobs and closed jobs
      _knownJobIds.remove(job.id);
      _closedJobs.remove(job.id);

      onJobsListChanged?.call();
    } catch (e) {
      _log.e('Error rejecting job: $e');
      rethrow;
    }
  }

  /// Hide current dialog
  void _hideCurrentDialog() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    _isShowingDialog = false;
  }

  /// Cleanup
  void dispose() {
    _stopPolling();
    _hideCurrentDialog();
    _audioPlayer.dispose();
  }
}

/// Overlay widget for job notification
class _JobNotificationOverlay extends StatefulWidget {
  final InternalJob job;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onClose;
  final VoidCallback onTimeout;

  const _JobNotificationOverlay({
    required this.job,
    required this.onAccept,
    required this.onReject,
    required this.onClose,
    required this.onTimeout,
  });

  @override
  State<_JobNotificationOverlay> createState() => _JobNotificationOverlayState();
}

class _JobNotificationOverlayState extends State<_JobNotificationOverlay> {
  bool _canClose = false; // Allow closing after 20 seconds

  @override
  void initState() {
    super.initState();
    // Allow closing after 20 seconds
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted) {
        setState(() {
          _canClose = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: PopScope(
          canPop: _canClose, // Prevent back button during first 20 seconds
          child: Newjobassigned(
            widget.job,
            initialSeconds: 20, // 20 seconds countdown - mandatory viewing
            onClose: widget.onClose,
            onAccept: widget.onAccept,
            onDecline: widget.onReject,
            onTimeout: widget.onTimeout, // Auto-close after 20 seconds
          ),
        ),
      ),
    );
  }
}
