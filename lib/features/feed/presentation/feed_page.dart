import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulso/features/studygram/studygram_data.dart';
import 'package:pulso/features/studygram/studygram_ui.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  String? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(studygramStoreProvider);
    final posts = _selectedSubject == null
        ? store.posts
        : store.posts.where((post) => post.subject == _selectedSubject).toList();
    final chipSubjects = studygramSubjects.where((s) => s != 'Others').toList();

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: pinkPageGradient()),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              StudygramHeader(
                trailing: IconButton(
                  onPressed: () => context.go('/search'),
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: chipSubjects.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final subject = index == 0 ? null : chipSubjects[index - 1];
                      return SubjectPill(
                        label: subject ?? 'All',
                        selected: subject == _selectedSubject,
                        onTap: () => setState(() => _selectedSubject = subject),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: posts.map((post) => StudyPostCard(post: post)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/compose'),
        backgroundColor: StudygramColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      bottomNavigationBar: const StudygramBottomNav(currentIndex: 0),
    );
  }
}

class StudyPostCard extends ConsumerWidget {
  const StudyPostCard({super.key, required this.post});

  final StudyPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: softCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFFFD7E4),
                  child: Text(
                    post.userName.isEmpty ? '?' : post.userName[0],
                    style: const TextStyle(
                      color: StudygramColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          color: StudygramColors.darkText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        post.timestamp,
                        style: const TextStyle(
                          color: StudygramColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _SubjectTag(label: post.subject),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              post.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: StudygramColors.darkText,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: StudygramColors.secondaryText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            StudyThumbnail(icon: post.thumbnailIcon, height: 150),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () => ref.read(studygramStoreProvider).toggleLike(post.id),
                  icon: Icon(
                    post.likedByMe
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                  ),
                  color: StudygramColors.primary,
                ),
                Text('${post.likeCount}'),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => context.push('/comments/${post.id}'),
                  icon: const Icon(Icons.mode_comment_outlined),
                  color: StudygramColors.primary,
                ),
                Text('${post.commentCount}'),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border_rounded),
                  color: StudygramColors.darkPink,
                  tooltip: 'Save',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectTag extends StatelessWidget {
  const _SubjectTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD7E4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: StudygramColors.darkPink,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
