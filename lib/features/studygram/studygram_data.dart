import 'package:flutter/foundation.dart';
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
    this.likedByMe = false,
    this.isMine = false,
  });

  final String id;
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
  final bool likedByMe;
  final bool isMine;

  StudyPost copyWith({
    int? likeCount,
    int? commentCount,
    bool? likedByMe,
  }) {
    return StudyPost(
      id: id,
      userName: userName,
      subject: subject,
      title: title,
      content: content,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      timestamp: timestamp,
      thumbnailIcon: thumbnailIcon,
      pageCount: pageCount,
      savedCount: savedCount,
      likedByMe: likedByMe ?? this.likedByMe,
      isMine: isMine,
    );
  }
}

class StudyComment {
  const StudyComment({
    required this.userName,
    required this.text,
  });

  final String userName;
  final String text;
}

class StudygramStore extends ChangeNotifier {
  StudygramStore()
      : _posts = [
          const StudyPost(
            id: 'post-1',
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
          'post-1': const [
            StudyComment(userName: 'Jana', text: 'This helped me review fast.'),
            StudyComment(userName: 'Luis', text: 'Can you add word problems?'),
            StudyComment(userName: 'Nica', text: 'Clear examples. Thanks!'),
          ],
          'post-2': const [
            StudyComment(userName: 'Sam', text: 'Provider example please.'),
            StudyComment(userName: 'Elle', text: 'Simple and useful.'),
          ],
          'post-3': const [
            StudyComment(userName: 'Miguel', text: 'Saved for our quiz.'),
          ],
          'post-4': const [
            StudyComment(userName: 'Anne', text: 'The thesis tip is useful.'),
          ],
        };

  final List<StudyPost> _posts;
  final Map<String, List<StudyComment>> _comments;

  List<StudyPost> get posts => List.unmodifiable(_posts);

  StudyPost? postById(String id) {
    for (final post in _posts) {
      if (post.id == id) return post;
    }
    return null;
  }

  List<StudyComment> commentsFor(String postId) {
    return List.unmodifiable(_comments[postId] ?? const []);
  }

  List<StudyPost> search({
    required String query,
    required String? subject,
  }) {
    final normalized = query.trim().toLowerCase();
    return _posts.where((post) {
      final matchesQuery = normalized.isEmpty ||
          post.title.toLowerCase().contains(normalized) ||
          post.subject.toLowerCase().contains(normalized);
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

  void addPost({
    required String userName,
    required String title,
    required String subject,
    required String content,
  }) {
    _posts.insert(
      0,
      StudyPost(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        userName: userName,
        subject: subject,
        title: title,
        content: content,
        likeCount: 0,
        commentCount: 0,
        timestamp: 'Just now',
        thumbnailIcon: Icons.description_rounded,
        pageCount: 1,
        savedCount: 0,
        isMine: true,
      ),
    );
    notifyListeners();
  }

  void addComment({
    required String postId,
    required String userName,
    required String text,
  }) {
    final comments = List<StudyComment>.from(_comments[postId] ?? const []);
    comments.add(StudyComment(userName: userName, text: text));
    _comments[postId] = comments;

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(commentCount: comments.length);
    }
    notifyListeners();
  }
}
