import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../controller/prompt_controller.dart';
import '../model/prompt_model.dart';
import '../services/daily_question_service.dart';

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
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        
        // Prompt card - BOTTOM ALIGNED with TAB
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab header
              Padding(
                padding: EdgeInsets.only(left: AppSpacing.sm, right: 160),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppBorderRadius.md),
                      topRight: Radius.circular(AppBorderRadius.md),
                    ),
                    border: Border(
                      left: BorderSide(color: AppColors.border, width: 1),
                      top: BorderSide(color: AppColors.border, width: 1),
                      right: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, size: 20),
                        padding: EdgeInsets.symmetric(),
                        constraints: BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Daily Question',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Main card
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.lg,
                  top: AppSpacing.md,
                ),
                decoration: BoxDecoration(color: AppColors.background),
                child: _model.isLoading
                    ? _buildLoadingView()
                    : _model.loadError != null
                        ? _buildErrorView()
                        : _buildPromptContent(),
              ),
            ],
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

  Widget _buildPromptContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text
        Text(
          _prompt?.questionText ?? 'Loading question...',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20),
        ),
        SizedBox(height: AppSpacing.md),

        // Input row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _answerController,
                autofocus: true,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Type your answer here...',
                  hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),

            // Send button
            IconButton(
              icon: _model.isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.send),
              color: _canSubmit
                  ? AppColors.primary
                  : AppColors.textSecondary,
              onPressed: _canSubmit && !_model.isSubmitting
                  ? _submitAnswer
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}