import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:pulso/core/providers/supabase_provider.dart';
import 'package:pulso/features/studygram/studygram_data.dart';
import 'package:pulso/features/studygram/studygram_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _subject = studygramSubjects.first;
  PlatformFile? _material;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMaterial() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) return;
    if (file.bytes == null || file.bytes!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read the selected file.')),
      );
      return;
    }
    setState(() => _material = file);
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and notes are required.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await _tryUploadMaterialToSupabase(title, content);
      ref.read(studygramStoreProvider).addPost(
            userId: 'me',
            userName: _currentUserName(),
            title: title,
            subject: _subject,
            content: content,
            materialName: _material?.name,
            materialBytes: _material?.bytes,
            materialType: _materialMimeType(),
          );
      if (!mounted) return;
      context.go('/feed');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not share post: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _tryUploadMaterialToSupabase(
      String title, String content) async {
    final file = _material;
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (file == null || file.bytes == null || user == null) return;

    final client = ref.read(supabaseClientProvider);
    final ext = file.extension ?? (file.name.split('.').last);
    final objectPath =
        '${user.id}/${DateTime.now().microsecondsSinceEpoch}.$ext';
    final mimeType = _materialMimeType();
    await client.storage.from('posts').uploadBinary(
          objectPath,
          file.bytes!,
          fileOptions: FileOptions(
            contentType: mimeType,
            upsert: true,
          ),
        );
    final publicUrl = client.storage.from('posts').getPublicUrl(objectPath);
    await client.from('posts').insert({
      'user_id': user.id,
      'image_url': publicUrl,
      'caption': '[$subjectLabel] $title\n\n$content',
    });
  }

  String get subjectLabel => _subject;

  String _materialMimeType() {
    final ext = (_material?.extension ?? '').toLowerCase();
    if (ext == 'pdf') return 'application/pdf';
    if (ext == 'png') return 'image/png';
    return 'image/jpeg';
  }

  String _currentUserName() {
    final localName = ref.read(studygramStoreProvider).currentUser.name;
    if (localName != 'StudyGram Student') return localName;
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
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: StudygramColors.darkText,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Share a reviewer, study tip, or class material.',
                      style: TextStyle(
                        color: StudygramColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      decoration: softCardDecoration(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleCtrl,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Post title',
                              prefixIcon: Icon(Icons.title_rounded),
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
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: _subject,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            dropdownColor: Colors.white,
                            decoration: const InputDecoration(
                              labelText: 'Subject category',
                              prefixIcon: Icon(Icons.menu_book_rounded),
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
                            items: studygramSubjects
                                .map(
                                  (subject) => DropdownMenuItem(
                                    value: subject,
                                    child: Text(
                                      subject,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _subject = value);
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: _pickMaterial,
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
                              child: Column(
                                children: [
                                  Icon(
                                    _material?.extension?.toLowerCase() == 'pdf'
                                        ? Icons.picture_as_pdf_rounded
                                        : Icons.cloud_upload_outlined,
                                    color: StudygramColors.primary,
                                    size: 42,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _material?.name ?? 'Upload material',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: StudygramColors.darkText,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _material == null
                                        ? 'Pick an image or PDF'
                                        : 'Tap to replace attached material',
                                    style: const TextStyle(
                                      color: StudygramColors.secondaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _contentCtrl,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Notes content',
                              alignLabelWithHint: true,
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            minLines: 7,
                            maxLines: 12,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: 22),
                          FilledButton(
                            onPressed: _submitting ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: StudygramColors.primary,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Share Post'),
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
