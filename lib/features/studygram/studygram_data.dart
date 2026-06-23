import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const studygramSubjects = [
  'Mathematics',
  'Programming',
  'Physics',
  'Biology',
  'English',
  'Others',
];

final studygramStoreProvider = ChangeNotifierProvider<StudygramStore>(
  (ref) => StudygramStore(),
);

class StudyPost {
  const StudyPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.title,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.timestamp,
    required this.thumbnailIcon,
    required this.pageCount,
    required this.savedCount,
    this.materialName,
    this.materialBytes,
    this.materialType,
    this.likedByMe = false,
    this.savedByMe = false,
    this.isMine = false,
  });

  final String id;
  final String userId;
  final String userName;
  final String subject;
  final String title;
  final String content;
  final int likeCount;
  final int commentCount;
  final String timestamp;
  final IconData thumbnailIcon;
  final int pageCount;
  final int savedCount;
  final String? materialName;
  final List<int>? materialBytes;
  final String? materialType;
  final bool likedByMe;
  final bool savedByMe;
  final bool isMine;

  bool get hasMaterial => materialName != null && materialName!.isNotEmpty;
  bool get hasImageMaterial =>
      materialBytes != null && (materialType?.startsWith('image/') ?? false);
  bool get hasPdfMaterial => materialType == 'application/pdf';

  StudyPost copyWith({
    int? likeCount,
    int? commentCount,
    int? savedCount,
    bool? likedByMe,
    bool? savedByMe,
  }) {
    return StudyPost(
      id: id,
      userId: userId,
      userName: userName,
      subject: subject,
      title: title,
      content: content,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      timestamp: timestamp,
      thumbnailIcon: thumbnailIcon,
      pageCount: pageCount,
      savedCount: savedCount ?? this.savedCount,
      materialName: materialName,
      materialBytes: materialBytes,
      materialType: materialType,
      likedByMe: likedByMe ?? this.likedByMe,
      savedByMe: savedByMe ?? this.savedByMe,
      isMine: isMine,
    );
  }
}

class StudyComment {
  const StudyComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    this.parentId,
    this.likeCount = 0,
    this.likedByMe = false,
  });

  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  final String? parentId;
  final int likeCount;
  final bool likedByMe;

  bool get isReply => parentId != null;

  StudyComment copyWith({
    int? likeCount,
    bool? likedByMe,
  }) {
    return StudyComment(
      id: id,
      postId: postId,
      userId: userId,
      userName: userName,
      text: text,
      createdAt: createdAt,
      parentId: parentId,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }
}

class StudyUser {
  const StudyUser({
    required this.id,
    required this.name,
    required this.bio,
    this.avatarBytes,
  });

  final String id;
  final String name;
  final String bio;
  final List<int>? avatarBytes;
}

