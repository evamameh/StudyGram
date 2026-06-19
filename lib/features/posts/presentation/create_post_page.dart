import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulso/core/providers/supabase_provider.dart';
import 'package:pulso/features/studygram/studygram_data.dart';
import 'package:pulso/features/studygram/studygram_ui.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _subject = studygramSubjects.first;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and notes are required.')),
      );
      return;
    }

    ref.read(studygramStoreProvider).addPost(
          userName: _currentUserName(),
          title: title,
          subject: _subject,
          content: content,
        );
    context.go('/feed');
  }

  String _currentUserName() {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    final metadata = user?.userMetadata ?? const <String, dynamic>{};
    final fullName = metadata['full_name'] as String?;
    if (fullName != null && fullName.trim().isNotEmpty) return fullName.trim();
    final firstName = metadata['first_name'] as String?;
    final lastName = metadata['last_name'] as String?;
    final joined = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    if (joined.isNotEmpty) return joined;
    return user?.email?.split('@').first ?? 'StudyGram Student';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: pinkPageGradient()),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              const StudygramHeader(showBack: true),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Note',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: StudygramColors.darkText,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Share a reviewer, study tip, or class material.',
                      style: TextStyle(color: StudygramColors.secondaryText),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      decoration: softCardDecoration(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Post title',
                              prefixIcon: Icon(Icons.title_rounded),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: _subject,
                            decoration: const InputDecoration(
                              labelText: 'Subject category',
                              prefixIcon: Icon(Icons.menu_book_rounded),
                            ),
                            items: studygramSubjects
                                .map(
                                  (subject) => DropdownMenuItem(
                                    value: subject,
                                    child: Text(subject),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) setState(() => _subject = value);
                            },
                          ),
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Upload material UI only for now.'),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(26),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F5),
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: const Color(0xFFFFC4D8),
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    color: StudygramColors.primary,
                                    size: 42,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Upload material',
                                    style: TextStyle(
                                      color: StudygramColors.darkText,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Image or PDF thumbnail preview',
                                    style: TextStyle(
                                      color: StudygramColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _contentCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Notes content',
                              alignLabelWithHint: true,
                            ),
                            minLines: 7,
                            maxLines: 12,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: 22),
                          FilledButton(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: StudygramColors.primary,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text('Share Post'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.go('/feed'),
                            child: const Text('Save to Draft'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
