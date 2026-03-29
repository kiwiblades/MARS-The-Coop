import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/services/daily_question_service.dart';
import 'dart:ui';
import '../constants.dart';
import '../controller/prompt_controller.dart';
import '../model/prompt_model.dart';

class DailyPromptModal extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final DailyQuestionService dqService;
  final VoidCallback onAnswerSubmitted;

  const DailyPromptModal({
    Key? key,
    required this.chatId,
    required this.currentUserId,
    required this.onAnswerSubmitted,
    required this.dqService,
  }) : super(key: key);

  @override
  State<DailyPromptModal> createState() => _DailyPromptModalState();
}

class _DailyPromptModalState extends State<DailyPromptModal> {
  late final DailyPromptController _controller;
  final DailyPromptModel _model = DailyPromptModel();
  final TextEditingController _answerController = TextEditingController();
  StreamSubscription? _answerAcceptedSubscription;
  
  DailyPrompt? _prompt;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _controller = DailyPromptController(
      widget.dqService,
      widget.chatId,
      widget.currentUserId,
    );
    _loadPrompt();
    
    _answerController.addListener(() {
      setState(() {
        _canSubmit = _answerController.text.trim().isNotEmpty;
      });
    });

    // listen for server confirmation
    _answerAcceptedSubscription = widget.dqService.onAnswerAccepted().listen((_) {
      if (!mounted) return;
      widget.onAnswerSubmitted();
    });
  }

  Future<void> _loadPrompt() async {
    setState(() {
      _model.isLoading = true;
      _model.loadError = null;
    });

    final result = await _controller.getTodaysPrompt();

    if (result['success']) {
      setState(() {
        _prompt = result['prompt'];
        _model.isLoading = false;
      });
    } else {
      setState(() {
        _model.loadError = result['error'];
        _model.isLoading = false;
      });
    }
  }

  Future<void> _submitAnswer() async {
    final answerText = _answerController.text.trim();
    if (answerText.isEmpty) return;

    setState(() {
      _model.isSubmitting = true;
      _model.submitError = null;
    });

    final result = await _controller.submitAnswer(answerText);

    if (!result['success']) {
      setState(() {
        _model.submitError = result['error'];
        _model.isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit answer: ${result['error']}')),
      );
    }
  }

  @override
  void dispose() {
    _answerAcceptedSubscription?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        
        // Modal content
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: _model.isLoading
                ? _buildLoadingView()
                : _model.loadError != null
                    ? _buildErrorView()
                    : _buildPromptView(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: AppSpacing.md),
        Text(
          'Loading today\'s prompt...',
          style: AppTextStyles.body,
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Failed to load prompt',
          style: AppTextStyles.heading.copyWith(fontSize: 18),
        ),
        SizedBox(height: AppSpacing.md),
        ElevatedButton(
          onPressed: _loadPrompt,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
          ),
          child: Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildPromptView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Daily Prompt',
            style: AppTextStyles.heading.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          
          // date
          Text(
            _prompt?.date ?? 'Today',
            style: AppTextStyles.label,
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // question card
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _prompt?.questionText ?? '',
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // answer input
          TextField(
            controller: _answerController,
            autofocus: true,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              hintStyle: AppTextStyles.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              counterText: '',
              contentPadding: EdgeInsets.all(AppSpacing.md),
            ),
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // character count
          Text(
            '${_answerController.text.length}/500',
            style: AppTextStyles.label.copyWith(fontSize: 12),
            textAlign: TextAlign.right,
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // submit button
          ElevatedButton(
            onPressed: _canSubmit && !_model.isSubmitting ? _submitAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.5),
            ),
            child: _model.isSubmitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.background,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Submit Answer',
                    style: AppTextStyles.button,
                  ),
          ),
          
          SizedBox(height: AppSpacing.sm),
          
          // Info text
          Text(
            'Answer to unlock your flock\'s responses',
            style: AppTextStyles.label.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}