class StudygramStore extends ChangeNotifier {
  StudygramStore()
      : _posts = [
          const StudyPost(
            id: 'post-1',
            userId: 'mika-santos',
            userName: 'Mika Santos',
            subject: 'Mathematics',
            title: 'Quadratic Formula Reviewer',
            content:
                'Remember the pattern: identify a, b, and c first, then substitute carefully. I added sample solutions for factoring and completing the square.',
            likeCount: 18,
            commentCount: 3,
            timestamp: '2h ago',
            thumbnailIcon: Icons.calculate_rounded,
            pageCount: 8,
            savedCount: 12,
          ),
          const StudyPost(
            id: 'post-2',
            userId: 'alex-reyes',
            userName: 'Alex Reyes',
            subject: 'Programming',
            title: 'Flutter State Basics',
            content:
                'Use setState for small local UI changes. Move shared app data into a provider so screens can react to one source of truth.',
            likeCount: 24,
            commentCount: 5,
            timestamp: '4h ago',
            thumbnailIcon: Icons.code_rounded,
            pageCount: 12,
            savedCount: 19,
          ),
          const StudyPost(
            id: 'post-3',
            userId: 'bea-cruz',
            userName: 'Bea Cruz',
            subject: 'Biology',
            title: 'Cell Organelles Cheat Sheet',
            content:
                'Nucleus controls the cell, mitochondria releases energy, ribosomes make proteins, and the cell membrane manages entry and exit.',
            likeCount: 12,
            commentCount: 2,
            timestamp: 'Yesterday',
            thumbnailIcon: Icons.biotech_rounded,
            pageCount: 6,
            savedCount: 8,
          ),
          const StudyPost(
            id: 'post-4',
            userId: 'carlo-dela-cruz',
            userName: 'Carlo Dela Cruz',
            subject: 'English',
            title: 'Essay Introduction Tip',
            content:
                'Start with context, narrow the topic, then end the introduction with a clear thesis statement that answers the prompt.',
            likeCount: 9,
            commentCount: 1,
            timestamp: '2d ago',
            thumbnailIcon: Icons.edit_note_rounded,
            pageCount: 4,
            savedCount: 5,
          ),
        ],
        _comments = {
          'post-1': [
            StudyComment(
              id: 'comment-1',
              postId: 'post-1',
              userId: 'jana-lim',
              userName: 'Jana',
              text: 'This helped me review fast.',
              createdAt: DateTime(2026, 6, 22, 7, 20),
              likeCount: 2,
            ),
            StudyComment(
              id: 'comment-2',
              postId: 'post-1',
              userId: 'luis-garcia',
              userName: 'Luis',
              text: 'Can you add word problems?',
              createdAt: DateTime(2026, 6, 22, 7, 28),
              likeCount: 1,
            ),
            StudyComment(
              id: 'reply-1',
              postId: 'post-1',
              userId: 'mika-santos',
              userName: 'Mika Santos',
              text: 'Yes, I will add a practice set tonight.',
              createdAt: DateTime(2026, 6, 22, 7, 35),
              parentId: 'comment-2',
            ),
            StudyComment(
              id: 'comment-3',
              postId: 'post-1',
              userId: 'nica-tan',
              userName: 'Nica',
              text: 'Clear examples. Thanks!',
              createdAt: DateTime(2026, 6, 22, 7, 45),
            ),
          ],
          'post-2': [
            StudyComment(
              id: 'comment-4',
              postId: 'post-2',
              userId: 'sam-villanueva',
              userName: 'Sam',
              text: 'Provider example please.',
              createdAt: DateTime(2026, 6, 22, 6, 10),
            ),
            StudyComment(
              id: 'comment-5',
              postId: 'post-2',
              userId: 'elle-ramos',
              userName: 'Elle',
              text: 'Simple and useful.',
              createdAt: DateTime(2026, 6, 22, 6, 18),
            ),
          ],
          'post-3': [
            StudyComment(
              id: 'comment-6',
              postId: 'post-3',
              userId: 'miguel-flores',
              userName: 'Miguel',
              text: 'Saved for our quiz.',
              createdAt: DateTime(2026, 6, 21, 14),
            ),
          ],
          'post-4': [
            StudyComment(
              id: 'comment-7',
              postId: 'post-4',
              userId: 'anne-uy',
              userName: 'Anne',
              text: 'The thesis tip is useful.',
              createdAt: DateTime(2026, 6, 20, 16),
            ),
          ],
        },
        _currentUser = const StudyUser(
          id: 'me',
          name: 'StudyGram Student',
          bio: 'Sharing clear reviewers and simple study notes for classmates.',
        );

  final List<StudyPost> _posts;
  final Map<String, List<StudyComment>> _comments;
  StudyUser _currentUser;

  List<StudyPost> get posts => List.unmodifiable(_posts);
  StudyUser get currentUser => _currentUser;

  void updateCurrentUser({
    required String name,
    required String bio,
    List<int>? avatarBytes,
  }) {
    _currentUser = StudyUser(
      id: 'me',
      name: name.trim().isEmpty ? 'StudyGram Student' : name.trim(),
      bio: bio.trim().isEmpty
          ? 'Sharing clear reviewers and simple study notes for classmates.'
          : bio.trim(),
      avatarBytes: avatarBytes ?? _currentUser.avatarBytes,
    );
    notifyListeners();
  }

  StudyPost? postById(String id) {
    for (final post in _posts) {
      if (post.id == id) return post;
    }
    return null;
  }

  StudyUser? userById(String userId) {
    if (userId == _currentUser.id) return _currentUser;
    final posts = postsForUser(userId);
    String? name = posts.isEmpty ? null : posts.first.userName;
    if (name == null) {
      for (final comments in _comments.values) {
        for (final comment in comments) {
          if (comment.userId == userId) {
            name = comment.userName;
            break;
          }
        }
        if (name != null) break;
      }
    }
    if (name == null) return null;
    return StudyUser(
      id: userId,
      name: name,
      bio: '$name shares concise reviewers and classroom notes on StudyGram.',
    );
  }

