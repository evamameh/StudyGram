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
  String _type = 'posts';

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(studygramStoreProvider);
    final results = store.search(
      query: _queryCtrl.text,
      subject: _subject,
      type: _type,
    );
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
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search notes, reviewers, subjects',
                    prefixIcon: Icon(Icons.search_rounded),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                    prefixIconColor: Colors.black,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'posts',
                      label: Text('Posts'),
                      icon: Icon(Icons.article_outlined),
                    ),
                    ButtonSegment(
                      value: 'users',
                      label: Text('Users'),
                      icon: Icon(Icons.person_search_rounded),
                    ),
                    ButtonSegment(
                      value: 'subjects',
                      label: Text('Subjects'),
                      icon: Icon(Icons.menu_book_outlined),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (value) =>
                      setState(() => _type = value.first),
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
                      final subject =
                          index == 0 ? null : chipSubjects[index - 1];
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
                  _sectionTitle(),
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
                  child: Center(
                    child: Text(
                      'No study posts found.',
                      style: TextStyle(
                        color: StudygramColors.secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: results
                        .map((post) => _SearchResultCard(
                              post: post,
                              resultType: _type,
                            ))
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

  String _sectionTitle() {
    return switch (_type) {
      'users' => 'People',
      'subjects' => 'Subjects',
      _ => 'Recommended Content',
    };
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.post,
    required this.resultType,
  });

  final StudyPost post;
  final String resultType;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (resultType == 'users') {
          context.push('/study-users/${post.userId}');
        } else {
          context.push('/comments/${post.id}');
        }
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: softCardDecoration(),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            StudyMaterialPreview(
              icon: post.thumbnailIcon,
              materialName: post.materialName,
              materialBytes: post.materialBytes,
              materialType: post.materialType,
              width: 92,
              height: 92,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resultType == 'users' ? post.userName : post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: StudygramColors.darkText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    switch (resultType) {
                      'users' => 'Tap to view profile',
                      'subjects' => post.subject,
                      _ => post.userName,
                    },
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
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
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${post.pageCount} pages',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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
