import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulso/features/studygram/studygram_data.dart';
import 'package:pulso/features/studygram/studygram_ui.dart';

class StudyUserProfilePage extends ConsumerWidget {
  const StudyUserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(studygramStoreProvider);
    final user = store.userById(userId);
    final posts = store.postsForUser(userId);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: pinkPageGradient()),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              const StudygramHeader(title: 'Profile', showBack: true),
              if (user == null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: softCardDecoration(),
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'This user profile is not available.',
                      style: TextStyle(
                        color: StudygramColors.secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: softCardDecoration(),
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: const Color(0xFFFFD7E4),
                          child: Text(
                            user.name.isEmpty ? '?' : user.name[0],
                            style: const TextStyle(
                              color: StudygramColors.primary,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: StudygramColors.darkText,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.bio,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: StudygramColors.secondaryText,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _Stat(label: 'Posts', value: '${posts.length}'),
                            _Stat(
                              label: 'Likes',
                              value:
                                  '${posts.fold<int>(0, (sum, p) => sum + p.likeCount)}',
                            ),
                            _Stat(
                              label: 'Saved',
                              value:
                                  '${posts.fold<int>(0, (sum, p) => sum + p.savedCount)}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Posts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: StudygramColors.darkText,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: posts.isEmpty
                      ? Container(
                          decoration: softCardDecoration(),
                          padding: const EdgeInsets.all(20),
                          child: const Text(
                            'No posts yet.',
                            style: TextStyle(
                              color: StudygramColors.secondaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : Column(
                          children: posts
                              .map((post) => _UserPostCard(post: post))
                              .toList(),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: StudygramColors.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: StudygramColors.secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _UserPostCard extends StatelessWidget {
  const _UserPostCard({required this.post});

  final StudyPost post;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/comments/${post.id}'),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: softCardDecoration(),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            StudyMaterialPreview(
              icon: post.thumbnailIcon,
              materialName: post.materialName,
              materialBytes: post.materialBytes,
              materialType: post.materialType,
              width: 86,
              height: 86,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: StudygramColors.darkText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.subject,
                    style: const TextStyle(
                      color: StudygramColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.favorite_border_rounded, size: 18),
                      const SizedBox(width: 4),
                      Text('${post.likeCount}'),
                      const SizedBox(width: 16),
                      const Icon(Icons.mode_comment_outlined, size: 18),
                      const SizedBox(width: 4),
                      Text('${post.commentCount}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