  List<StudyPost> postsForUser(String userId) {
    return _posts
        .where((post) => post.userId == userId)
        .toList(growable: false);
  }

  List<StudyPost> get savedPosts {
    return _posts.where((post) => post.savedByMe).toList(growable: false);
  }

  List<StudyComment> commentsFor(String postId) {
    final comments = List<StudyComment>.from(_comments[postId] ?? const []);
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return List.unmodifiable(comments);
  }

  List<StudyComment> topLevelCommentsFor(String postId) {
    return commentsFor(postId).where((comment) => !comment.isReply).toList();
  }

  List<StudyComment> repliesFor(String postId, String parentId) {
    return commentsFor(postId)
        .where((comment) => comment.parentId == parentId)
        .toList();
  }

  List<StudyPost> search({
    required String query,
    required String? subject,
    String type = 'posts',
  }) {
    final normalized = query.trim().toLowerCase();
    return _posts.where((post) {
      final source = switch (type) {
        'users' => post.userName,
        'subjects' => post.subject,
        _ => '${post.title} ${post.content} ${post.userName} ${post.subject}',
      };
      final haystack = source.toLowerCase();
      final matchesQuery = normalized.isEmpty || haystack.contains(normalized);
      final matchesSubject = subject == null || post.subject == subject;
      return matchesQuery && matchesSubject;
    }).toList(growable: false);
  }

  void toggleLike(String postId) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;
    final post = _posts[index];
    _posts[index] = post.copyWith(
      likedByMe: !post.likedByMe,
      likeCount: post.likedByMe ? post.likeCount - 1 : post.likeCount + 1,
    );
    notifyListeners();
  }

  void toggleSave(String postId) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;
    final post = _posts[index];
    _posts[index] = post.copyWith(
      savedByMe: !post.savedByMe,
      savedCount: post.savedByMe
          ? (post.savedCount > 0 ? post.savedCount - 1 : 0)
          : post.savedCount + 1,
    );
    notifyListeners();
  }

  void deletePost(String postId) {
    _posts.removeWhere((post) => post.id == postId);
    _comments.remove(postId);
    notifyListeners();
  }

  void deleteComment(String postId, String commentId) {
    final comments = List<StudyComment>.from(_comments[postId] ?? const []);
    comments.removeWhere(
      (comment) => comment.id == commentId || comment.parentId == commentId,
    );
    _comments[postId] = comments;

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        commentCount: comments.where((comment) => !comment.isReply).length,
      );
    }
    notifyListeners();
  }

  void toggleCommentLike(String commentId) {
    for (final entry in _comments.entries) {
      final index =
          entry.value.indexWhere((comment) => comment.id == commentId);
      if (index == -1) continue;
      final comment = entry.value[index];
      entry.value[index] = comment.copyWith(
        likedByMe: !comment.likedByMe,
        likeCount: comment.likedByMe
            ? (comment.likeCount > 0 ? comment.likeCount - 1 : 0)
            : comment.likeCount + 1,
      );
      notifyListeners();
      return;
    }
  }

  void addPost({
    String? userId,
    required String userName,
    required String title,
    required String subject,
    required String content,
    String? materialName,
    List<int>? materialBytes,
    String? materialType,
  }) {
    _posts.insert(
      0,
      StudyPost(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        userId: userId ?? 'me',
        userName: userName,
        subject: subject,
        title: title,
        content: content,
        likeCount: 0,
        commentCount: 0,
        timestamp: 'Just now',
        thumbnailIcon: materialType == 'application/pdf'
            ? Icons.picture_as_pdf_rounded
            : Icons.description_rounded,
        pageCount: 1,
        savedCount: 0,
        materialName: materialName,
        materialBytes: materialBytes,
        materialType: materialType,
        isMine: true,
      ),
    );
    notifyListeners();
  }

  void addComment({
    required String postId,
    String? userId,
    required String userName,
    required String text,
    String? parentCommentId,
  }) {
    final comments = List<StudyComment>.from(_comments[postId] ?? const []);
    comments.add(
      StudyComment(
        id: 'comment-${DateTime.now().microsecondsSinceEpoch}',
        postId: postId,
        userId: userId ?? 'me',
        userName: userName,
        text: text,
        createdAt: DateTime.now(),
        parentId: parentCommentId,
      ),
    );
    _comments[postId] = comments;

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        commentCount: comments.where((comment) => !comment.isReply).length,
      );
    }
    notifyListeners();
  }
}
