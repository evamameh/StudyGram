import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulso/features/studygram/studygram_data.dart';
import 'package:pulso/features/studygram/studygram_ui.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _queryCtrl = TextEditingController();
  String? _subject;

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(studygramStoreProvider);
    final results = store.search(query: _queryCtrl.text, subject: _subject);
    final chipSubjects = studygramSubjects.where((s) => s != 'Others').toList();

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: pinkPageGradient()),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              const StudygramHeader(title: 'Search'),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextField(
                  controller: _queryCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search notes, reviewers, subjects',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
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
                        selected: subject == _subject,
                        onTap: () => setState(() => _subject = subject),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Recommended Content',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: StudygramColors.darkText,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              if (results.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 42),
                  child: Center(child: Text('No study posts found.')),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: results
                        .map((post) => _SearchResultCard(post: post))
                        .toList(),
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
      bottomNavigationBar: const StudygramBottomNav(currentIndex: 1),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.post});

  final StudyPost post;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/comments/${post.id}'),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: softCardDecoration(),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            StudyThumbnail(icon: post.thumbnailIcon, width: 92, height: 92),
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
                    post.userName,
                    style: const TextStyle(color: StudygramColors.secondaryText),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD7E4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          post.subject,
                          style: const TextStyle(
                            color: StudygramColors.darkPink,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${post.pageCount} pages',
                        style: const TextStyle(
                          color: StudygramColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
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
