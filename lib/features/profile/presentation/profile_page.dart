import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulso/core/providers/supabase_provider.dart';
import 'package:pulso/features/auth/providers/auth_providers.dart';
import 'package:pulso/features/studygram/studygram_data.dart';
import 'package:pulso/features/studygram/studygram_ui.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(supabaseClientProvider).auth.currentUser;
    final store = ref.watch(studygramStoreProvider);
    final fullName = _displayName(user?.userMetadata, user?.email);
    final myPosts = store.posts.where((post) => post.isMine).toList();
    final visiblePosts = _tab == 0 ? myPosts : store.posts.take(2).toList();

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: pinkPageGradient()),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              StudygramHeader(
                title: 'Profile',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => context.go('/search'),
                      icon: const Icon(Icons.search_rounded),
                    ),
                    IconButton(
                      tooltip: 'Logout',
                      onPressed: () async {
                        await ref.read(authServiceProvider).signOut();
                      },
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: softCardDecoration(),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 54,
                        backgroundColor: Color(0xFFFFD7E4),
                        child: Icon(
                          Icons.person_rounded,
                          size: 62,
                          color: StudygramColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: StudygramColors.darkText,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: const [
                          _Badge(label: 'Student'),
                          _Badge(label: 'Note Sharer'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sharing clear reviewers and simple study notes for classmates.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: StudygramColors.secondaryText,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _Stat(label: 'Posts', value: '${myPosts.length}'),
                          const _Stat(label: 'Followers', value: '128'),
                          _Stat(
                            label: 'Saved',
                            value: '${store.posts.fold<int>(0, (sum, p) => sum + p.savedCount)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                backgroundColor: StudygramColors.primary,
                              ),
                              child: const Text('Edit Profile'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Settings'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Notes')),
                    ButtonSegment(value: 1, label: Text('Saved')),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (value) => setState(() => _tab = value.first),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: visiblePosts.isEmpty
                    ? Container(
                        decoration: softCardDecoration(),
                        padding: const EdgeInsets.all(20),
                        child: const Text(
                          'No notes yet. Create your first study post from the home page.',
                          style: TextStyle(color: StudygramColors.secondaryText),
                        ),
                      )
                    : Column(
                        children: visiblePosts
                            .map((post) => _ProfilePostCard(post: post))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const StudygramBottomNav(currentIndex: 3),
    );
  }

  String _displayName(Map<String, dynamic>? metadata, String? email) {
    final fullName = metadata?['full_name'] as String?;
    if (fullName != null && fullName.trim().isNotEmpty) return fullName.trim();
    final firstName = metadata?['first_name'] as String?;
    final lastName = metadata?['last_name'] as String?;
    final joined = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    if (joined.isNotEmpty) return joined;
    return email?.split('@').first ?? 'StudyGram Student';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFFFFD7E4),
      labelStyle: const TextStyle(
        color: StudygramColors.darkPink,
        fontWeight: FontWeight.w800,
      ),
      side: BorderSide.none,
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
        Text(label, style: const TextStyle(color: StudygramColors.secondaryText)),
      ],
    );
  }
}

class _ProfilePostCard extends StatelessWidget {
  const _ProfilePostCard({required this.post});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudyThumbnail(icon: post.thumbnailIcon, height: 150),
            const SizedBox(height: 12),
            Chip(
              label: Text(post.subject),
              backgroundColor: const Color(0xFFFFD7E4),
              labelStyle: const TextStyle(
                color: StudygramColors.darkPink,
                fontWeight: FontWeight.w800,
              ),
              side: BorderSide.none,
            ),
            Text(
              post.title,
              style: const TextStyle(
                color: StudygramColors.darkText,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: StudygramColors.secondaryText),
            ),
            const SizedBox(height: 10),
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
    );
  }
}
