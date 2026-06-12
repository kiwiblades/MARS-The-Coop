import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../controller/journalentry_controller.dart';
import '../model/journalentry_model.dart';
import '../model/pigeon.dart';
import '../services/api_client.dart';
import '../services/journalentry_service.dart';

class JournalPage extends StatefulWidget {
  static const String routeName = '/journalPage';

  final String subjectId;
  final String userName; // username of journal owner
  final int pigeonId; // pigeon id for profile image

  const JournalPage({
    super.key,
    required this.subjectId,
    required this.userName,
    required this.pigeonId,
  });

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late final JournalController _controller;
  final JournalEntryModel _model = JournalEntryModel();
  final TextEditingController _entryController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<JournalEntry> _entries = [];
  bool _hasMore = true;
  String? _editingEntryId;
  String? _actionEntryId;

  @override
  void initState() {
    super.initState();
    _controller = JournalController(
      widget.subjectId, 
      journalService: JournalService(api: ApiClient()),
    );
    _setupScrollListener();
    _loadEntries();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // load more when scrolled to top (older entries)
      if (_scrollController.position.pixels == 0 &&
          _hasMore &&
          !_model.isLoading) {
        _loadMoreEntries();
      }
    });
  }

  Future<void> _loadEntries() async {
    setState(() {
      _model.isLoading = true;
      _model.loadError = null;
    });

    final result = await _controller.loadEntries();

    if (result['success']) {
      setState(() {
        _entries = result['entries'];
        _hasMore = result['hasMore'];
        _model.isLoading = false;
      });
      _scrollToBottom();
    } else {
      setState(() {
        _model.loadError = result['error'];
        _model.isLoading = false;
      });
    }
  }

  Future<void> _loadMoreEntries() async {
    final result = await _controller.loadEntries(
      offset: _entries.length,
      limit: 50,
    );

    if (result['success']) {
      setState(() {
        _entries.insertAll(0, result['entries']);
        _hasMore = result['hasMore'];
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _submitEntry() async {
    final content = _entryController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _model.isSubmitting = true;
    });

    final result = await _controller.createEntry(content);
    if (!mounted) return;

    if (result['success']) {
      _entryController.clear();
      setState(() {
        _entries.add(result['entry']);
        _model.isSubmitting = false;
      });
      _scrollToBottom();
    } else {
      setState(() {
        _model.isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed to save entry: ${result['error']}')),
      );
    }
  }

  Future<void> _submitEditedEntry() async {
    final content = _editController.text.trim();
    if (content.isEmpty || _editingEntryId == null) return;

    setState(() {
      _model.isSubmitting = true;
    });

    final result = await _controller.updateEntry(_editingEntryId!, content);
    if (!mounted) return;

    if (result['success']) {
      setState(() {
        final index = _entries.indexWhere((e) => e.id == _editingEntryId);
        if (index != -1) {
          _entries[index] = JournalEntry(
            id: _editingEntryId!,
            content: content,
            timestamp: _entries[index].timestamp,
            editedAt: DateTime.now(),
          );
        }
        _editingEntryId = null;
        _editController.clear();
        _model.isSubmitting = false;
      });
    } else {
      setState(() {
        _model.isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed to save entry: ${result['error']}')),
      );
    }
  }

  void _startEditing(JournalEntry entry) {
    setState(() {
      _editingEntryId = entry.id;
      _editController.text = entry.content;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingEntryId = null;
      _editController.clear();
    });
  }

  Future<void> _showDeleteConfirmation(String entryId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('delete entry', style: AppTextStyles.heading),
        content: Text(
          'delete this entry? this cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel',
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'delete',
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteEntry(entryId);
    }
  }

  Future<void> _deleteEntry(String entryId) async {
    final result = await _controller.deleteEntry(entryId);
    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _entries.removeWhere((e) => e.id == entryId);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('failed to delete entry')));
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _editController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Container(
        // ADD THIS CONTAINER
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/woodGrainTexture.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _model.loadError != null
              ? _buildErrorView()
              : Column(
                  children: [
                    Expanded(child: _buildEntryList()),
                    _buildInputArea(),
                  ],
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final pigeon = Pigeon.getById(widget.pigeonId);
    final sideImage =
        pigeon?.side ?? 'images/pigeonSide/defaultPigeonSide.webp';

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      toolbarHeight: 150,
      leadingWidth: 24,
      titleSpacing: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Keep status bar transparent
        statusBarIconBrightness:
            Brightness.dark, // Dark icons on light background
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.transparent,
            ),
            child: Center(
              child: Image.asset(
                sideImage,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              widget.userName,
              style: AppTextStyles.heading.copyWith(fontSize: 22),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryList() {
    if (_model.isLoading && _entries.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_entries.isEmpty) {
      return Center(
        child: Text(
          'no entries yet.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            _buildEntryCard(_entries[index]),
            SizedBox(height: AppSpacing.md),
          ],
        );
      },
    );
  }

  // String _getDateKey(DateTime timestamp) {
  //   final now = DateTime.now();
  //   final difference = now.difference(timestamp);

  //   if (difference.inDays == 0) {
  //     return 'today';
  //   } else if (difference.inDays == 1) {
  //     return 'yesterday';
  //   } else {
  //     return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
  //   }
  // }

  // Widget _buildDateHeader(String dateKey) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
  //     child: Center(
  //       child: Text(
  //         dateKey,
  //         style: AppTextStyles.label.copyWith(
  //           fontSize: 12,
  //           color: AppColors.textSecondary,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildEntryCard(JournalEntry entry) {
    final isEditing = _editingEntryId == entry.id;
    final showActions = _actionEntryId == entry.id;

    return GestureDetector(
      onLongPress: isEditing
          ? null
          : () {
              setState(() {
                _actionEntryId = entry.id;
              });
            },
      onTap: () {
        if (!isEditing && showActions) {
          setState(() {
            _actionEntryId = null;
          });
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // main card
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: (isEditing || showActions) ? 50 : AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightBrown,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(
                color: isEditing ? AppColors.primary : AppColors.border,
                width: isEditing ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // content
                isEditing
                    ? TextField(
                        controller: _editController,
                        maxLines: 10,
                        minLines: 1,
                        maxLength: 5000,
                        autofocus: true,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      )
                    : Text(entry.content, style: AppTextStyles.body),
                if (entry.isEdited && !isEditing)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'edited',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // timestamp label on top border
          Positioned(
            top: -8,
            left: AppSpacing.md,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Text(
                _formatTimestamp(entry.timestamp),
                style: AppTextStyles.label.copyWith(
                  fontSize: 10,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          if (isEditing || showActions)
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Row(
                children: [
                  if (isEditing) ...[
                    IconButton(
                      icon: Icon(Icons.close, size: 20),
                      color: AppColors.error,
                      onPressed: _cancelEditing,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    IconButton(
                      icon: Icon(Icons.check, size: 20),
                      color: AppColors.primary,
                      onPressed: _submitEditedEntry,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ] else if (showActions) ...[
                    IconButton(
                      icon: Icon(Icons.edit, size: 18),
                      color: AppColors.primary,
                      onPressed: () => _startEditing(entry),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    IconButton(
                      icon: Icon(Icons.delete, size: 18),
                      color: AppColors.error,
                      onPressed: () => _showDeleteConfirmation(entry.id),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour > 12
        ? timestamp.hour - 12
        : (timestamp.hour == 0 ? 12 : timestamp.hour);
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'pm' : 'am';
    final time = '$hour:$minute $period';

    final date = '${timestamp.month}/${timestamp.day}/${timestamp.year}';

    return '$date $time';
  }

  // void _showEntryOptions(JournalEntry entry) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: AppColors.background,
  //     builder: (context) => Container(
  //       padding: EdgeInsets.all(AppSpacing.md),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: Icon(Icons.edit, color: AppColors.textPrimary),
  //             title: Text('edit', style: AppTextStyles.body),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _startEditing(entry);
  //             },
  //           ),
  //           ListTile(
  //             leading: Icon(Icons.delete, color: AppColors.error),
  //             title: Text(
  //               'delete',
  //               style: AppTextStyles.body.copyWith(color: AppColors.error),
  //             ),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _showDeleteConfirmation(entry.id);
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('failed to load journal', style: AppTextStyles.body),
          SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _loadEntries,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
            ),
            child: Text('retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _entryController,
              onChanged: (text) => setState(() {}),
              maxLines: 5,
              minLines: 1,
              maxLength: 5000,
              decoration: InputDecoration(
                hintText: 'write your thoughts...', // Changed hint text
                hintStyle: AppTextStyles.label,
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
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
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
          IconButton(
            icon: Icon(
              Icons.send,
              color: _entryController.text.trim().isEmpty
                  ? AppColors.textSecondary
                  : AppColors.primary,
            ),
            onPressed: _entryController.text.trim().isEmpty
                ? null
                : _submitEntry,
          ),
        ],
      ),
    );
  }
}
