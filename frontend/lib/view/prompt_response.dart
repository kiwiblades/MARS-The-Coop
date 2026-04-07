import 'package:flutter/material.dart';
import 'package:frontend/services/daily_question_service.dart';
import '../constants.dart';
import '../controller/prompt_controller.dart';
import '../model/prompt_model.dart';
import '../model/pigeon.dart';

class PromptResponseFeed extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final DailyQuestionService dqService;

  const PromptResponseFeed({
    Key? key,
    required this.chatId,
    required this.currentUserId,
    required this.dqService,
  }) : super(key: key);

  @override
  State<PromptResponseFeed> createState() => _PromptResponseFeedState();
}

class _PromptResponseFeedState extends State<PromptResponseFeed> {
  late final DailyPromptController _controller;
  final DailyPromptModel _model = DailyPromptModel();
  
  List<PromptResponse> _responses = [];
  DailyPrompt? _prompt;

  @override
  void initState() {
    super.initState();
    _controller = DailyPromptController(
      widget.dqService,
      widget.chatId,
      widget.currentUserId,
    );
    _loadPromptAndResponses();
  }

  Future<void> _loadPromptAndResponses() async {
    if (!mounted) return;
    setState(() {
      _model.isLoading = true;
      _model.loadError = null;
    });

    final promptResult = await _controller.getTodaysPrompt();
    final responsesResult = await _controller.getTodaysResponses();

    if (!mounted) return;
    if (promptResult['success'] && responsesResult['success']) {
      setState(() {
        _prompt = promptResult['prompt'];
        _responses = responsesResult['responses'];
        _model.isLoading = false;
      });
    } else {
      setState(() {
        _model.loadError = promptResult['error'] ?? responsesResult['error'];
        _model.isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_model.isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_model.loadError != null) {
      return _buildErrorView();
    }

    if (_responses.isEmpty || _prompt == null) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppBorderRadius.lg),
                topRight: Radius.circular(AppBorderRadius.lg),
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _prompt!.questionText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: _responses.map((response) {
                final pigeon = response.pigeonId != null
                    ? Pigeon.getById(response.pigeonId!)
                    : null;
                final profileImage =
                    pigeon?.profile ?? 'images/pigeonProfile/defaultPigeonProfile.webp';

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage(profileImage),
                        backgroundColor: Colors.transparent,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              response.username,
                              style: AppTextStyles.label.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              response.answerText,
                              style: AppTextStyles.body.copyWith(fontSize: 14),
                            ),
                            SizedBox(height: 2),
                            Text(
                              _formatTimestamp(response.answeredAt),
                              style: AppTextStyles.label.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Failed to load responses',
            style: AppTextStyles.body,
          ),
          SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _loadPromptAndResponses,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}