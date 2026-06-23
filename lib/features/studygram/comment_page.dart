import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulso/core/providers/supabase_provider.dart';
import 'package:pulso/features/studygram/studygram_data.dart';
import 'package:pulso/features/studygram/studygram_ui.dart';

class CommentPage extends ConsumerStatefulWidget {
  const CommentPage({
    super.key,
    required this.postId,
    this.replyToCommentId,
  });

  final String postId;
  final String? replyToCommentId;

  @override
  ConsumerState<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends ConsumerState<CommentPage> {
  final _commentCtrl = TextEditingController();
  StudyComment? _replyingTo;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    ref.read(studygramStoreProvider).addComment(
          postId: widget.postId,
          userId: 'me',
          userName: _currentUserName(),
          text: text,
          parentCommentId: _replyingTo?.id,
        );
    _commentCtrl.clear();
    setState(() => _replyingTo = null);
  }

  String _currentUserName() {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    final metadata = user?.userMetadata ?? const <String, dynamic>{};
    final fullName = metadata['full_name'] as String?;
    if (fullName != null && fullName.trim().isNotEmpty) return fullName.trim();
    return user?.email?.split('@').first ?? 'You';
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(studygramStoreProvider);
    final post = store.postById(widget.postId);
    final comments = store.topLevelCommentsFor(widget.postId);
    if (_replyingTo == null && widget.replyToCommentId != null) {
      final allComments = store.commentsFor(widget.postId);
      for (final comment in allComments) {
        if (comment.id == widget.replyToCommentId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _replyingTo == null) {
              setState(() => _replyingTo = comment);
            }
          });
          break;
        }
      }
    }

    if (post == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: FilledButton(
              onPressed: () => context.go('/feed'),
              child: const Text('Back to feed'),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: pinkPageGradient()),
        child: SafeArea(
          child: Column(
            children: [
              const StudygramHeader(title: 'Comments', showBack: true),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  children: [
                    _PostSummary(post: post),
                    const SizedBox(height: 18),
                    if (comments.isEmpty)
                      Container(
                        decoration: softCardDecoration(),
                        padding: const EdgeInsets.all(20),
                        child: const Text(
                          'No comments yet. Start the discussion.',
                          style: TextStyle(
                            color: StudygramColors.secondaryText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      ...comments.map(
                        (comment) => _CommentThread(
                          comment: comment,
                          replies: store.repliesFor(widget.postId, comment.id),
                          postId: widget.postId,
                          onReply: () => context.push(
                            '/comments/${widget.postId}/replies/${comment.id}',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_replyingTo != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Replying to ${_replyingTo!.userName}',
                                  style: const TextStyle(
                                    color: StudygramColors.darkPink,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    setState(() => _replyingTo = null),
                                icon: const Icon(Icons.close_rounded),
                                tooltip: 'Cancel reply',
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentCtrl,
                              decoration: InputDecoration(
                                hintText: _replyingTo == null
                                    ? 'Write a comment...'
                                    : 'Write a reply...',
                              ),
                              minLines: 1,
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filled(
                            onPressed: _send,
                            icon: const Icon(Icons.send_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: StudygramColors.primary,
                              foregroundColor: Colors.white,
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
      ),
    );
  }
}

class _PostSummary extends StatelessWidget {
  const _PostSummary({required this.post});

  final StudyPost post;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: softCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudyMaterialPreview(
            icon: post.thumbnailIcon,
            materialName: post.materialName,
            materialBytes: post.materialBytes,
            materialType: post.materialType,
            width: 82,
            height: 82,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    color: StudygramColors.darkText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => context.push('/study-users/${post.userId}'),
                  child: Text(
                    '${post.userName} - ${post.subject}',
                    style: const TextStyle(
                      color: StudygramColors.secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: StudygramColors.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentThread extends ConsumerWidget {
  const _CommentThread({
    required this.comment,
    required this.replies,
    required this.postId,
    required this.onReply,
  });

  final StudyComment comment;
  final List<StudyComment> replies;
  final String postId;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CommentCard(comment: comment, postId: postId, onReply: onReply),
        if (replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 38, bottom: 6),
            child: Column(
              children: replies
                  .map(
                    (reply) => _CommentCard(
                      comment: reply,
                      postId: postId,
                      compact: true,
                      onReply: onReply,
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _CommentCard extends ConsumerWidget {
  const _CommentCard({
    required this.comment,
    required this.postId,
    required this.onReply,
    this.compact = false,
  });

  final StudyComment comment;
  final String postId;
  final VoidCallback onReply;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> confirmDelete() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete comment?'),
          content: Text(
            comment.isReply
                ? 'This reply will be removed.'
                : 'This comment and its replies will be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      ref.read(studygramStoreProvider).deleteComment(postId, comment.id);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: softCardDecoration(),
      padding: EdgeInsets.all(compact ? 12 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.push('/study-users/${comment.userId}'),
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              radius: compact ? 16 : 20,
              backgroundColor: const Color(0xFFFFD7E4),
              child: Text(
                comment.userName.isEmpty ? '?' : comment.userName[0],
                style: const TextStyle(
                  color: StudygramColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            context.push('/study-users/${comment.userId}'),
                        child: Text(
                          comment.userName,
                          style: const TextStyle(
                            color: StudygramColors.darkText,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      _timeLabel(comment.createdAt),
                      style: const TextStyle(
                        color: StudygramColors.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: confirmDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: StudygramColors.darkPink,
                      tooltip: 'Delete comment',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.text,
                  style: const TextStyle(
                    color: StudygramColors.secondaryText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () => ref
                          .read(studygramStoreProvider)
                          .toggleCommentLike(comment.id),
                      child: Text(
                        comment.likedByMe ? 'Liked' : 'Like',
                        style: const TextStyle(
                          color: StudygramColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (comment.likeCount > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${comment.likeCount}',
                        style: const TextStyle(
                          color: StudygramColors.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(width: 18),
                    InkWell(
                      onTap: onReply,
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          color: StudygramColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime createdAt) {
    final delta = DateTime.now().difference(createdAt);
    if (delta.inMinutes < 1) return 'now';
    if (delta.inMinutes < 60) return '${delta.inMinutes}m';
    if (delta.inHours < 24) return '${delta.inHours}h';
    return '${delta.inDays}d';
  }
}
