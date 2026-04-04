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

  @override
  void initState() {
    super.initState();
    _controller = DailyPromptController(
      widget.dqService,
      widget.chatId,
      widget.currentUserId,
    );
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    if (!mounted) return;
    setState(() {
      _model.isLoading = true;
      _model.loadError = null;
    });

    final result = await _controller.getTodaysResponses();

    if (!mounted) return;
    if (result['success']) {
      setState(() {
        _responses = result['responses'];
        _model.isLoading = false;
      });
    } else {
      setState(() {
        _model.loadError = result['error'];
        _model.isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Today\'s Responses',
            style: AppTextStyles.heading.copyWith(fontSize: 18),
          ),
          SizedBox(height: AppSpacing.md),
          
          // Content
          if (_model.isLoading)
            Center(child: CircularProgressIndicator(color: AppColors.primary))
          else if (_model.loadError != null)
            _buildErrorView()
          else if (_responses.isEmpty)
            _buildEmptyState()
          else
            _buildResponseList(),
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
            onPressed: _loadResponses,
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

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No responses yet. You\'re the first!',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildResponseList() {
    return Column(
      children: _responses.map((response) => Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: _buildResponseBubble(response),
      )).toList(),
    );
  }

  Widget _buildResponseBubble(PromptResponse response) {
    final pigeon = response.pigeonId != null 
        ? Pigeon.getById(response.pigeonId!)
        : null;
    final profileImage = pigeon?.profile ?? 'images/pigeonProfile/defaultPigeonProfile.png';
    
    return Align(
      alignment: response.isSentByCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!response.isSentByCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(profileImage),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: response.isSentByCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!response.isSentByCurrentUser)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      response.username,
                      style: AppTextStyles.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: response.isSentByCurrentUser
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  ),
                  child: Text(
                    response.answerText,
                    style: AppTextStyles.body.copyWith(
                      color: response.isSentByCurrentUser
                          ? AppColors.background
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatTimestamp(response.answeredAt),
                  style: AppTextStyles.label.copyWith(fontSize: 12),
                ),
              ],
            ),
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