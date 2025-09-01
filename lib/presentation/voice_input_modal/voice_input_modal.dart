import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/category_chips_widget.dart';
import './widgets/error_retry_widget.dart';
import './widgets/language_toggle_widget.dart';
import './widgets/microphone_button_widget.dart';
import './widgets/transcription_display_widget.dart';
import './widgets/voice_waveform_widget.dart';

/// Voice Input Modal for hands-free expense and income entry
class VoiceInputModal extends StatefulWidget {
  const VoiceInputModal({super.key});

  @override
  State<VoiceInputModal> createState() => _VoiceInputModalState();
}

class _VoiceInputModalState extends State<VoiceInputModal>
    with TickerProviderStateMixin {
  // Voice recognition state
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSinhala = false;
  String _transcribedText = '';
  double _confidence = 0.0;
  String? _selectedCategory;
  String? _errorMessage;
  double _amplitude = 0.0;

  // Animation controllers
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Timers
  Timer? _listeningTimer;
  Timer? _amplitudeTimer;

  // Mock voice recognition data for demonstration
  final List<Map<String, dynamic>> _mockRecognitionResults = [
    {
      'text_en': 'Add expense Rs. 500 for lunch',
      'text_si': 'දිවා ආහාරය සඳහා රුපියල් 500 වියදම් එකතු කරන්න',
      'confidence': 0.95,
      'category': 'food',
      'amount': 500.0,
      'type': 'expense',
    },
    {
      'text_en': 'Transport cost Rs. 150',
      'text_si': 'ප්‍රවාහන වියදම රුපියල් 150',
      'confidence': 0.88,
      'category': 'transport',
      'amount': 150.0,
      'type': 'expense',
    },
    {
      'text_en': 'Income Rs. 25000 from salary',
      'text_si': 'වැටුපෙන් රුපියල් 25000 ආදායම',
      'confidence': 0.92,
      'category': 'salary',
      'amount': 25000.0,
      'type': 'income',
    },
    {
      'text_en': 'Bill payment Rs. 3500',
      'text_si': 'බිල්පත් ගෙවීම රුපියල් 3500',
      'confidence': 0.85,
      'category': 'bills',
      'amount': 3500.0,
      'type': 'expense',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _requestMicrophonePermission();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  Future<void> _requestMicrophonePermission() async {
    try {
      if (kIsWeb) {
        // Web: Browser handles microphone permissions
        return;
      } else {
        // Mobile: Request microphone permission
        // This would use permission_handler package in real implementation
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Microphone permission denied';
      });
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _isProcessing = false;
      _transcribedText = '';
      _confidence = 0.0;
      _errorMessage = null;
      _amplitude = 0.0;
    });

    // Start amplitude simulation for waveform
    _amplitudeTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isListening) {
        setState(() {
          _amplitude = 0.3 +
              (0.7 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000);
        });
      }
    });

    // Simulate listening timeout
    _listeningTimer = Timer(const Duration(seconds: 5), () {
      if (_isListening) {
        _processVoiceInput();
      }
    });

    HapticFeedback.mediumImpact();
  }

  void _stopListening() {
    _listeningTimer?.cancel();
    _amplitudeTimer?.cancel();

    if (_isListening) {
      _processVoiceInput();
    }
  }

  void _processVoiceInput() {
    setState(() {
      _isListening = false;
      _isProcessing = true;
      _amplitude = 0.0;
    });

    // Simulate processing delay
    Timer(const Duration(seconds: 2), () {
      _simulateVoiceRecognition();
    });
  }

  void _simulateVoiceRecognition() {
    // Get random mock result
    final result = (_mockRecognitionResults..shuffle()).first;

    setState(() {
      _isProcessing = false;
      _transcribedText = _isSinhala ? result['text_si'] : result['text_en'];
      _confidence = result['confidence'];
      _selectedCategory = result['category'];
    });

    // Auto-navigate to add transaction after successful recognition
    Timer(const Duration(seconds: 2), () {
      _navigateToAddTransaction(result);
    });

    HapticFeedback.lightImpact();
  }

  void _navigateToAddTransaction(Map<String, dynamic> result) {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/add-transaction',
      arguments: {
        'voice_data': result,
        'transcribed_text': _transcribedText,
        'category': _selectedCategory,
        'language': _isSinhala ? 'si' : 'en',
      },
    );
  }

  void _retryVoiceInput() {
    setState(() {
      _errorMessage = null;
      _transcribedText = '';
      _confidence = 0.0;
      _selectedCategory = null;
    });
  }

  void _requestPermission() {
    _requestMicrophonePermission();
  }

  void _closeModal() {
    _slideController.reverse().then((_) {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _listeningTimer?.cancel();
    _amplitudeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: _closeModal,
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(),
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: 85.h,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.shadow.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {}, // Prevent tap through
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(context),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(6.w),
                              child: Column(
                                children: [
                                  _buildVoiceSection(context),
                                  SizedBox(height: 4.h),
                                  _buildTranscriptionSection(context),
                                  SizedBox(height: 4.h),
                                  _buildCategorySection(context),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Language toggle
          LanguageToggleWidget(
            isSinhala: _isSinhala,
            onLanguageChanged: (isSinhala) {
              setState(() {
                _isSinhala = isSinhala;
                _transcribedText = '';
                _confidence = 0.0;
              });
            },
          ),

          const Spacer(),

          // Title
          Text(
            _isSinhala ? 'කටහඬ ආදානය' : 'Voice Input',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Close button
          IconButton(
            onPressed: _closeModal,
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSection(BuildContext context) {
    return Column(
      children: [
        // Waveform animation
        if (_isListening || _isProcessing)
          VoiceWaveformWidget(
            isListening: _isListening,
            isProcessing: _isProcessing,
            amplitude: _amplitude,
          ),

        SizedBox(height: 4.h),

        // Microphone button
        MicrophoneButtonWidget(
          onPressed: _toggleListening,
          isListening: _isListening,
          isProcessing: _isProcessing,
          isIdle: !_isListening && !_isProcessing,
        ),

        SizedBox(height: 2.h),

        // Status text
        Text(
          _getStatusText(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTranscriptionSection(BuildContext context) {
    if (_errorMessage != null) {
      return ErrorRetryWidget(
        errorMessage: _errorMessage!,
        isSinhala: _isSinhala,
        onRetry: _retryVoiceInput,
        onPermissionRequest: _requestPermission,
      );
    }

    return TranscriptionDisplayWidget(
      transcribedText: _transcribedText,
      isSinhala: _isSinhala,
      confidence: _confidence,
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return CategoryChipsWidget(
      isSinhala: _isSinhala,
      selectedCategory: _selectedCategory,
      onCategorySelected: (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }

  String _getStatusText() {
    if (_isListening) {
      return _isSinhala ? 'සවන් දෙමින්...' : 'Listening...';
    } else if (_isProcessing) {
      return _isSinhala ? 'සැකසෙමින්...' : 'Processing...';
    } else if (_transcribedText.isNotEmpty) {
      return _isSinhala ? 'සාර්ථකයි!' : 'Success!';
    } else {
      return _isSinhala
          ? 'මයික්‍රෆෝන් ස්පර්ශ කර කතා කරන්න'
          : 'Tap microphone and speak';
    }
  }
}